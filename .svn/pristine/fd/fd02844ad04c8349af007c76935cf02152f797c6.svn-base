//
//  TalkingRecordViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "TalkingRecordViewController.h"


#import "Whistle.h"
#import "Constants.h"
#import "EmoView.h"
#import "SmileyParser.h"
#import <QuartzCore/CALayer.h>
#import "HPGrowingTextView.h"
#import "ConversationInfo.h"
#import "TalkFromTextCell.h"
#import "TalkFromImgCell.h"
#import "TalkToImgCell.h"
#import "TalkToTextCell.h"
#import "FriendInfo.h"
#import "JSONObjectHelper.h"
#import "ChatRecord.h"
#import "MessageLayoutInfo.h"
#import "MessageText.h"
#import "MessageImage.h"
#import "BizlayerProxy.h"
#import "PersonCardViewController.h"
#import "BizBridge.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVWebViewController.h"
#import "ImUtils.h"
#import "RosterManager.h"
#import "DiscussionManager.h"
#import "CrowdManager.h"
#import "RecentRecord.h"
#import "QTLeftVoiceMessageCell.h"
#import "QTRightVoiceMessageCell.h"
#import "LightAppInfo.h"
#import "LightAppMessageInfo.h"
#import "LightAppNewsCell.h"
#import "TalkSingleNewsCell.h"

#import "Manager.h"
#import "GetFrame.h"
#import "OHASBasicHTMLParser.h"
#import "NBNavigationController.h"
#import "amrEnDecodeManager.h"
#import "PhotoPreviewController.h"

#define kFacesRegionHeight          150
#define emoSinglePageNum          27
#define emoSinglePageNumColunm 7
#define kImageContentHeight 75

#define EACH_PAGE_RECORD_NUM 15


#define BUTTON_NUMBER 5

#define BUTTON_START_TAG 1000
#define FIRST_BUTTON_TAG 1000
#define PREVIOUS_BUTTON_TAG 1001
#define NEXT_BUTTON_TAG 1002
#define LAST_BUTTON_TAG 1003
#define DELETE_BUTTON_TAG 1004

#define LEFT_ITEM_TAG 2000


@interface TalkingRecordViewController ()
<UIScrollViewDelegate,EmoViewDelegate,HPGrowingTextViewDelegate,UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,NSXMLParserDelegate, UINavigationControllerDelegate, UIAlertViewDelegate,NBNavigationControllerDelegate,QTVoiceMessageCellDelegate>
{
    CGRect m_frame;
    NSMutableArray *docArray;
    NSMutableArray *entityArray;
    NSDate *lastTime;
    SmileyParser *parser;
    NSFileManager *fileManager;
    NSUInteger m_pageIndex;
    
    NSUInteger m_totalPages;
    NSMutableArray * m_arrAllTableData;
    NSMutableArray * m_arrEachPageData;
    
    NSArray * m_arrEnableImage;
    NSArray * m_arrUnEnableImage;
    NSArray * m_arrPressImage;
    
    UIImageView * m_BGImageView;
    
    NSMutableArray * m_arrBtnEnabled;
    BOOL m_btnHadCreated;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    
    // 第一次装与聊天页数量相同的空数组
    BOOL m_canAddBankArr;
    
    NSMutableDictionary *friendTempDic;

    BOOL isPlay;
    NSIndexPath * selectVoiceButtonIndexPath;
}

@property (nonatomic, strong) NSMutableArray * m_arrAllTableData;
@property (nonatomic, strong) NSMutableArray * m_arrEachPageData;
@property (nonatomic, strong) NSArray * m_arrEnableImage;
@property (nonatomic, strong) NSArray * m_arrUnEnableImage;
@property (nonatomic, strong) NSArray * m_arrPressImage;
@property (nonatomic, strong) UIImageView * m_BGImageView;
@property (nonatomic, strong) NSMutableArray * m_arrBtnEnabled;


@property (nonatomic,strong) NSIndexPath * selectVoiceButtonIndexPath;


@end

@implementation TalkingRecordViewController

@synthesize m_delegate;
@synthesize inputJid;
@synthesize messageCount;
@synthesize inputObject;
@synthesize countAll;

@synthesize mainContent;


@synthesize m_arrAllTableData;
@synthesize m_arrEachPageData;

@synthesize m_arrEnableImage;
@synthesize m_arrUnEnableImage;
@synthesize m_arrPressImage;

@synthesize m_BGImageView;

@synthesize m_arrBtnEnabled;

@synthesize selectVoiceButtonIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initEnvironment
{
     withCount:
    [[MessageManager shareInstance] addListener:self];
    
    [self.m_arrEachPageData removeAllObjects];
    
    [entityArray removeAllObjects];
    
    [self initConversationHistory];
}

-(void)convMsgListChanged:(NSArray *)msgList
{
    [mainContent performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void) getConvMsgFinish:(NSArray *)msg_list withCountAll:(NSUInteger)count_all
{
    countAll = count_all;
    [self performSelectorOnMainThread:@selector(parseConversationHistory:) withObject:msg_list waitUntilDone:YES];
}


-(void) setHeadViewImage:(FriendInfo *)friend withImageView:(UIImageView *)imageView forObj:(MessageLayoutInfo *)mli
{
    if(friend)
    {
        [ImUtils drawRosterHeadPic:friend withView:imageView withOnline:NO] ;
    }else
    {
        imageView.layer.cornerRadius = 8.0f;
        imageView.layer.masksToBounds = YES;
        imageView.image = [UIImage imageNamed:@"identity_man_new.png"];
    }
}

- (void)createDeleteFailedAlertView:(ResultInfo *)result
{
    NSString * errorMsg = [NSString stringWithFormat:@"succeed == %d, errorCode == %d, errorMsg == %@", result.succeed, result.errorCode, result.errorMsg];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"删除失败" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

// history_dock_bg.png
- (void)viewDidLoad
{
    [super viewDidLoad];
    m_canAddBankArr = YES;
    
    inputJid  = [ImUtils getIdByObject:inputObject];

    friendTempDic = [NSMutableDictionary dictionary];
    
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    if (m_isIOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.m_arrAllTableData = [[NSMutableArray alloc] initWithCapacity:0];
    parser = [SmileyParser parser];

    fileManager = [[NSFileManager alloc] init];
    
    parser = [SmileyParser parser];
    entityArray = [NSMutableArray array];
    lastTime = [NSDate dateWithTimeIntervalSince1970:0];
    

    CGFloat y = 0.0f;
    CGFloat height = m_frame.size.height - 20 - 44 - 49;
    
    
    mainContent = [[UITableView alloc] initWithFrame:CGRectMake(0,y, m_frame.size.width, height) style:UITableViewStylePlain];

    [mainContent setSeparatorColor:[UIColor clearColor]];
    mainContent.backgroundColor = [UIColor colorWithRed:240.0f/ 255.0f green:240.0f/ 255.0f blue:240.0f/ 255.0f alpha:1.0f];
    mainContent.dataSource = self;
    mainContent.delegate = self;
    [self.view addSubview:mainContent];

    
    
    self.messageCount = 50;
    
    [self createBGImageView];
    [self createNavigationBar:YES withTitle:NSLocalizedString(@"conversationHistory", @"")];
    [self initEnvironment];
}
-(void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [[MessageManager shareInstance] leaveConversation];
    [self.navigationController popViewControllerAnimated:YES];
    if (isPlay) {
        [self clearCellAnimationAndPlayer];
    }
}

- (void)createNavigationBar:(BOOL)needCreate withTitle:(NSString *) title
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:title andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)createBGImageView
{
    CGFloat y = 0.0f;
    y = m_frame.size.height - 49 - 44 - 20;
    
    self.m_BGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width,49)];
    self.m_BGImageView.backgroundColor =[((NBNavigationController *)self.navigationController) getThemeBGColor];
    self.m_BGImageView.userInteractionEnabled = YES;
    self.m_BGImageView.clipsToBounds = YES;
    [self.view addSubview:self.m_BGImageView];
}

- (void)createView
{
    LOG_UI_INFO(@"创建翻页button");
    self.m_arrEnableImage = [NSArray arrayWithObjects:@"conv_his_first_nor.png", @"conv_his_pageup_nor.png", @"conv_his_pagedown_nor.png", @"conv_his_last_nor.png", @"conv_his_delete_nor.png", nil];
    self.m_arrPressImage = [NSArray arrayWithObjects:@"conv_his_first_pre.png", @"conv_his_pageup_pre.png", @"conv_his_pagedown_pre.png", @"conv_his_last_pre.png", @"conv_his_delete_pre.png", nil];
    self.m_arrUnEnableImage = [NSArray arrayWithObjects:@"conv_his_first_dis.png", @"conv_his_pageup_dis.png", @"conv_his_pagedown_dis.png", @"conv_his_last_dis.png",@"conv_his_delete_dis.png", nil];

    
    NSMutableArray * startImage = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * btnEnabled = [[NSMutableArray alloc] initWithCapacity:0];

    if (m_totalPages == 0) {
        [startImage addObjectsFromArray:self.m_arrUnEnableImage];
        for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
            [btnEnabled addObject:[NSNumber numberWithBool:NO]];
        }
    } else if (m_totalPages == 1) {
        [startImage addObjectsFromArray:self.m_arrUnEnableImage];
        [startImage replaceObjectAtIndex:BUTTON_NUMBER - 1 withObject:@"conv_his_delete_nor.png"];
        
        for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
            [btnEnabled addObject:[NSNumber numberWithBool:NO]];
        }
        [btnEnabled replaceObjectAtIndex:BUTTON_NUMBER - 1 withObject:[NSNumber numberWithBool:YES]];
    } else if (m_totalPages >= 2) {
        [startImage addObjectsFromArray:self.m_arrEnableImage];
        [startImage replaceObjectAtIndex:0 withObject:@"conv_his_first_dis.png"];
        [startImage replaceObjectAtIndex:1 withObject:@"conv_his_pageup_dis.png"];

        for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
            [btnEnabled addObject:[NSNumber numberWithBool:YES]];
        }
        [btnEnabled replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
        [btnEnabled replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
    }
    self.m_arrBtnEnabled = [NSMutableArray arrayWithArray:btnEnabled];
    
    CGFloat padding = (m_frame.size.width-150)/6;
    for (NSUInteger i = 0; i < 5; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[startImage objectAtIndex:i]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:[m_arrPressImage objectAtIndex:i]] forState:UIControlStateHighlighted];
        
        button.frame = CGRectMake(30 * i+padding*(i+1), 9.5, 30, 30);
        button.tag = BUTTON_START_TAG + i;
        BOOL enabled = [[btnEnabled objectAtIndex:i] boolValue];
        button.enabled = enabled;
        [button addTarget:self action:@selector(operationRemarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.m_BGImageView addSubview:button];
    }
    
    m_btnHadCreated = YES;
}

// button点击事件
- (void)operationRemarkButtonPressed:(UIButton *)button
{
    if (button.tag == FIRST_BUTTON_TAG) {
        m_pageIndex = 0;
    } else if (button.tag == PREVIOUS_BUTTON_TAG) {
        if (m_pageIndex > 0) {
            m_pageIndex--;
        }
    } else if (button.tag == NEXT_BUTTON_TAG) {
        m_pageIndex++;
        if (m_pageIndex >= m_totalPages - 1) {
            m_pageIndex = m_totalPages - 1;
        }
    } else if (button.tag == LAST_BUTTON_TAG) {
        m_pageIndex = m_totalPages - 1;
    } else if (button.tag == DELETE_BUTTON_TAG) {
        [self createDeleteConversationAlertView];
    }
    
    LOG_UI_INFO(@"button pressed m_pageIndex === %d", m_pageIndex);
    
    if (button.tag != DELETE_BUTTON_TAG) {
        if ([self.m_arrAllTableData count] > m_pageIndex && [[self.m_arrAllTableData objectAtIndex:m_pageIndex] count] > 0) {
            [entityArray removeAllObjects];
            entityArray = [NSMutableArray arrayWithArray:[self.m_arrAllTableData objectAtIndex:m_pageIndex]];
            LOG_UI_INFO(@"button pressed entityArray == %@, entityArray count == %d, entityArray address == %p", entityArray, [entityArray count], entityArray);

            [self showPageNum:countAll];
            [mainContent reloadData];
        } else {
            [self initConversationHistory];
        }
    }
    
}

-(void) initConversationHistory
{
    ConversationType type = [ImUtils getChatType:inputJid];
    if(type == SessionType_LightApp)
    {
        [[MessageManager shareInstance] getLightappMsg:inputJid withType:[ImUtils getChatType:inputJid] withBeginIndex:m_pageIndex * EACH_PAGE_RECORD_NUM withCount:EACH_PAGE_RECORD_NUM];
    }else{
        
        [[MessageManager shareInstance] getConversation:inputJid withType:[ImUtils getChatType:inputJid] withBeginIndex:m_pageIndex * EACH_PAGE_RECORD_NUM withCount:EACH_PAGE_RECORD_NUM];
    }
}

- (void)createDeleteConversationAlertView
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"删除记录" message:NSLocalizedString(@"delete_talk_history", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"action_cancel", nil) otherButtonTitles:NSLocalizedString(@"action_confirm", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteConverSationHistory];
    }
}

// 删除聊天记录
// -(void) deleteConversationHistory:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
- (void)deleteConverSationHistory
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteConverSationHistory" object:inputJid];
    
    [self clearUIWhenConversationHistoryIsNone];
    if ([ImUtils getChatType:inputJid] == SessionType_LightApp) {
        
        [[MessageManager shareInstance] deleteLightapp:inputJid callback:^(BOOL result) {
            
        }];
        
    }else
    {
        [[MessageManager shareInstance] deleteAllHistoryMessage:[ImUtils getChatType:inputJid] withjid:inputJid withListener:^(BOOL result) {
            
        }];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clearLastConversationForTalkSessionController
{
    [m_delegate clearLastConversation];
}

- (void)clearUIWhenConversationHistoryIsNone
{
    [self createNavigationBar:NO withTitle:NSLocalizedString(@"conversationHistory", @"")];
    NSMutableArray * imageArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
        [self.m_arrBtnEnabled replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
    
    imageArr = [NSMutableArray arrayWithArray:self.m_arrUnEnableImage];
    for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
        UIButton * btn = (UIButton *)[self.view viewWithTag:BUTTON_START_TAG + i];
        [btn setBackgroundImage:[UIImage imageNamed:[imageArr objectAtIndex:i]] forState:UIControlStateNormal];
        btn.enabled = [[self.m_arrBtnEnabled objectAtIndex:i] boolValue];
        LOG_UI_INFO(@"btnbtnbtnbtnbtn ==== %@", btn);
        LOG_UI_INFO(@"btnbtnbtnbtnbtn.enable ==== %d", btn.enabled);
    }
    
    [entityArray removeAllObjects];
    [mainContent reloadData];
}

-(void) reloadDatas
{
    LOG_UI_INFO(@"reloadData");
    [self showPageNum:countAll];
    LOG_UI_INFO(@"m_arrEachPageData in talking record viewcontroller == %@, counter == %d, m_arrEachPageData address == %p", self.m_arrEachPageData, [self.m_arrEachPageData count], self.m_arrEachPageData);

    NSMutableArray * array = [NSMutableArray arrayWithArray:self.m_arrEachPageData];
    
    LOG_UI_INFO(@"array in talking record viewcontroller == %@, array count == %d, array address == %p", array, [array count], array);

    if ([self.m_arrAllTableData count] > m_pageIndex) {
        [self.m_arrAllTableData replaceObjectAtIndex:m_pageIndex withObject:array];
    }
    
    LOG_UI_INFO(@"self.m_arrAllTableData  == %@, self.m_arrAllTableData count == %d self.m_arrAllTableData address == %p", self.m_arrAllTableData, [self.m_arrAllTableData count], self.m_arrAllTableData);
    
    entityArray = [NSMutableArray arrayWithArray:self.m_arrEachPageData];
    LOG_UI_INFO(@"entityArray == %@, entityArray count == %d, entityArray address == %p", entityArray, [entityArray count], entityArray);


    [mainContent reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[MessageManager shareInstance] leaveConversation];
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self changeSelfTitle:m_totalPages];
}

-(void) parseConversationHistory:(NSArray *)data
{
    [entityArray removeAllObjects];
    
    if([ImUtils getChatType:inputJid] == SessionType_LightApp)
    {
        for (LightAppMessageInfo *info in data) {
            if([info.lightappType isEqualToString:KEY_TEXT] && !info.attr_)
            {
                info.attr_ = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:[ImUtils flattenHTML:[parser pasrePushMessageToSmily:info.content] trimWhiteSpace:YES]];
                [info.attr_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                [info.attr_ setTextAlignment:kCTTextAlignmentNatural lineBreakMode:kCTLineBreakByCharWrapping];
                info.size_ = [info.attr_  sizeConstrainedToSize:CGSizeMake(kTextCellMAXWidth, CGFLOAT_MAX)];
            }if ([info.lightappType isEqualToString:KEY_IMAGE])
            {
                info.size_ = CGSizeMake(kImageCellWidth, kImageCellHeight);
            }if ([info.lightappType isEqualToString:KEY_NEWS])
            {
                info.size_ = CGSizeMake(240,info.articleCount==1? 262: [LightAppNewsCell getCellHeightWithCount:info.articleCount]);
            }
            [entityArray addObject:info];
        }
    }else
    {
        for (ConversationInfo *record in data) {
            
            if(record.msgInfo.isTxtMsg && !record.attr_)
            {
                record.attr_ = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:[ImUtils flattenHTML:[parser pasrePushMessageToSmily:record.msgInfo.txt] trimWhiteSpace:YES]];
                [record.attr_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                //            [mas setTextColor:[randomColors objectAtIndex:(idx%5)]];
                [record.attr_ setTextAlignment:kCTTextAlignmentNatural lineBreakMode:kCTLineBreakByCharWrapping];
                record.size_ = [record.attr_  sizeConstrainedToSize:CGSizeMake(kTextCellMAXWidth, CGFLOAT_MAX)];
            }else if (record.msgInfo.isImgMsg)
            {
                record.size_ = CGSizeMake(kImageCellWidth, kImageCellHeight);
            }
            [entityArray addObject:record];
        }
    }
    
    
    self.m_arrEachPageData = [NSMutableArray arrayWithArray:entityArray];
    [self reloadDatas];
}

- (void)showPageNum:(NSUInteger)talkCount
{
    NSUInteger totalPage = talkCount / EACH_PAGE_RECORD_NUM;
    NSUInteger remainingCount = talkCount % EACH_PAGE_RECORD_NUM;
    if (remainingCount > 0) {
        totalPage++;
    }
    m_totalPages = totalPage;
    LOG_UI_INFO(@"m_totalPagesm_totalPagesm_totalPagesm_totalPages == %d", m_totalPages);
    if (m_canAddBankArr) {
        m_canAddBankArr = NO;
        for (NSUInteger i = 0; i < m_totalPages; i++) {
            NSMutableArray * eachPageArr = [[NSMutableArray alloc] initWithCapacity:0];
            [self.m_arrAllTableData addObject:eachPageArr];
        }
        LOG_UI_INFO(@"all empty arr in self.m_arrAllTableData  == %@, self.m_arrAllTableData count == %d self.m_arrAllTableData address == %p", self.m_arrAllTableData, [self.m_arrAllTableData count], self.m_arrAllTableData);
    }
    if (!m_btnHadCreated) {
        [self createView];
    } else {
        [self changeButtonBGImage];
    }
    [self changeSelfTitle:totalPage];
}

- (void)changeSelfTitle:(NSUInteger)totalPageNum
{
    if (totalPageNum > 0) {
        [self createNavigationBar:NO withTitle:[NSString stringWithFormat:@"%@（%d/%d）",NSLocalizedString(@"conversationHistory", @""),m_pageIndex + 1, totalPageNum]];
    } else {
        [self createNavigationBar:NO withTitle:NSLocalizedString(@"conversationHistory", @"")];
    }
}

- (void)changeButtonBGImage
{
    LOG_UI_INFO(@"changeButtonBGImage changeButtonBGImage");
    NSMutableArray * imageArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
        [self.m_arrBtnEnabled replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
    }
    
    if (m_totalPages > 1) {
        if (m_pageIndex == 0) {
            imageArr = [NSMutableArray arrayWithArray:self.m_arrEnableImage];
            [imageArr replaceObjectAtIndex:0 withObject:@"conv_his_first_dis.png"];
            [imageArr replaceObjectAtIndex:1 withObject:@"conv_his_pageup_dis.png"];
            [self.m_arrBtnEnabled replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
            [self.m_arrBtnEnabled replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
        } else if (m_pageIndex == m_totalPages - 1) {
            imageArr = [NSMutableArray arrayWithArray:self.m_arrEnableImage];
            [imageArr replaceObjectAtIndex:2 withObject:@"conv_his_pagedown_dis.png"];
            [imageArr replaceObjectAtIndex:3 withObject:@"conv_his_last_dis.png"];
            [self.m_arrBtnEnabled replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
            [self.m_arrBtnEnabled replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
        } else if (0 < m_pageIndex && m_pageIndex < m_totalPages - 1) {
            imageArr = [NSMutableArray arrayWithArray:self.m_arrEnableImage];
        }
    } else {
        imageArr = [NSMutableArray arrayWithArray:self.m_arrUnEnableImage];
        if (countAll>0) {
            [imageArr replaceObjectAtIndex:4 withObject:@"conv_his_delete_nor.png"];
        }
        for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
            [self.m_arrBtnEnabled replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
        [self.m_arrBtnEnabled replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:YES]];
    }
 
   
    for (NSUInteger i = 0; i < BUTTON_NUMBER; i++) {
        UIButton * btn = (UIButton *)[self.view viewWithTag:BUTTON_START_TAG + i];
        [btn setBackgroundImage:[UIImage imageNamed:[imageArr objectAtIndex:i]] forState:UIControlStateNormal];
        btn.enabled = [[self.m_arrBtnEnabled objectAtIndex:i] boolValue];
    }
    
    LOG_UI_INFO(@"m_pageIndex m_pageIndex == %d", m_pageIndex + 1);
    LOG_UI_INFO(@"m_totalPages --- m_totalPages == %d", m_totalPages);
}

-(void) markAllMSgReaded
{
    switch ([ImUtils getChatType:inputJid]) {
        case SessionType_LightApp:
            [[MessageManager shareInstance] markLightMessageRead:inputJid type:[ImUtils getChatType:inputJid] withCallback:^(BOOL no) {
                
            }];
            break;
            
        default:
            [[BizlayerProxy shareInstance] markMessageRead:inputJid withType:[ConversationInfo getConvType:[ImUtils getChatType:inputJid]] withListener:^(NSDictionary *data)
             {
                 
             }];
            LOG_UI_INFO(@"markAllMSgReaded");
            break;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = [entityArray objectAtIndex:indexPath.row];
    if ([ImUtils getChatType:inputJid]==SessionType_LightApp) {
        LightAppMessageInfo * info = data;
        if([info.lightappType isEqualToString:KEY_TEXT])
        {
            return info.size_.height + 54    ;
        }else if ([info.lightappType isEqualToString:@"voice"])
        {
            return 80;
        }else if ([info.lightappType isEqualToString:KEY_IMAGE])
        {
            if(info.size_.height >0)
            {
                return info.size_.height+48;
            }
            return kImageCellHeight;
        }
        
        
        return 40;
    }
    
    ConversationInfo *convInfo = data;
    if(convInfo.msgInfo.isTxtMsg)
    {
        return convInfo.size_.height + 54    ;
    }else if (convInfo.msgInfo.isImgMsg)
    {
        if(convInfo.size_.height >0)
        {
            return convInfo.size_.height+48;
        }
        return kImageCellHeight;
    }else if (convInfo.msgInfo.isVoiceMsg)
    {
        return 80;
    }

    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseMessageInfo *bmi = [entityArray objectAtIndex:indexPath.row];
    if ([ImUtils getChatType:inputJid]==SessionType_LightApp) {
        LightAppMessageInfo * info = (LightAppMessageInfo *)bmi;
        LightAppInfo *li = inputObject;
        if([info.lightappType isEqualToString:KEY_TEXT])
        {
            if (info.isSend) {
                TalkToTextCell *cell=(TalkToTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToTextCell"];
                if(!cell)
                {
                    cell = [[TalkToTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToTextCell"];
//                    [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                FriendInfo *fi = info.lightappDetail?info.lightappDetail:[[RosterManager shareInstance] mySelf];
                [cell.headImageview setImageWithURL:[NSURL fileURLWithPath:fi.head] placeholderImage:[UIImage imageNamed:@"app_default.png"]];
                
                [cell setupCell:info.attr_ withSTDtime:info.ntime withSize:info.size_ withRowHeight:tableView.rowHeight];
                return cell;
            }else
            {
                TalkFromTextCell *cell=(TalkFromTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkFromTextCell"];
                if(!cell)
                {
                    cell = [[TalkFromTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkFromTextCell"];
//                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)]];
                }
                [cell.headImageView setImageWithURL:[NSURL fileURLWithPath:li.appIcon_middle] placeholderImage:[UIImage imageNamed:@"app_default.png"]];
                
                [cell setupCell:info.attr_ withSTDtime:info.ntime withSize:info.size_ withRowHeight:tableView.rowHeight];
                
                return cell;
            }
            
        }else if ([info.lightappType isEqualToString:KEY_NEWS])
        {
            if (info.articleCount==1) {
                TalkSingleNewsCell *cell=(TalkSingleNewsCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkSingleNewsCell"];
                if(!cell)
                {
                    cell = [[TalkSingleNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkSingleNewsCell"];
                    [self addTapGestureToNewsView:cell.background];
                }
                [cell setupCellWith:info];
                return cell;
            }else
            {
                LightAppNewsCell *cell=(LightAppNewsCell *)[tableView dequeueReusableCellWithIdentifier:@"LightAppNewsCell"];
                if(!cell)
                {
                    cell = [[LightAppNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LightAppNewsCell"];
                    [self addTapGestureToNewsView:cell.titleView];
                }
                
                [cell setUpCell:info];
                return cell;
            }
        }else if ([info.lightappType isEqualToString:@"voice"]){
            if (info.isSend) {
                QTRightVoiceMessageCell *cell=(QTRightVoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"QTRightVoiceMessageCell"];
                if(!cell)
                {
                    cell = [[QTRightVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QTRightVoiceMessageCell"];
//                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                FriendInfo *fi = info.lightappDetail?info.lightappDetail:[[RosterManager shareInstance] mySelf];
                [ImUtils setHeadViewImage:fi withImageView:cell.headImageView forJid:inputJid];
                [cell setCellDataDuration:info.voiceLength stdTime:info.ntime.longLongValue isPlay:YES];
                cell.delegate = self;
                [cell changeSubViews];
                return cell;
            }else{
                QTLeftVoiceMessageCell *cell=(QTLeftVoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"QTLeftVoiceMessageCell"];
                if(!cell)
                {
                    cell = [[QTLeftVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QTLeftVoiceMessageCell"];
//                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                [cell.headImageView setImageWithURL:[NSURL fileURLWithPath:li.appIcon_middle] placeholderImage:[UIImage imageNamed:@"app_default.png"]];
                [cell setCellDataDuration:info.voiceLength stdTime:info.ntime.longLongValue isPlay:YES];
                [cell changeSubViews];
                cell.delegate = self;
                
                return cell;
            }
        }else if ([info.lightappType isEqualToString:KEY_IMAGE])
        {
            TalkToImgCell *cell=(TalkToImgCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToImgCell"];
            if(!cell)
            {
                cell = [[TalkToImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToImgCell"];
//                [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)withRowNum:indexPath.row]];
                [self addTapGestureToView:cell.contentImg];
            }
            
            FriendInfo *fi = info.lightappDetail?info.lightappDetail:[[RosterManager shareInstance] mySelf];
            [ImUtils setHeadViewImage:fi withImageView:cell.headImageview forJid:inputJid];
            
            [cell setupLightCell:info withCallback:^{
                dispatch_block_t tableViewReloadBlock = ^{
                    NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                    NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
                    [mainContent reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                };
                dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
            }];
            return cell;
        }
        
    }
    
    // if (self.tableView.dragging == NO && self.tableView.decelerating == NO
    ConversationInfo *info = [entityArray objectAtIndex:indexPath.row];
    if (info.msgInfo.isTxtMsg) {
        
        if (info.isSend) {
            
            TalkToTextCell *cell=(TalkToTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToTextCell"];
            if(!cell)
            {
                cell = [[TalkToTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToTextCell"];
                [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)]];
                
            }
            
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageview forJid:inputJid];
            
            [cell setupCell:info.attr_ withSTDtime:[NSString stringWithFormat:@"%ld",info.msgInfo.stdtime] withSize:info.size_ withRowHeight:tableView.rowHeight];
            return cell;
        }else
        {
            TalkFromTextCell *cell=(TalkFromTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkFromTextCell"];
            if(!cell)
            {
                cell = [[TalkFromTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkFromTextCell"];
                [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)]];
            }
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
            
            [cell setupCell:info.attr_ withSTDtime:[NSString stringWithFormat:@"%ld",info.msgInfo.stdtime] withSize:info.size_ withRowHeight:tableView.rowHeight];
            
            return cell;
        }
        
    }else if (info.msgInfo.isImgMsg) {
        
        if(info.isSend)
        {
            TalkToImgCell *cell=(TalkToImgCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToImgCell"];
            if(!cell)
            {
                cell = [[TalkToImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToImgCell"];
                [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)]];
                [self addTapGestureToView:cell.contentImg];
            }
            
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageview forJid:inputJid];
            
            [cell setupCell:info withCallback:^{
                dispatch_block_t tableViewReloadBlock = ^{
                    NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                    NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
                    [mainContent reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
            }];
            return cell;
            
        }else
        {
            TalkFromImgCell *cell=(TalkFromImgCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkFromImgCell"];
            if(!cell)
            {
                cell = [[TalkFromImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkFromImgCell"];
                [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)]];
                [self addTapGestureToView:cell.contentImg];
            }
            
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
            
            [cell setupCell:info withCallback:^{
                dispatch_block_t tableViewReloadBlock = ^{
                    NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                    NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
                    [mainContent reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                
                dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
            }];
            
            return cell;
        }
        
        
    }else if (info.msgInfo.isVoiceMsg) {
        if (info.isSend) {
            QTRightVoiceMessageCell *cell=(QTRightVoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"QTRightVoiceMessageCell"];
            if(!cell)
            {
                cell = [[QTRightVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QTRightVoiceMessageCell"];
                [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)]];
            }
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
            [cell setCellDataDuration:info.msgInfo.duration stdTime:info.msgInfo.stdtime isPlay:info.msgInfo.isPlay];
            cell.delegate = self;
            [cell changeSubViews];
            return cell;
        }else{
            QTLeftVoiceMessageCell *cell=(QTLeftVoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"QTLeftVoiceMessageCell"];
            if(!cell)
            {
                cell = [[QTLeftVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QTLeftVoiceMessageCell"];
                [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)]];
            }
            [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
            cell.delegate = self;
            [cell setCellDataDuration:info.msgInfo.duration stdTime:info.msgInfo.stdtime isPlay:info.msgInfo.isPlay];
            [cell changeSubViews];
            return cell;
        }
    }
    return [[TalkFromTextCell alloc] init];
}


- (void)addTapGestureToNewsView:(UIView *)view {
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsView:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[view addGestureRecognizer:tapRecognizer];
}

-(void)showNewsView:(UITapGestureRecognizer *)gestureRecognizer// event:(UIEvent *)event
{
    CGPoint                     point                   = [gestureRecognizer locationInView:self.mainContent];
    NSIndexPath *               indexPath               = [mainContent indexPathForRowAtPoint:point];
    LightAppMessageInfo *       info                    = [entityArray objectAtIndex:indexPath.row];
    LightAppNewsMessageInfo *   news                    = [info.articles objectAtIndex:0];
    SVWebViewController *       controller              = [[SVWebViewController alloc] init];
    controller.URL                                      = [NSURL URLWithString:news.url];
    
    [self.navigationController pushViewController:controller animated:NO];
}

- (UIButton *)createFriendHeaderImageButtonWithFrame:(CGRect)frame
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    [button addTarget:self action:@selector(personImagebuttonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 好友头像点击事件
- (void)personImagebuttonPressed:(UIButton *)button event:(UIEvent *)event
{
    NSSet *set = [event allTouches];
    UITouch *touch = [set anyObject];
    CGPoint point = [touch locationInView:self.mainContent];
    NSIndexPath *indexPath = [mainContent indexPathForRowAtPoint:point];
    MessageLayoutInfo *mli =[entityArray objectAtIndex:indexPath.row];
    PersonCardViewController * cardViewController = [[PersonCardViewController alloc] init];
    cardViewController.hidesBottomBarWhenPushed = YES;
    FriendInfo *info =mli.extraInfo;
    cardViewController.m_jid = info.jid;
    
    [[RosterManager shareInstance] getRelationShip:cardViewController.m_jid WithCallback:^(enum FriendRelation relationShip) {
        BOOL isStranger = NO;
        if (relationShip == RelationStranger || relationShip == RelationNone) {
            isStranger = YES;
        } else if (relationShip == RelationContact) {
            isStranger = NO;
        }
        cardViewController.m_isStranger = isStranger;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:cardViewController animated:YES];
        });
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return entityArray.count;
}

-(void)dealloc
{
    [friendTempDic removeAllObjects];
    friendTempDic = nil;
    
}

- (void)addTapGestureToView:(UIView *)view {
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePreView:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[view addGestureRecognizer:tapRecognizer];
}

-(void)showImagePreView:(UITapGestureRecognizer *)gestureRecognizer// event:(UIEvent *)event
{
    CGPoint point = [gestureRecognizer locationInView:self.mainContent];
    NSIndexPath *indexPath = [mainContent indexPathForRowAtPoint:point];
    ConversationInfo *convInfo =[entityArray objectAtIndex:indexPath.row];
    
    PhotoPreviewController *controller =[[PhotoPreviewController alloc] init];
    
    if ([convInfo isKindOfClass:[ConversationInfo class]]) {
        controller.imagePath = [ImUtils getVacrdImagePath:convInfo.msgInfo.src];
    }else
    {
        LightAppMessageInfo *info = (LightAppMessageInfo *)convInfo;
        controller.imagePath = [ImUtils getVacrdImagePath:info.image];
    }
    
    
    [self.navigationController pushViewController:controller animated:NO];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - QTVoiceMessageCellDelegate -
-(void)voiceMessageButtonPressedAtCell:(id)cell
{
    if ([cell getSelected]) {
        if (isPlay) {
            [self clearCellAnimationAndPlayer];
        }
        selectVoiceButtonIndexPath = [mainContent indexPathForCell:cell];
        [cell setSelected:YES];
        [cell beganAnimation];

        ConversationInfo *info = [entityArray objectAtIndex:selectVoiceButtonIndexPath.row];
        NSString * voiceFile = info.msgInfo.src;
        isPlay = YES;
        [[amrEnDecodeManager sharedManager] startPlay:voiceFile];
    }else{
        [cell stopAnimation];
        [[amrEnDecodeManager sharedManager] stopPlay];
        isPlay = NO;
    }
}
-(void)clearCellAnimationAndPlayer
{
    id currentCell = [mainContent cellForRowAtIndexPath:selectVoiceButtonIndexPath];
    [currentCell stopAnimation];
    [[amrEnDecodeManager sharedManager] stopPlay];
    isPlay = NO;
}
@end
