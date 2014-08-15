//
//  SystemInfomationViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemInfomationViewController.h"
#import "GetFrame.h"
#import "SystemInfoTableView.h"
#import "SystemInformationData.h"
#import "PersonCardViewController.h"
#import "AnswerRequestViewController.h"
#import "Whistle.h"
#import "BizlayerProxy.h"
#import "SystemMessageInfo.h"
#import "CrowdSystemViewController.h"
#import "FriendInfo.h"
#import "AgreeToAddFriendViewController.h"
#import "ImUtils.h"
#import "RosterManager.h"
#import "NBNavigationController.h"
#import "SystemMsgManager.h"
#import "CustomActionSheet.h"

#define SYSTEM_SEND_DATE @"sendDate"
#define SYSTEM_MESSAGE @"systemMessage"

#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000

@interface SystemInfomationViewController ()
<SystemInformationDataDelegate, SystemInfoTableViewDelegate,NBNavigationControllerDelegate,UIAlertViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;

    SystemInformationData * m_infoData;
    
    SystemInfoTableView * m_systemInfoTableView;
    
    NSMutableDictionary * m_dictSystemMessage;
    
    UIButton * m_rightBarButton;
    
}

@property (nonatomic, strong) SystemInformationData * m_infoData;

@property (nonatomic, strong) SystemInfoTableView * m_systemInfoTableView;
@property (nonatomic, strong) NSMutableDictionary * m_dictSystemMessage;
@property (nonatomic, strong) UIButton * m_rightBarButton;



@end

@implementation SystemInfomationViewController

@synthesize m_infoData;
@synthesize m_systemInfoTableView;
@synthesize m_dictSystemMessage;
@synthesize m_rightBarButton;

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
    [self setBaseCondition];
    [self createSystemInfoTableView];
    [self createSystemInformationData];
    [self getSystemMessageWithStartIndex:-1 andCount:20];
    [self createNavigationBar:YES];
}

- (void)createSystemInformationData
{
    self.m_infoData = [[SystemInformationData alloc] init];
    self.m_infoData.m_delegate = self;
}

- (void)setBaseCondition
{
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
}

#pragma mark -
#pragma mark - BarButtonItem
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"delete" andLeftTitle:NSLocalizedString(@"system_list", nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) rightNavigationBarButtonPressed:(UIButton *)button
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"全部删除", @"取消", nil];
    [[[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:nil] show];
}

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 0) {
        [self deleteAllMessage];
    }
}

- (void)deleteAllMessage
{
    [[SystemMsgManager shareInstance] deleteAllSystemMsgWithCallback:^(BOOL success) {
        NSLog(@"delete all system message == %d", success);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}


- (void)createSystemInfoTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        if (m_is4Inch) {
            height = m_frame.size.height - 64;
        } else {
            height = m_frame.size.height - 64;
        }
    } else {
        height = m_frame.size.height - 44;
    }
    
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.m_systemInfoTableView = [[SystemInfoTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_systemInfoTableView.backgroundColor = [UIColor clearColor];
    self.m_systemInfoTableView.m_delegate = self;
    [self.view addSubview:self.m_systemInfoTableView];
}

- (void)pushPersonInfoToController:(FriendInfo *)friendInfo andSystemMessage:(SystemMessageInfo *)messageInfo isStranger:(BOOL)stranger
{
    PersonCardViewController * controller = [[PersonCardViewController alloc] init];
    controller.m_jid = friendInfo.jid;
    controller.hidesBottomBarWhenPushed = YES;
    
    [[RosterManager shareInstance] getRelationShip:controller.m_jid WithCallback:^(enum FriendRelation relationShip) {
        BOOL isStranger = NO;
        if (relationShip == RelationStranger || relationShip == RelationNone) {
            isStranger = YES;
        } else if (relationShip == RelationContact) {
            isStranger = NO;
        }
        controller.m_isStranger = isStranger;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:controller animated:YES];
        });
    }];

}

- (void)answerRequest:(SystemMessageInfo *)messageInfo
{
    AnswerRequestViewController * controller = [[AnswerRequestViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.m_systemMessageInfo = messageInfo;
    controller.m_friendInfo = messageInfo.extraObject;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) pushCrowdInfoToController:(CrowdInfo *)crowd andSystemMessage:(SystemMessageInfo *)message
{
    CrowdSystemViewController* controller = [[CrowdSystemViewController alloc] init];
    controller.systemMsgInfo = message;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToAgreeToAddFriendViewController:(SystemMessageInfo *)messageInfo
{
    AgreeToAddFriendViewController * controller = [[AgreeToAddFriendViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.m_messageInfo = messageInfo;
    controller.m_friendInfo = messageInfo.extraObject;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteSystemMessage:(SystemMessageInfo *)messageInfo
{
    [self.m_infoData deleteSystemMsg:messageInfo];
}

- (void)markReadSystemMessage:(SystemMessageInfo *)messageInfo
{
//    messageInfo.isRead = YES;
    [[SystemMsgManager shareInstance] markSystemRead:messageInfo withCallback:^(BOOL isSuccess) {
        
    }];
}

- (void)getMoreSystemItemsWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count
{
    [self getSystemMessageWithStartIndex:startIndex andCount:count];
}

- (void)getSystemMessageWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.m_infoData constructSystemMessageTableViewDataWithStartIndex:startIndex andCount:count];
    });
}

- (void)sendSystemMessage:(NSMutableDictionary *)dataDict andTotalCount:(NSUInteger)totalCount
{
    self.m_dictSystemMessage = dataDict;
    self.m_systemInfoTableView.m_totalCount = totalCount;
    [self.m_systemInfoTableView refreshNoticeTableView:self.m_dictSystemMessage];
    if (totalCount <= 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    m_systemInfoTableView.openedIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
