//
//  PersonCardViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PersonCardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendsDetailInfoViewController.h"
#import "TalkingRecordViewController.h"
#import "ChangeRemarkViewController.h"
#import "FriendInfo.h"
#import "GBPathImageView.h"
#import <MessageUI/MessageUI.h>
#import "Whistle.h"
#import "GetFrame.h"
#import "NetworkBrokenAlert.h"
#import "RosterManager.h"
#import "PersonCardInfo.h"
#import "PrivateTalkViewController.h"
#import "JSONObjectHelper.h"
#import "RequestFriendsViewController.h"
#import "RosterManager.h"
#import "NBNavigationController.h"
#import "PersonCardView.h"
#import "PersonalSettingData.h"
#import "ImUtils.h"
#import "PrivateTalkViewController.h"
#import "ChangeTextInfoViewController.h"
#import "CustomActionSheet.h"

#define BUTTON_TAG_START 1000
#define RECORD_BUTTON_TAG 1000
#define CHANGE_REMARK_BUTTON_TAG 1001
#define DELETE_FRIEND_BUTTON_TAG 1002


#define PHONE_BUTTON_START_TAG 2000
#define PHONE_BUTTON_TAG 2000
#define NOTE_BUTTON_TAG 2001

#define LEFT_ITEM_TAG 5000
#define RIGHT_ITEM_TAG 3000

#define FRIEND @"friend"


@interface PersonCardViewController ()
<UITextViewDelegate, UIAlertViewDelegate, TalkingRecordViewControllerDelegate, PersonCardInfoDelegate, PersonCardViewDelegate, CustomActionSheetDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    PersonCardInfo * m_cardInfo;
    FriendInfo * m_friendInfo;
    NSString * m_rightBarBtnType;
    PersonCardView * m_personCardView;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic, strong) PersonCardInfo * m_cardInfo;
@property (nonatomic, strong) FriendInfo * m_friendInfo;
@property (nonatomic, strong) NSString * m_rightBarBtnType;
@property (nonatomic, strong) PersonCardView * m_personCardView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@end

@implementation PersonCardViewController

@synthesize m_friendInfo;
@synthesize m_delegate;
@synthesize m_isStranger;
@synthesize m_cardInfo;
@synthesize m_jid;
@synthesize m_rightBarBtnType;
@synthesize m_personCardView;
@synthesize m_arrTableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setbasicCondition];
    [self createNavigationBar:YES];
    [self createTableData];
    [self createPersonCardView];
    [self setPersonCardInfo];
    [self getData];
}

- (void)setbasicCondition
{
    self.view.backgroundColor =[ImUtils colorWithHexString:@"F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createTableData
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    if (self.m_isStranger) {
        [self.m_arrTableData addObject:[self getFirstSectionArr]];
    } else {
        [self.m_arrTableData addObject:[self getFirstSectionArr]];
        [self.m_arrTableData addObject:[self getSecondSectionArr]];
        [self.m_arrTableData addObject:[self getThirdSectionArr]];
    }
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * signData = [[PersonalSettingData alloc] init];
    signData.m_title = @"个性签名";
    signData.m_cellHeight = 45;
    signData.m_hasLabel = YES;
    signData.m_hasHeaderLine = YES;
    [sectionArr addObject:signData];
    
    PersonalSettingData * detailData = [[PersonalSettingData alloc] init];
    detailData.m_title = @"详细资料";
    detailData.m_cellHeight = 45;
    detailData.m_hasIndicator = YES;
    [sectionArr addObject:detailData];

    return  sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * remarkData = [[PersonalSettingData alloc] init];
    remarkData.m_title = @"修改备注";
    remarkData.m_cellHeight = 45;
    remarkData.m_hasLabel = YES;
    remarkData.m_hasHeaderLine = YES;
    remarkData.m_hasIndicator = YES;
    [sectionArr addObject:remarkData];
    
    return  sectionArr;
}

- (NSMutableArray *)getThirdSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * recordData = [[PersonalSettingData alloc] init];
    recordData.m_title = @"聊天记录";
    recordData.m_cellHeight = 45;
    recordData.m_hasHeaderLine = YES;
    recordData.m_hasIndicator = YES;
    [sectionArr addObject:recordData];
    
    return  sectionArr;
}

- (void)createPersonCardView
{
    m_frame = [[UIScreen mainScreen] bounds];
    
    CGFloat y = 0.0f;
    if (m_isIOS7) {
        y += 64.0f;
    }
    self.m_personCardView = [[PersonCardView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 20.0f - 44.0f)];
    self.m_personCardView.m_delegate = self;
    self.m_personCardView.m_isStranger = self.m_isStranger;
    [self.view addSubview:self.m_personCardView];
}

// PersonCardView delegate
- (void)changeRemark
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = @"备注";
    controller.m_placeHolder = [[RosterManager shareInstance] getShownameByIdentity:self.m_friendInfo];
    controller.m_numberOfWords = 12;
    controller.m_type = @"friendRemark";
    controller.m_friendInfo = self.m_friendInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

// PersonCardView delegate
- (void)showTalkRecord
{
    TalkingRecordViewController * controller = [[TalkingRecordViewController alloc] init];
    controller.inputObject = self.m_friendInfo;
    controller.m_delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

// PersonCardView delegate
- (void)showDetailInfo
{
    FriendsDetailInfoViewController * controller = [[FriendsDetailInfoViewController alloc] init];
    controller.m_friendInfo = self.m_friendInfo;
    controller.m_type = FRIEND;
    [self.navigationController pushViewController:controller animated:YES];
}


// PersonCardView delegate
- (void)deleteFriend
{
    [self createDeleteFriendAlertView];
}

// PersonCardView delegate
- (void)callUp
{
    [self callAction];
}

// PersonCardView delegate
- (void)sendMessage
{
    [self sendMsg];
}

- (void)sendMsg
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"sms://", self.m_friendInfo.cellphone]]];
    NSLog(@"send message!!!!!!!!!!!!! send message!!!!!!!!!!!!!");
}

- (void)callAction
{
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSString * phoneNum = [NSString stringWithFormat:@"tel:%@", self.m_friendInfo.cellphone];
    NSURL *telURL =[NSURL URLWithString:phoneNum];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    [self.view addSubview:callWebview];
    NSLog(@"call phone!!!!!!!!!!!!! call phone!!!!!!!!!!!!!");
}

// PersonCardView delegate
- (void)talkingWithFriend
{
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = self.m_friendInfo;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// PersonCardView delegate
- (void)addFriend
{
    RequestFriendsViewController * requestViewController = [[RequestFriendsViewController alloc] init];
    requestViewController.m_friendInfo = self.m_friendInfo;
    [self.navigationController pushViewController:requestViewController animated:YES];
}

// 没有电话或电话不可见的情况
- (void)showPhoneList
{
    [self showCustomActionSheet];
}

- (void)showCustomActionSheet
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"发送", @"取消", nil];
    
    CustomActionSheet * sheet = [[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:@"没电话没人爱，快来添加你的电话号码吧!"];
    sheet.tag = 2000;
    [sheet show];
}

- (void)pushToPrivateTalkViewController
{
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = self.m_friendInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setPersonCardInfo
{
    self.m_cardInfo = [[PersonCardInfo alloc] init];
    self.m_cardInfo.m_delegate = self;
}

- (void)getData
{
    if (self.m_jid) {
        [self.m_cardInfo getUserDetailInfoWithJid:self.m_jid];
    }
}

// PersonCardInfo delegate
- (void)sendFriendInfo:(FriendInfo *)friendInfo
{
    self.m_friendInfo = friendInfo;
    NSLog(@"friendInfo.moodWords -- in PersonCardViewController == %@", friendInfo.moodWords);
    [self resetMoodWordsWithFriendInfo:self.m_friendInfo];
    [self.m_personCardView createSubViewsWithFriendInfo:self.m_friendInfo andTableDataArr:self.m_arrTableData];
}

- (void)resetMoodWordsWithFriendInfo:(FriendInfo *)friendInfo
{
    NSMutableArray * sectionArr = nil;
    if ([self.m_arrTableData count] > 0) {
        sectionArr = [self.m_arrTableData objectAtIndex:0];
    }
    
    if ([sectionArr count] > 0) {
        PersonalSettingData * signatureData = [sectionArr objectAtIndex:0];
        signatureData.m_content = friendInfo.moodWords;
        NSLog(@"content  ===== %@", signatureData.m_content);
        
        
        CGSize textSize = [self.m_friendInfo.moodWords sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        if (textSize.height < 30) {
            signatureData.m_cellHeight = 45;
        } else {
            signatureData.m_cellHeight = textSize.height + 10;
        }
        signatureData.m_textHeight = textSize.height;
        NSLog(@"textSize for sign in edit page == %@", NSStringFromCGSize(textSize));
    }
    
    NSLog(@" [[RosterManager shareInstance] getShownameByIdentity:friendInfo] == %@",  [[RosterManager shareInstance] getShownameByIdentity:friendInfo]);
    if ([self.m_arrTableData count] > 1) {
        NSMutableArray * remarkArr = [self.m_arrTableData objectAtIndex:1];
        if ([remarkArr count] > 0) {
            PersonalSettingData * nickNameData = [remarkArr objectAtIndex:0];
            nickNameData.m_content = [[RosterManager shareInstance] getShownameByIdentity:friendInfo];
            NSLog(@"nickNameData title == %@", nickNameData.m_title);
            
            CGSize textSize = [nickNameData.m_content sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 10000) lineBreakMode:NSLineBreakByWordWrapping];
            if (textSize.height < 30) {
                nickNameData.m_cellHeight = 45;
            } else {
                nickNameData.m_cellHeight = textSize.height + 10;
            }
            nickNameData.m_textHeight = textSize.height;
        }
    }
}

// PersonCardInfo delegate
- (void)deleteFriendSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
}

// PersonCardInfo delegate
- (void)friendInfoUpdate:(FriendInfo *)friendInfo
{
    if ([friendInfo.jid isEqualToString:self.m_friendInfo.jid]) {
        self.m_friendInfo = friendInfo;
        [self resetMoodWordsWithFriendInfo:self.m_friendInfo];
        [self.m_personCardView refreshViews:self.m_friendInfo andTableDataArr:self.m_arrTableData];
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NSString * title = nil;
    if (self.m_isStranger) {
        title = @"个人名片";
    } else {
        title = @"好友名片";
    }
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:title andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 获取最新数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self createNavigationBar:NO];
}

// TalkingRecordViewController delegate --> 聊天记录删除后，清空最后一条聊天信息
- (void)clearLastConversation
{
    [m_delegate clearLastConversation];
}

- (void)createDeleteFriendAlertView
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    NSArray * titleArr = [NSArray arrayWithObjects:@"确定", @"取消", nil];
    CustomActionSheet * sheet = [[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:@"确定删除好友?"];
    sheet.tag = 1000;
    [sheet show];
}

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (customActionSheet.tag == 1000) {
        if (buttonIndex == 0) {
            [self.m_cardInfo deleteFriendWithFriendInfo:self.m_friendInfo];
        }
    } else if (customActionSheet.tag == 2000) {
        if(buttonIndex == 0){
            [self pushToPrivateTalkViewController];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
