//
//  PrivateTalkViewController.m
//  WhistleIm
//
//  Created by wangchao on 13-7-19.

//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PrivateTalkViewController.h"
#import "Whistle.h"
#import "Constants.h"
#import "EmoView.h"
#import "SmileyParser.h"
#import <QuartzCore/CALayer.h>
#import "HPGrowingTextView.h"
#import "ConversationInfo.h"
#import "TalkFromTextCell.h"
#import "TalkToTextCell.h"
#import "TalkFromImgCell.h"
#import "TalkToImgCell.h"
#import "RosterManager.h"
#import "JSONObjectHelper.h"
#import "ChatRecord.h"
#import "MessageLayoutInfo.h"
#import "MessageText.h"
#import "MBProgressHUD.h"
#import "MessageImage.h"
#import "PersonCardViewController.h"
#import "ChatPopViewController.h"
#import "ImUtils.h"
#import "TalkingRecordViewController.h"
#import "GetFrame.h"
#import "ConversationInfo.h"
#import "CrowdInfo.h"
#import "ChatGroupInfo.h"
#import "FriendInfo.h"
#import "AppMsgInfo.h"
#import "MessageManager.h"
#import "RecentAppMessageInfo.h"
#import "NetworkBrokenAlert.h"
#import "NSAttributedString+Attributes.h"
#import "NSString+Base64.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CrowdVoteViewController.h"
#import "LightAppMenuInfo.h"
#import "TalkSingleNewsCell.h"
#import "Toast.h"

#import "QTTalkHUD.h"
#import "QTVoicePanel.h"
#import "amrEnDecodeManager.h"
#import "QTLeftVoiceMessageCell.h"
#import "QTRightVoiceMessageCell.h"
#import "OHASBasicHTMLParser.h"

#import "NBNavigationController.h"
#import "CrowdVoteViewController.h"
#import "AppManager.h"

#import "LightAppInfo.h"
#import "LightAppNewsCell.h"
#import "LightAppMessageInfo.h"
#import "AddRostersViewController.h"
#import "GroupListViewController.h"
#import "ChatPopViewController.h"
#import "PhotoPreviewController.h"
#import "SVWebViewController.h"
#import "PersonalInfoViewController.h"

#define light_drop_tag 1024;
#define light_contant_tag 2048;

#define ADD_GROUP_MEMBERS_NONE @"addGroupMembersNone"
#define ADD_GROUP_MEMBERS_DEFAULT @"addGroupMembersDefault"
#define ADD_GROUP_MEMBERS_DEFAULT_STRANGER @"addGroupMembersDefaultStranger"
#define OTHER_CONVERSATION @"other_conversation"
#define HELLO_TEXT @"HELLO_TEXT"

@interface PrivateTalkViewController ()<QTVoicePanelDelegate,QTVoiceMessageCellDelegate,RecordSoundManagerDelegate,NBNavigationControllerDelegate>
{
    NSMutableArray *docArray;
    NSMutableArray *entityArray;
    NSDate *lastTime;
    SmileyParser *parser;
    Boolean isInited;
    UIView *testView;
    ConversationInfo * otherConversationInfo;
    NSInteger indexForCurrentPlay;
    BOOL isPlay;
}

@property (nonatomic,strong) UIView *lightApppanel;
@property (nonatomic,strong) UIButton *emoBtn;
@property (nonatomic,strong) UIButton *keyBordBtn;
@property (nonatomic,strong) NSMutableArray *popUpWindowArray;
@property (nonatomic,strong) UIImageView *inputImageView;
@property (nonatomic,strong) UIImageView *lightContantView;
@property (nonatomic,strong) UIImageView *lightDropView;
@property (nonatomic,strong) NSTimer *msgTimer;
@property (nonatomic,assign) int currentPopIndex;
@property (nonatomic,assign) BOOL interrupt;

@end

@implementation PrivateTalkViewController
{
    NSFileManager *fileManager;
    Boolean showOtherFlag;
    NSMutableDictionary *friendTempDic;
    NSInteger _callbackCount;
    
    NSDate *start;
   
    // 下一次请求允许标志位
    BOOL m_canRequestNext;
}

@synthesize groupType;
@synthesize operatePanel;
@synthesize lightApppanel;
@synthesize switchModeBtn;
@synthesize keyBordBtn;
@synthesize inputField;
@synthesize inputImageView;
@synthesize moreBtn;
@synthesize voiceBtn;
@synthesize popUpWindowArray;
@synthesize morePanel;
@synthesize mainContent;
@synthesize emoPanel;
@synthesize interrupt;
@synthesize emoBtn;
@synthesize currentPopIndex;
@synthesize popEmoWindow;
@synthesize inputJid;
@synthesize inputObject;
@synthesize countAll;
@synthesize otherMsgBtn;//他人提醒栏
@synthesize messageCount;
@synthesize voicePanel;
@synthesize lightContantView;
@synthesize lightDropView;

- (id)init
{
    self = [super init];
    
    if(self){

    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)clearLastConversation
{
    [entityArray removeAllObjects];
    [self reloadDatas];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_canRequestNext = YES;
    
    start = [NSDate date];
    
    NSLog(@"start time  long is %@",start);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initObject];
    
    [self  initView];
    
    [self obtainConversationHistory];
}

-(void) initObject
{
    self.messageStart                               = -1;//消息起始；
    
    self.messageCount                               = 30;
    
    inputJid                                        = [ImUtils getIdByObject:inputObject];

    friendTempDic                                   = [NSMutableDictionary dictionary];//friend 缓存
    
    showOtherFlag                                   = false;//是否展示他人提醒栏
    
    isInited                                        = false;//是否已经初始化完成
    
    self.picker                                     = [[UIImagePickerController alloc] init];//照片，相册
    
    self.picker.allowsEditing                       = NO;
    
    self.picker.delegate                            = self;
    
    fileManager                                     = [[NSFileManager alloc] init];
    
    self.navigationController.toolbarHidden = YES;
    
    parser                                          = [SmileyParser parser];//表情解析
    
    entityArray                                     = [NSMutableArray array];
    
    lastTime                                        = [NSDate dateWithTimeIntervalSince1970:0];//时间对比flag；
    
    [self registerManagerListener];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConverSationHistory:) name:@"deleteConverSationHistory" object:nil];
   
    [[MessageManager shareInstance] addListener:self];
    
    [[AppMessageManager shareInstance] addListener:self];
    
    [amrEnDecodeManager sharedManager].delegate = self;

}

-(void) getHelloText
{
    NSUserDefaults*     userDefault                   = [NSUserDefaults standardUserDefaults];
    NSString*           key                           = [NSString stringWithFormat:@"%@%@",[[RosterManager shareInstance] mySelf].jid,HELLO_TEXT];
    NSString*           UUID                          = [userDefault objectForKey:key];
    if(!UUID)
    {
        UUID                                          = [[NSUUID UUID] UUIDString];
        [userDefault setObject:UUID forKey:key];
    }
    
    
    [[MessageManager shareInstance] sendHelloMessage:inputJid withID:UUID];
}

-(void)initView
{
    mainContent = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-20-44-49) style:UITableViewStylePlain];

    mainContent = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-20-44-49) style:UITableViewStylePlain];
    
    mainContent.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
    
    [mainContent setSeparatorColor:[UIColor clearColor]];
    
    mainContent.dataSource = self;
    mainContent.delegate = self;
    
    UITapGestureRecognizer * recongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView)];
    
    recongnizer.cancelsTouchesInView = NO;
    
    [recongnizer setNumberOfTapsRequired:1];
    
    [recongnizer setNumberOfTouchesRequired:1];
    
    recongnizer.delegate = self;

    [mainContent addGestureRecognizer:recongnizer];
    
    otherMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    otherMsgBtn.frame =CGRectMake(0, 0,kScreenWidth, 35);
    
    [otherMsgBtn  setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:UIControlStateNormal];
    
    otherMsgBtn.titleLabel.font=[UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    
    otherMsgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    otherMsgBtn.contentEdgeInsets = UIEdgeInsetsMake(0,15, 0, 0);
    
    [otherMsgBtn setBackgroundColor:[UIColor whiteColor]];
    
    //    [mainContent addSubview:otherMsgBtn];
    [otherMsgBtn setHidden:YES];
    
    [self.view addSubview:mainContent];
    [self.view addSubview:otherMsgBtn];
    
    [self createNavigationBar:YES];

    [self initDocView];
    
    //下啦刷新
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0- mainContent.bounds.size.height, self.mainContent.frame.size.width, mainContent.bounds.size.height)];
        
        view1.delegate = self;
        
        [self.mainContent addSubview:view1];
        
        _refreshHeaderView = view1;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"more" andLeftTitle:[self getViewTitle] andRightTitle:nil andNeedCreateSubViews:needCreate];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL flag = ![touch.view isKindOfClass:[OHAttributedLabel class]];
    flag = ![touch.view isKindOfClass:[UIImageView class]];
    return flag;
}

-(void)deleteConverSationHistory:(NSNotification *) notification
{
    if([inputJid isEqualToString:[notification object]])
    {
        [entityArray removeAllObjects];
        [self performSelectorOnMainThread:@selector(clearLastConversation) withObject:nil waitUntilDone:YES];
    }
}
-(void) registerManagerListener
{
    if([ImUtils getChatType:inputJid]==SessionType_Discussion)
    {
        [[DiscussionManager shareInstance] addListener:self];
        
    }else if ([ImUtils getChatType:inputJid] ==SessionType_Crowd)
    {
        [[CrowdManager shareInstance] addListener:self];
    }
    
}

-(void)discussionListChanged:(NSArray *)discussionList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([ImUtils getChatType:inputJid ] == SessionType_Discussion)
        {
            ChatGroupInfo *tempInfo = inputObject;
            for (ChatGroupInfo *info in discussionList) {
                if([tempInfo.sessionId isEqualToString:info.sessionId])
                {
                    inputObject = info;
                    [self createNavigationBar:NO];
                }
            }
        }
        
    });
}

-(void)discussionBeDistroy:(ChatGroupInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([info.sessionId isEqualToString:inputJid])
        {
             [[[CustomAlertView alloc] initWithTitle:@"提示" message:@"该讨论组不存在请退出" delegate:self cancelButtonTitle:@"退出" confrimButtonTitle:nil] show];
        }
    });
    
}

/**
 *  群被解散后的通知
 *
 *  @param info 被解散群的对象
 */
- (void) crowdBeDismiss:(CrowdInfo*) info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[CustomAlertView alloc] initWithTitle:@"提示" message:@"你已经不在这个群中或该群被解散，点击确认退出聊天页面" delegate:self cancelButtonTitle:@"确认" confrimButtonTitle:nil] show];
    });
}

/**
 *  群被冻结
 *
 *  @param info 被冻结群的对象
 */
- (void) crowdBeFrozen:(CrowdInfo*) info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你已经不在这个群中或该群被解散，点击确认退出聊天页面" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if([ImUtils getChatType:inputJid]==SessionType_Discussion)
            {
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if ([ImUtils getChatType:inputJid] ==SessionType_Crowd)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self  hideEmoWindow];
    if([ImUtils getChatType:inputJid] == SessionType_AppMsg)
    {
        mainContent.frame = CGRectMake(0,0, kScreenWidth, kScreenHeight-20-44);
    }else
    {
        operatePanel.frame = CGRectMake(0,kScreenHeight-20-44-operatePanel.frame.size.height , kScreenWidth, operatePanel.frame.size.height);
        mainContent.frame = CGRectMake(0,0, kScreenWidth, kScreenHeight-20-44-operatePanel.frame.size.height);
    }
    [self hidePanel];
    
    [super viewWillDisappear:animated];
}

-(void) initDocView
{

    if ([ImUtils getChatType:inputJid] == SessionType_LightApp)
    {
        [self initLightAppDocView];
    }else
    {
        [self initConversationDocView];
    }
    [self registerKeybordChangedListener];
    
}
-(void)initLightAppDocButton
{
    LightAppInfo        * lai  =inputObject;
    popUpWindowArray = [NSMutableArray array];
    currentPopIndex = -1;
    NSArray *menus = lai.menus;
    if (!menus || menus.count==0) {
        lightApppanel.hidden = YES;
        operatePanel.hidden=NO;
    }else
    {
        CGFloat width = (kScreenWidth-51)/menus.count;
        
        for (int i=0; i<menus.count; i++) {
            [self createLightDocButton:[menus objectAtIndex:i] withIndex:i width:width];
        }
    }
    
}


-(void)createLightDocButton:(LightAppMenuInfo *)menuInfo withIndex:(int) index width:(CGFloat) width
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(51+width*index, 0, width, 49);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:menuInfo.name forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    [button setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15]];
    [lightApppanel addSubview:button];
    button.tag = index;
    if(menuInfo.subButton.count>0)
    {
        [button addTarget:self action:@selector(showPopUp:) forControlEvents:UIControlEventTouchUpInside];

    }else{
        [button addTarget:self action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}
//lightapp_sub_indicator
-(UIView *)createLightPopButton:(LightAppMenuInfo *)menuInfo withIndex:(int) index width:(CGFloat) width
{
    CGFloat startx = 51;
    CGFloat h = 5+44*menuInfo.subButton.count+4+menuInfo.subButton.count+1;
    lightContantView = [[UIImageView alloc] initWithFrame:CGRectMake(startx+width*index,kScreenHeight-20-44-49-5-h, width,h)];
    
    lightContantView.image = [ImUtils getFullBackgroundImageView:@"lightapp_sub_bg"WithCapInsets:UIEdgeInsetsMake(12,12,12,12) hLeftCapWidth:12 topCapHeight:12];
    lightContantView.tag =light_contant_tag;
    lightContantView.userInteractionEnabled = YES;
    [lightContantView setHidden:YES];
    
    lightDropView =  [[UIImageView alloc] initWithFrame:CGRectMake(startx+width*index+width/2,kScreenHeight-20-44-49-8,8,6)];//startx+width*index+width/2*(index+1)  kScreenHeight-20-44-49-6
    lightDropView.image = [UIImage imageNamed:@"lightapp_sub_ind"];
    lightDropView.tag = light_drop_tag;
    [lightDropView setHidden:YES];
    
    [self addContentBtn:lightContantView LightAppMenuInfo:menuInfo withIndex:index width:width];
    
    [self.view addSubview:lightContantView];
    [self.view addSubview:lightDropView];
    
    return lightContantView;
}

-(void) addContentBtn:(UIImageView *) imageView LightAppMenuInfo:(LightAppMenuInfo *)menuInfo withIndex:(int) index width:(CGFloat) width
{
    for (UIView *view in imageView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat startx = 51;
    
    CGFloat centerx  = startx+width*index+width/2*(index+1);
    
    CGFloat h = 5+44*menuInfo.subButton.count+4+menuInfo.subButton.count+1;
    lightDropView.center = CGPointMake(startx+width*index+width/2,lightDropView.center.y);
    CGFloat maxWidth = width;
    for(LightAppMenuInfo *info in menuInfo.subButton)
    {
        CGFloat w= [info.name sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:13]].width+50+7;
        maxWidth = w>maxWidth?w :maxWidth;
    }
    
    UIImage * imgHighlight= [ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#CCCCCC"]];
    UIImage * imgNor= [ImUtils createImageWithColor:[UIColor clearColor]];
    for (int i = 0 ; i< menuInfo.subButton.count; i++) {
        LightAppMenuInfo *info = [menuInfo.subButton objectAtIndex:i];
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(2,1+44*i+1+4*i,maxWidth-4,42);
        
        [btn setTitle:info.name forState:UIControlStateNormal];
        [btn setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:13]];
        [btn setBackgroundImage:imgNor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:imgHighlight forState:UIControlStateHighlighted];
        btn.layer.cornerRadius = 8.0f;
        btn.layer.masksToBounds = YES;
        btn.tag = (index+1)*10+i;
        [lightContantView addSubview:btn];
        if (i!=menuInfo.subButton.count-1) {
            UIView *spView =  [[UIView alloc] initWithFrame:CGRectMake(4,btn.frame.size.height+5, maxWidth-8,1)];
            spView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
            [lightContantView addSubview:spView];
        }
    }
    
    startx = centerx - maxWidth/2<0?5: centerx - maxWidth/2;
    startx = centerx + maxWidth/2 >kScreenWidth? kScreenWidth - maxWidth-5 :startx;

    lightContantView.frame = CGRectMake(startx, lightContantView.frame.origin.y, maxWidth,h);
}

-(IBAction)showPopUp:(id)sender
{
    UIButton *btn = sender;
    LightAppInfo        * lai  = inputObject;
    LightAppMenuInfo * menuInfo = [lai.menus objectAtIndex:btn.tag];
    if (currentPopIndex != btn.tag) {
        [lightContantView setHidden:YES];
        [lightDropView setHidden:YES];
        currentPopIndex = btn.tag;
    }
    
    CGFloat width = (kScreenWidth-51)/lai.menus.count;
    
    if (lightContantView == nil) {
        [self createLightPopButton:menuInfo withIndex:btn.tag width:width];
    }else
    {
        [self addContentBtn:lightContantView LightAppMenuInfo:menuInfo withIndex:btn.tag width:width];
    }
    
    [lightContantView setHidden:!lightContantView.isHidden];
    [lightDropView setHidden:!lightDropView.isHidden];
    
}


-(IBAction)lightButtonClick:(id)sender
{
    UIButton *btn = sender;
    
    LightAppMenuInfo * menuInfo = [self getLightAppMenuInfoByButton:btn];
    
    if([menuInfo.type isEqualToString:@"click"])
    {
        [[MessageManager shareInstance] sendLightAppMessage:inputJid event:menuInfo.type eventKey:menuInfo.key];
    }else if([menuInfo.type isEqualToString:@"view"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuInfo.url]];
    }
}
-(LightAppMenuInfo *) getLightAppMenuInfoByButton:(UIButton *)button
{
    LightAppInfo        * lai  = inputObject;
    if (button.tag>9) {
         LightAppMenuInfo * temp = [lai.menus objectAtIndex:button.tag/10-1];
        return [temp.subButton objectAtIndex:button.tag%10];
    }else
    {
        return [lai.menus objectAtIndex:button.tag];
    }
}

-(void)initLightAppDocView
{
    lightApppanel = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight-20-44-49 , kScreenWidth,49)];
    lightApppanel.backgroundColor = [((NBNavigationController *)self.navigationController) getThemeBGColor];
    [self.view addSubview:lightApppanel];
    
    UIButton * switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(15,14, 21, 21);
    [switchBtn addTarget:self action:@selector(lightKeyBordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [switchBtn setImage:[UIImage imageNamed:@"keybord_qt.png"] forState:UIControlStateNormal];
    
    [lightApppanel addSubview:switchBtn];
    
    [self initConversationDocView];
    
    [operatePanel setHidden:YES];
    inputField.frame = CGRectMake(85, 8,150, 33);
    inputImageView.frame = CGRectMake(85, 8,150, 33);
    
    
    voiceBtn.frame = CGRectMake(45, 9.5, 30, 30);
    keyBordBtn.frame = CGRectMake(45, 9.5, 30, 30);
    
    UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lightBtn.frame = CGRectMake(10,9.5, 29.5,29.5);
    [lightBtn addTarget:self action:@selector(lightSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [lightBtn setImage:[UIImage imageNamed:@"talk_dock_light_swith.png"] forState:UIControlStateNormal];
    [lightBtn setImage:[UIImage imageNamed:@"talk_dock_light_swith_pre.png"] forState:UIControlStateHighlighted];
    
    [operatePanel addSubview:lightBtn];
    
    [[AppManager shareInstance] getAppDetailInfoByAppid:inputJid callback:^(BaseAppInfo *baseInfo, BOOL result) {
        inputObject = baseInfo;
    }];
    
    [self setUpLightBtn];
}

-(void) setUpLightBtn
{
    LightAppInfo * info = inputObject;
    if (!info.menus) {
        [[AppManager shareInstance] getAppDetailInfoByAppid:inputJid callback:^(BaseAppInfo *baseInfo, BOOL result) {
            inputObject = baseInfo;
            [self performSelectorOnMainThread:@selector(initLightAppDocButton) withObject:nil waitUntilDone:YES];
        }];
    }
    [self initLightAppDocButton];
}

-(IBAction)lightKeyBordSwitch:(id)sender
{
    [operatePanel setHidden:!operatePanel.isHidden];
    [lightApppanel setHidden:!lightApppanel.isHidden];
    [self hidePanel];
}

-(void)initConversationDocView
{
    //  底边操作栏
    operatePanel                        = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-49 , kScreenWidth,49)];
    
    moreBtn                             = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame                       = CGRectMake(kScreenWidth-40,9.5, 30, 30);
    
    [moreBtn                            addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn                            setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
    [moreBtn                            setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
    
    //morePanel 弹出的操作界面
    morePanel                           = [[UIView alloc] initWithFrame:CGRectMake(0,kScreenHeight - 22 - 44,kScreenWidth,216)];
    morePanel.backgroundColor           = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    
    [self.view                          addSubview:morePanel];
    [morePanel                          setHidden:YES];
    
    inputField                          = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(51, 8, 184, 33)];
    
    //语音按钮
    voiceBtn                            = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.frame                      = CGRectMake(10, 9.5, 30, 30);
    
    [voiceBtn                           setImage:[UIImage imageNamed:@"talk_dock_voice.png"] forState:UIControlStateNormal];
    [voiceBtn                           setImage:[UIImage imageNamed:@"talk_dock_voice_pre.png"] forState:UIControlStateHighlighted];
    [voiceBtn                           addTarget:self action:@selector(showVoicePanel) forControlEvents:UIControlEventTouchUpInside];
    [operatePanel addSubview:voiceBtn];
    
    voicePanel                          = [[QTVoicePanel alloc]initWithFrame:CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216)];
    voicePanel.hidden                   = YES;
    voicePanel.delegate                 = self;
    [self.view                          addSubview:voicePanel];
    
    //输入框
    inputField.font                     =[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    
    inputField.isScrollable             = NO;
    
    inputField.contentInset             = UIEdgeInsetsMake(0, 5, 0, 5);
    
	inputField.minNumberOfLines         = 1;
    
	inputField.maxNumberOfLines         = 4;
    
	inputField.returnKeyType            = UIReturnKeySend; //just as an example
    
	inputField.delegate                 = self;
    
    inputField.internalTextView.scrollIndicatorInsets   = UIEdgeInsetsMake(0, 0, 0, 0);
    inputField.enablesReturnKeyAutomatically            =YES;
    
    inputField.backgroundColor          =[UIColor clearColor];
    
    inputField.autoresizingMask         = UIViewAutoresizingFlexibleWidth;
    
    inputField.layer.cornerRadius       = 15;
    
    inputImageView                      = [[UIImageView alloc] initWithImage: [ImUtils getFullBackgroundImageView:@"talk_et_new" WithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14) hLeftCapWidth:14 topCapHeight:14]];
    
    
    
    inputImageView.frame                = CGRectMake(51, 8,184,33);
    
    inputImageView.autoresizingMask     = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIButton *imgBtn                    = [[UIButton alloc] initWithFrame:CGRectMake(20,20, 55, 55)];
    [imgBtn setImage:[UIImage imageNamed:@"talk_dock_img.png"] forState:UIControlStateNormal];
    [imgBtn addTarget:self action:@selector(selectPictureFromAlbum) forControlEvents:UIControlEventTouchUpInside];
    UILabel *imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [imgLabel setFont:[UIFont systemFontOfSize:12]];
    imgLabel.backgroundColor = [UIColor clearColor];
    [imgLabel setTextAlignment:NSTextAlignmentCenter];
    [imgLabel setText:NSLocalizedString(@"picture",@"")];
    [imgLabel setTextColor:[ImUtils colorWithHexString:@"#808080"]];
    [imgLabel sizeToFit];
    imgLabel.center = CGPointMake(imgBtn.center.x, imgBtn.center.y+32.5+imgLabel.frame.size.height/2);
    
    emoBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-75,9.5, 30, 30)];
    [emoBtn setImage:[UIImage imageNamed:@"talk_dock_emo.png"] forState:UIControlStateNormal];
    [emoBtn setImage:[UIImage imageNamed:@"talk_dock_emo_pre.png"] forState:UIControlStateHighlighted];
    [emoBtn addTarget:self action:@selector(showEmoWindow) forControlEvents:UIControlEventTouchUpInside];
    
    //keybord_qt.png
    UIButton *caremaBtn = [[UIButton alloc] initWithFrame:CGRectMake(95,20,55,55)];//拍照
    [caremaBtn setImage:[UIImage imageNamed:@"talk_dock_camera.png"] forState:UIControlStateNormal];
    [caremaBtn addTarget:self action:@selector(selectPictureFromCamer) forControlEvents:UIControlEventTouchUpInside];
    UILabel *caremaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [caremaLabel setFont:[UIFont systemFontOfSize:12]];
    caremaLabel.backgroundColor = [UIColor clearColor];
    [caremaLabel setTextAlignment:NSTextAlignmentCenter];
    [caremaLabel setText:NSLocalizedString(@"Photograph",@"")];
    [caremaLabel setTextColor:[ImUtils colorWithHexString:@"#808080"]];
    [caremaLabel sizeToFit];
    caremaLabel.center = CGPointMake(caremaBtn.center.x, caremaBtn.center.y+32.5+caremaLabel.frame.size.height/2);
    [morePanel addSubview:imgBtn];
    [morePanel addSubview:imgLabel];
    [morePanel addSubview:caremaBtn];
    [morePanel addSubview:caremaLabel];
    
    //keybord_qt.png
    keyBordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    keyBordBtn.frame = CGRectMake(10, 9.5, 30, 30);
    [keyBordBtn addTarget:self action:@selector(keybordSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [keyBordBtn setImage:[UIImage imageNamed:@"keybord_qt.png"] forState:UIControlStateNormal];
    [keyBordBtn setHidden:YES];
    
    switchModeBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    moreBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    voiceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    //temp version
    imgBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    emoBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [operatePanel addSubview:inputImageView];
    [operatePanel addSubview:inputField];
    [operatePanel addSubview:moreBtn];
    [operatePanel addSubview:emoBtn];
    [operatePanel addSubview:keyBordBtn];
    
    operatePanel.backgroundColor = [((NBNavigationController *)self.navigationController) getThemeBGColor];
    operatePanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:operatePanel];
}

-(void)initEmoPanel
{
    //Emotion
    emoPanel = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-20-44, kScreenWidth, 216)];
    [emoPanel setHidden:YES];
    emoPanel.backgroundColor=[UIColor whiteColor];
    
    int page =parser.defArray.count%emoSinglePageNum == 0?parser.defArray.count/emoSinglePageNum:parser.defArray.count/emoSinglePageNum+1;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 197)];
    scrollView.contentSize = CGSizeMake(kScreenWidth*page, 197);
    
    docArray = [NSMutableArray arrayWithCapacity:page];
    
    UIView *docView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2-(6*page+5*(page-1))/2,197,6*page+5*(page-1), 6)];
    
    
    for (int i=0; i<page; i++) {
        EmoView *emoView = [[EmoView alloc] initWithFrame:CGRectMake(i*kScreenWidth,10, kScreenWidth, 187)];
        emoView.delegate = self;
        emoView.backgroundColor =[UIColor clearColor];
        
        NSMutableArray *data = [NSMutableArray arrayWithArray:[parser.defArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i*emoSinglePageNum, i*emoSinglePageNum+emoSinglePageNum>parser.defArray.count?(parser.defArray.count-i*emoSinglePageNum):emoSinglePageNum)]]];
        SmileyInfo *delinfo = [[SmileyInfo alloc] init];
        delinfo.smiley = @"";
        delinfo.pushText =@"";
        delinfo.resName =@"talk_emo_delete_nor.png";
        delinfo.resName_press =@"talk_emo_delete_pre";
        [data addObject:delinfo];
        
        SmileyInfo *sendinfo = [[SmileyInfo alloc] init];
        sendinfo.smiley = @"";
        sendinfo.pushText =@"";
        sendinfo.resName =@"talk_emo_send_nor.png";
        sendinfo.resName_press =@"talk_emo_send_pre";
        [data addObject:sendinfo];
        
        [emoView loadEmoViewfromData:data numColumns:7 size:CGSizeMake(42,42)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(6+5), 0, 6, 6);
        [button setImage:[UIImage imageNamed:@"talk_emotion_indicator.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"talk_emotion_indicator_current.png"] forState:UIControlStateSelected];
        [docView addSubview:button];
        [docArray addObject:button];
        [scrollView addSubview:emoView];
    }
    
    UIButton *curBtn = [docArray objectAtIndex:scrollView.contentOffset.x/kScreenWidth];
    curBtn.selected = YES;
    
    scrollView.pagingEnabled= true;
    scrollView.delegate = self;
    [scrollView setShowsHorizontalScrollIndicator:NO];
    
    //docs
    
    
    [emoPanel addSubview:scrollView];
    [emoPanel addSubview:docView];
    [self.view addSubview:morePanel];
    
    
    [self.view addSubview:emoPanel];
    
    //popupwindows;
    popEmoWindow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300, 83, 94)];
    
    popEmoWindow.image = [UIImage imageNamed:@"talk_emo_popup"];
    UIImageView *emoImg = [[UIImageView alloc] initWithFrame:CGRectMake(28, 21, 27, 27)];
    emoImg.tag=0;
    UILabel *emoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,53, 83, 10)];
    emoLabel.tag =1;
    emoLabel.font = [UIFont systemFontOfSize:9];
    emoLabel.textColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:1];
    emoLabel.shadowColor = [UIColor whiteColor];
    emoLabel.shadowOffset = CGSizeMake(0, 1);
    emoLabel.backgroundColor = [UIColor clearColor];
    emoLabel.textAlignment = NSTextAlignmentCenter;
    emoLabel.text = @"";
    
    [popEmoWindow addSubview:emoImg];
    [popEmoWindow addSubview:emoLabel];
    [popEmoWindow setHidden:YES];
    [self.view addSubview:popEmoWindow];
}


-(void) setViewTitle:(NSString *)title
{
     [self setTitle:title];
}
-(NSString *) getViewTitle
{
    ConversationType type = [ImUtils getChatType:inputJid];
    
    
    if(type == SessionType_Conversation)
    {
        if(inputObject)
        {
            FriendInfo * info =  inputObject;
            return info.showName;
        }else
        {
            __weak PrivateTalkViewController *controller = self;
            [[RosterManager shareInstance] getFriendInfoByJid:inputJid checkStrange:NO WithCallback:^(FriendInfo *friendInfo){
                [controller performSelectorOnMainThread:@selector(createNavigationBar:) withObject:NO waitUntilDone:YES];
            }];
        }
    }else if (type == SessionType_Crowd)
    {
        CrowdInfo * info =  inputObject;
        return info.name;
    }else if (type == SessionType_Discussion)
    {
        ChatGroupInfo *info = inputObject;
        return info.groupName;
    }else if (type == SessionType_LightApp)
    {
        LightAppInfo * lai =inputObject;
        return lai?lai.appName:@"轻应用";

    }
    return @"";
}

-(void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [   self                                popToCorrespondingViewController];
    
    [   [MessageManager shareInstance]      leaveConversation];
    
    if (isPlay) {
        
    [   self                                clearCellAnimationAndPlayer];
        
    }
}

- (void)popToCorrespondingViewController
{
    if (!self.groupType) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSArray * controllerArr = self.navigationController.viewControllers;
    if ([self.groupType isEqualToString:OTHER_CONVERSATION]) {
        [self.navigationController popToViewController:[controllerArr objectAtIndex:controllerArr.count-3] animated:YES];
    }
    
    for (UIViewController * controller in controllerArr) {
        if ([self.groupType isEqualToString:ADD_GROUP_MEMBERS_NONE]) {
            if ([controller isKindOfClass:[GroupListViewController class]]) {
                GroupListViewController * groupListVC = (GroupListViewController *)controller;
                [self.navigationController popToViewController:groupListVC animated:YES];
                break;
                NSLog(@"had GroupListViewController");
                NSLog(@"self.navigationController in add member controller == %@", self.navigationController);
                
            } else if ([controller isKindOfClass:[AddRostersViewController class]]) {
                AddRostersViewController * addRostersVC = (AddRostersViewController *)controller;
                [self.navigationController popToViewController:addRostersVC animated:YES];
                break;
                NSLog(@"had AddRostersViewController");
                NSLog(@"self.navigationController in add member controller == %@", self.navigationController);
            }
        } else if ([self.groupType isEqualToString:ADD_GROUP_MEMBERS_DEFAULT_STRANGER] || [self.groupType isEqualToString:ADD_GROUP_MEMBERS_DEFAULT]) {
            if ([controller isKindOfClass:[ChatPopViewController class]]) {
                ChatPopViewController * chatPopVC = (ChatPopViewController *)controller;
                [self.navigationController popToViewController:chatPopVC animated:YES];
                break;
                NSLog(@"had ChatPopViewController");
                NSLog(@"self.navigationController in add member controller == %@", self.navigationController);
            }
        }
    }
}

-(void)rightNavigationBarButtonPressed:(UIButton *)button
{
    ChatPopViewController *pop = [[ChatPopViewController alloc] init];
    pop.hidesBottomBarWhenPushed = YES;
    pop.uintInfo = self.inputObject;
    [self.navigationController pushViewController:pop animated:YES];
    if (isPlay) {
        [self clearCellAnimationAndPlayer];
    }
}

-(IBAction)lightSwitch:(id)sender
{
    [operatePanel setHidden:!operatePanel.isHidden];
    [lightApppanel setHidden:!lightApppanel.isHidden];
    [self hidePanel];
}

-(IBAction)keybordSwitch:(id)sender
{
    [voiceBtn setHidden:NO];
    [keyBordBtn setHidden:YES];
    [self hidePanel];
    [inputField becomeFirstResponder];
}

-(void) tapTableView
{
    [inputField resignFirstResponder];
    [self hideEmoWindow];
    operatePanel.frame = CGRectMake(0,kScreenHeight-20-44-operatePanel.frame.size.height , kScreenWidth, operatePanel.frame.size.height);
    mainContent.frame = CGRectMake(0,0, kScreenWidth, kScreenHeight-20-44-operatePanel.frame.size.height);
    morePanel.frame = CGRectMake(10,kScreenHeight-20-44,320,216);
    voicePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
    morePanel.hidden = YES;
    voicePanel.hidden = YES;
    voiceBtn.hidden = NO;
    keyBordBtn.hidden=YES;
    
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
    
    [lightContantView setHidden:YES];
    [lightDropView setHidden:YES];
   // morePanel.frame = CGRectMake(10,kScreenHeight-20-44-50-51,89,48);
}

-(void) reloadDatas
{
    [mainContent reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    interrupt = NO;
    
    [self createNavigationBar:NO];
    
//    operatePanel.frame =CGRectMake(0,kScreenHeight-20-44- operatePanel.frame.size.height , kScreenWidth, operatePanel.frame.size.height);
    m_canRequestNext = YES;
}

-(void) scrollToBottom:(Boolean) animed;
{
    if (mainContent.contentSize.height > mainContent.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, mainContent.contentSize.height - mainContent.frame.size.height);
        [self.mainContent setContentOffset:offset animated:animed];
    }
    
}

//---------------------- MessageManager ----------------------

-(void)convMsgListChanged:(NSArray *)msgList
{
    [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:YES];
}

-(void)newMsgUpdate:(NSArray *)msg
{
//    BOOL scroll = msg.count>entityArray.count;
    BaseMessageInfo *info = msg.lastObject;
    if ([info.jid isEqualToString:inputJid] || [info.jid hasPrefix:inputJid]) {
        [self performSelectorOnMainThread:@selector(parseConversationHistory:) withObject:msg waitUntilDone:YES];
        
        if (info.isSend|| mainContent.contentSize.height - mainContent.contentOffset.y<= mainContent.frame.size.height +[self getLastCellHeight]+54) {
            [self scrollToBottom:YES];
        }
        [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:YES];
    }else
    {
        if(![@"lightapp_msg" isEqualToString:info.messageType])
        {
            [self performSelectorOnMainThread:@selector(showOtherMsg:) withObject:info waitUntilDone:YES];
        }
        
    }
    
}

-(NSInteger) getLastCellHeight
{
    if([ImUtils getChatType:inputJid] == SessionType_LightApp)
    {
        LightAppMessageInfo *info  = entityArray.lastObject;
        return info.size_.height>340?info.size_.height:340;
    }else
    {
        ConversationInfo *info  = entityArray.lastObject;
        return info.size_.height>340?info.size_.height:340;
    }
}

-(void)oneMsgChanged:(BaseMessageInfo *)msg
{
    [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:YES];
}

- (void) getConvMsgFinish:(NSArray *)msg_list withCountAll:(NSUInteger)count_all{
    countAll = count_all;
    if(isInited && !_reloading)
    {
        return;
    }
    isInited = true;
//    NSLog(@"getConvMsgFinish  long is %f",[NSDate da])
    
    NSLog(@"getConvMsgFinish  long is %f",[[NSDate date] timeIntervalSinceDate:start]);
    
    if (_reloading) {
      
        [self performSelectorOnMainThread:@selector(obtainReflashDate:) withObject:msg_list waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
    }else
    {
        [self performSelectorOnMainThread:@selector(parseConversationHistory:) withObject:msg_list waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(scrollToBottom:) withObject:NO waitUntilDone:YES];
    }
}

-(void) obtainReflashDate:(NSArray *)msg_list
{
    [entityArray removeAllObjects];
    [self parseConversationHistory:msg_list];
}

- (void) getConvMsgFailure
{
    LOG_UI_INFO(@"initConversationHistory failed");
}

- (void) msgItemUpdate:(ConversationInfo*) msg
{
    if(msg)
    {
        if([msg.jid isEqualToString:inputJid])
        {

        }else{
            [self performSelectorOnMainThread:@selector(showOtherMsg:) withObject:msg waitUntilDone:NO];
        }
    }
}
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self sendMessage:nil];
//    inputField.frame =CGRectMake(moreBtn.frame.origin.x+37
//                                 , 7,187, 36);
    return NO;
}

-(void) obtainConversationHistory
{
    ConversationType type = [ImUtils getChatType:inputJid];
    if(type == SessionType_LightApp)
    {
        [self getHelloText];
        [[MessageManager shareInstance] getLightappMsg:inputJid withType:type withBeginIndex:-1 withCount:messageCount];
    }else{
         NSLog(@"obtainConversationHistory  long is %f",[[NSDate date] timeIntervalSinceDate:start]);
        if (self.myDevice) {
            [[MessageManager shareInstance] getConversation:self.myDevice withType:type withBeginIndex:-1 withCount:messageCount];
        }else{
            [[MessageManager shareInstance] getConversation:inputJid withType:type withBeginIndex:-1 withCount:messageCount];            
        }

    }
}

-(NSString *)formatAppMsg:(NSString *)content withTime:(NSString *) time
{
    return [NSString stringWithFormat:@"{\"yourcls\":\"details\",\"txt\":\"%@\",\"time\":\"%@\",\"style\":\"\",\"style\":\"\",\"stdtime\":\"\",\"details\":\"outline:none\"}",[ImUtils flattenHTML:content trimWhiteSpace:YES],time];
}



-(void) parseConversationHistory:(NSArray *)data
{
    [self markAllMSgReaded];
//    [entityArray removeAllObjects];
    if([ImUtils getChatType:inputJid] == SessionType_LightApp)
    {
        for (LightAppMessageInfo *info in data) {
            if (interrupt) {
                [entityArray removeAllObjects];
                break;
            }
            
            if([info.lightappType isEqualToString:KEY_TEXT] && !info.attr_)
            {
                info.attr_ = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:[ImUtils flattenHTML:[parser pasrePushMessageToSmily:info.content] trimWhiteSpace:YES]];
                [info.attr_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                [info.attr_ setTextAlignment:kCTTextAlignmentNatural lineBreakMode:kCTLineBreakByCharWrapping];
                info.size_ = [info.attr_  sizeConstrainedToSize:CGSizeMake(kTextCellMAXWidth, CGFLOAT_MAX)];
            }else if ([info.lightappType isEqualToString:KEY_IMAGE])
            {
                info.size_ = CGSizeMake(kImageCellWidth, kImageCellHeight);
            }else if ([info.lightappType isEqualToString:KEY_NEWS])
            {
                info.size_ = CGSizeMake(240,info.articleCount==1? 262: [LightAppNewsCell getCellHeightWithCount:info.articleCount]);
            }
            [entityArray addObject:info];
        }
    }else
    {
        for (ConversationInfo *record in data) {
            if (interrupt) {
                [entityArray removeAllObjects];
                break;
            }
            if(record.msgInfo.isTxtMsg && !record.attr_)
            {
                if ([record.msgInfo.txt rangeOfString:@"crowd_vote_info clearfix"].location !=NSNotFound) {
                    record.attr_ = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:record.msgInfo.txt];
                }else
                {
                    record.attr_ = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:[ImUtils flattenHTML:[parser pasrePushMessageToSmily:record.msgInfo.txt] trimWhiteSpace:YES]];
                    [record.attr_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
                }
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
    
    [self reloadDatas];

    NSLog(@"parseConversationHistory  long is %f",[[NSDate date] timeIntervalSinceDate:start]);
}

-(void) markAllMSgReaded
{
    switch ([ImUtils getChatType:inputJid]) {
        case SessionType_LightApp:

            [[MessageManager shareInstance] markLightMessageRead:inputJid type:[ImUtils getChatType:inputJid] withCallback:^(BOOL no) {
                
            }];
            break;
            
        default:
            if (self.myDevice) {
                [[MessageManager shareInstance] markMessageRead:self.myDevice type:[ImUtils getChatType:inputJid] withCallback:^(BOOL no) {
                    
                }];
            }else{
                [[MessageManager shareInstance] markMessageRead:inputJid type:[ImUtils getChatType:inputJid] withCallback:^(BOOL no) {
                    
                }];
            }

            break;
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
        float diff = (growingTextView.frame.size.height - height);
        
        CGRect r = operatePanel.frame;
        r.size.height -= diff;
        r.origin.y += diff;
        operatePanel.frame = r;
}



-(void)EmoViewTouchDown:(SmileyInfo *)smileyInfo with:(UIButton *)button
{
    if(![smileyInfo.resName isEqualToString:@"talk_emo_delete_nor.png"] && ![smileyInfo.resName isEqualToString:@"talk_emo_send_nor.png"])
    {
        UIImageView *iv = [[popEmoWindow subviews] objectAtIndex:0];
        iv.image = [UIImage imageNamed:smileyInfo.resName];
        UILabel *label = (UILabel *)[[popEmoWindow subviews] objectAtIndex:1];;
        label.text = smileyInfo.smiley;
        CGFloat x = button.center.x;
        CGFloat y = emoPanel.frame.origin.y +button.center.y-popEmoWindow.frame.size.height/2;
        popEmoWindow.center =  CGPointMake(x, y);
        [popEmoWindow setHidden:NO];
    }
}

-(void)EmoViewTouchUpInSide:(SmileyInfo *)smileyInfo with:(UIButton *)button
{
    [self performSelector:@selector(hidePopEmoWindow:) withObject:nil afterDelay:0.2];
    if([smileyInfo.resName isEqualToString:@"talk_emo_delete_nor.png"])
    {
        NSString *content = inputField.text;
        if(content.length>0)
        {
             inputField.text = [content substringToIndex:content.length-1];
        }
    }if([smileyInfo.resName isEqualToString:@"talk_emo_send_nor.png"])
    {
        [self sendMessage:nil];
    }else
    { 
        NSString *content=[NSString stringWithFormat:@"%@%@",inputField.text,smileyInfo.smiley];
        [inputField setText:content];
    }
    
}

-(void)EmoViewTouchUpOutSide:(SmileyInfo *)smileyInfo with:(UIButton *)button
{
    [self hidePopEmoWindow:button];
}

-(void)hidePopEmoWindow:(id)sender
{
    [popEmoWindow setHidden:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [popEmoWindow setHidden:YES];
     int index = scrollView.contentOffset.x/kScreenWidth;
    for (int i =0; i<docArray.count; i++) {
        UIButton *button = [docArray objectAtIndex:i];
        button.selected = i ==index;
    }
}
-(void)showVoicePanel
{
    [inputField resignFirstResponder];
    [voiceBtn setHidden:YES];
    [keyBordBtn setHidden:NO];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
    if (operatePanel.frame.origin.y>kScreenHeight-20-44-operatePanel.frame.size.height - 200)
    {
        [UIView animateWithDuration:0.35 animations:^{
            
            operatePanel.frame = CGRectMake(0,kScreenHeight-20-44-operatePanel.frame.size.height - 216, kScreenWidth,  operatePanel.frame.size.height);
            voicePanel.frame = CGRectMake(0,operatePanel.frame.origin.y + operatePanel.frame.size.height , kScreenWidth, voicePanel.frame.size.height);
            [morePanel setHidden:NO];
            voicePanel.hidden = NO;
            
            emoPanel.frame = CGRectMake(0, kScreenHeight-20-44,kScreenWidth, emoPanel.frame.size.height);
            mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
            [emoPanel setHidden:YES];
            
            morePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
            morePanel.hidden = YES;
        }];
    }else
    {
        voicePanel.frame = CGRectMake(0,operatePanel.frame.origin.y + operatePanel.frame.size.height , kScreenWidth, voicePanel.frame.size.height);
        [morePanel setHidden:NO];
        voicePanel.hidden = NO;
        
        emoPanel.frame = CGRectMake(0, kScreenHeight-20-44,kScreenWidth, emoPanel.frame.size.height);
        mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
        [emoPanel setHidden:YES];
        
        morePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
        morePanel.hidden = YES;
    }

}
-(IBAction)moreBtnClick:(id)sender
{
    [inputField resignFirstResponder];
    emoPanel.hidden = YES;
   
    if(morePanel.isHidden)
    {
        [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_close.png"] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_close_pre.png"] forState:UIControlStateHighlighted];
        if (operatePanel.frame.origin.y>kScreenHeight-20-44-operatePanel.frame.size.height - 200) {
            [UIView animateWithDuration:0.35 animations:^{
                
                operatePanel.frame = CGRectMake(0,kScreenHeight-20-44-operatePanel.frame.size.height - 216, kScreenWidth,  operatePanel.frame.size.height);
                morePanel.frame = CGRectMake(0,operatePanel.frame.origin.y + operatePanel.frame.size.height , kScreenWidth, morePanel.frame.size.height);
                [morePanel setHidden:NO];
                
                emoPanel.frame = CGRectMake(0, kScreenHeight-20-44,kScreenWidth, emoPanel.frame.size.height);
                mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
                [emoPanel setHidden:YES];
                
                voicePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
                voicePanel.hidden = YES;
            }];
        }else
        {
            morePanel.frame = CGRectMake(0,operatePanel.frame.origin.y + operatePanel.frame.size.height , kScreenWidth, morePanel.frame.size.height);
            [morePanel setHidden:NO];
            
            emoPanel.frame = CGRectMake(0, kScreenHeight-20-44,kScreenWidth, emoPanel.frame.size.height);
            mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
            [emoPanel setHidden:YES];
            
            voicePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
            voicePanel.hidden = YES;
        }
    }else
    {
        [self hidePanel];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseMessageInfo *bmi = [entityArray objectAtIndex:indexPath.row];
    if ([ImUtils getChatType:inputJid]==SessionType_LightApp) {
        LightAppMessageInfo * info = (LightAppMessageInfo *)bmi;
        if ([info.lightappType isEqualToString:KEY_NEWS])
        {
            if (info.articleCount==1) {
                LightAppNewsMessageInfo * news =  info.articles.lastObject;
                SVWebViewController *web = [[SVWebViewController alloc] init];
                web.URL = [NSURL URLWithString:news.url];
                [self.navigationController pushViewController:web animated:YES];
            }
        }
        
    }
}

-(void)selectPictureFromAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.picker animated:YES completion:nil];
    }else
    {
        [self showToast:NSLocalizedString(@"photo_unavailable",nil)];
    }
}

-(void)selectPictureFromCamer
{
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
     {
         self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
         [self presentViewController:self.picker animated:YES completion:nil];
     }else
     {
         [self showToast:NSLocalizedString(@"camera_unavailable",nil)];
     }
}

-(void) sendImage:(NSString *)src name:(NSString *) name
{
    if (![NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        
        [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(scrollToBottom:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        
        
        if([ImUtils getChatType:inputJid]==SessionType_LightApp)
        {
            [[MessageManager shareInstance] sendLightAppMessage:inputJid image:src];
        }else
        {
            [[MessageManager shareInstance] sendImageMessage:src callback:^(BOOL result) {
                
            }];
            
        }
        
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *newPortrait = [ImUtils scaleAndRotateImage:[info valueForKey:UIImagePickerControllerOriginalImage] scaleMaxResolution:[UIScreen mainScreen].bounds.size.width*3];
    NSData *bdata =  UIImageJPEGRepresentation(newPortrait,0.8); //[self calcSimpleSize:newPortrait.size maxH:kScreenHeight maxW:kScreenWidth]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"]; 
    NSString *imageName = [[ImUtils md5HexDigest:[formatter stringFromDate:[NSDate date]]] stringByAppendingString:@".jpg"];
    NSString *portraitPath = [ImUtils getVacrdImagePath:imageName];
    formatter = nil;
    [bdata writeToFile:portraitPath atomically:YES];
    [self sendImage:portraitPath name:imageName];
}


-(CGFloat) calcSimpleSize:(CGSize)size maxH:(CGFloat) maxH maxW:(CGFloat) maxW
{
    CGFloat ratio = 1.0;
    CGFloat ratio_w = 0;
    CGFloat ratio_h = 0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    if(width<= maxW && height<=maxW )
    {
        return ratio;
    }
    
    if(width > height)
    {
        ratio_w = width/maxW;
        ratio_h = height/maxH;
    }else{
        ratio_w = height/maxW;
        ratio_h = width/maxH;
    }
    
    if(ratio_h>ratio_w)
    {
        ratio = ratio_h;
    }else{
        ratio = ratio_w;
    }
    
    return 1.0;
}

-(void) showEmoWindow
{
//    [moreBtn setImage:[UIImage imageNamed:@"talk_more_inv_pre.png"] forState:UIControlStateHighlighted];
    
    if(!emoPanel)
    {
        [self initEmoPanel];
    }
    if (!emoPanel.hidden) {
        [self hidePanel];
        [popEmoWindow setHidden:YES];
    }else
    {
        [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
        morePanel.hidden=YES;
        [UIView animateWithDuration:0.25f animations:^{
            [inputField resignFirstResponder];
            [emoPanel setHidden:NO];
            emoPanel.frame = CGRectMake(0, kScreenHeight-20-44-216, kScreenWidth, 216);
            
            
            CGRect oprect = operatePanel.frame;
            oprect.origin.y = emoPanel.frame.origin.y-operatePanel.frame.size.height;
            operatePanel.frame = oprect;
            mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
            voicePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
            voicePanel.hidden = YES;
        }];
    }
    
}

-(void) hideEmoWindow
{
    [popEmoWindow setHidden:YES];
    [UIView animateWithDuration:0.25f animations:^{
        mainContent.frame = CGRectMake(mainContent.frame.origin.x, mainContent.frame.origin.y, mainContent.frame.size.width,operatePanel.frame.origin.y - mainContent.frame.origin.y);
        [emoPanel setHidden:YES];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) registerKeybordChangedListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

//-(void) unRegisterKeybordChangedListener
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
//}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = operatePanel.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    
    CGRect tableView = mainContent.frame;
    tableView.size.height = containerFrame.origin.y;
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	operatePanel.frame = containerFrame;
    mainContent.frame = CGRectMake(tableView.origin.x, tableView.origin.y, tableView.size.width, containerFrame.origin.y);
    [morePanel setHidden:YES];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
	[voiceBtn setHidden:NO];
    [keyBordBtn setHidden:YES];
    voicePanel.hidden = YES;
	// commit animations
	[UIView commitAnimations];
    [self hideEmoWindow];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = operatePanel.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
    CGRect tableView = mainContent.frame;
    tableView.size.height = containerFrame.origin.y;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	operatePanel.frame = containerFrame;
	mainContent.frame = tableView;
	// commit animations
	[UIView commitAnimations];
}

-(void) keyBordFrameChanged:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
   
    CGRect beginRect = [[info valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat offset = endRect.origin.y - beginRect.origin.y;
  
    if(offset <0 && operatePanel.frame.origin.y != kScreenHeight-20-44-operatePanel.frame.size.height+offset)
    {
        CGRect dockFrame = operatePanel.frame;
        dockFrame.origin.y += offset;
        CGRect moreFrame = morePanel.frame;
        moreFrame.origin.y += offset;
        
        CGRect tableView = mainContent.frame;
        tableView.size.height += offset;
        
       
        
        [UIView  animateWithDuration:duration animations:^{
            operatePanel.frame = dockFrame;
            morePanel.frame = moreFrame;
            mainContent.frame = tableView;
            [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:NO];
        }];
    }
}

-(IBAction)sendMessage:(id)sender
{
    if (![NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        [morePanel setHidden:YES];
        
        if(inputField.text.length== 0)
        {
            return;
        }
        NSMutableString *message = [NSMutableString stringWithString:inputField.text];
        
        [message replaceOccurrencesOfString:@"<" withString:@"&lt" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length)];
        [message replaceOccurrencesOfString:@">" withString:@"&gt" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length)];
        //    [message replaceOccurrencesOfString:@"\n" withString:@"<br>" options:NSCaseInsensitiveSearch range:NSMakeRange(0, message.length)];
        
        inputField.text = @"";
        if([ImUtils getChatType:inputJid]==SessionType_LightApp)
        {
            [[MessageManager shareInstance] sendLightAppMessage:inputJid text:message];
            [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(scrollToBottom:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
            [self markAllMSgReaded];
        }else
        {
            [[MessageManager shareInstance] sendMessage:message callback:^(BOOL result) {
                [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(scrollToBottom:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
                [self markAllMSgReaded];
            }];
        }
    }
}
-(void)sendVoiceMessage:(NSString *)src andDuration:(int)duration
{
    if (![NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        if ([ImUtils getChatType:inputJid] == SessionType_LightApp)
        {
            [self performSelectorOnMainThread:@selector(reloadDatas) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(scrollToBottom:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
            [[MessageManager shareInstance] sendLightAppMessage:inputJid voice:src lenght:duration callback:^(BOOL result) {
                [[amrEnDecodeManager sharedManager] deleteFile:src];
            }];
            
        }else{
            [[MessageManager shareInstance] sendVoiceMessage:src duration:duration callback:^(BOOL isOK){
                NSLog(@"%s",__FUNCTION__);
                if (isOK) {
                    NSLog(@"语音发送成功！");
                }else{
                    NSLog(@"语音发送失败！");
                }
                [[amrEnDecodeManager sharedManager] deleteFile:src];
            }];
        }
    }
}
-(void) showToast:(NSString *)content
{
    [Toast show:content];
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
        }else if ([info.lightappType isEqualToString:KEY_NEWS])
        {
            return info.size_.height;
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
    
    return 44 ;
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
                    cell.textView.delegate =self;
                    [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)withRowNum:indexPath.row]];
                }
                FriendInfo *fi = info.lightappDetail?info.lightappDetail:[[RosterManager shareInstance] mySelf];
                [ImUtils setHeadViewImage:fi withImageView:cell.headImageview forJid:inputJid];
                
                [cell setupCell:info.attr_ withSTDtime:info.ntime withSize:info.size_ withRowHeight:tableView.rowHeight];
                
                return cell;
            }else
            {
                TalkFromTextCell *cell=(TalkFromTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkFromTextCell"];
                if(!cell)
                {
                    cell = [[TalkFromTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkFromTextCell"];
                    cell.txtView.delegate =self;
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
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
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                FriendInfo *fi = [[RosterManager shareInstance] mySelf];
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
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                [cell.headImageView setImageWithURL:[NSURL fileURLWithPath:li.appIcon_middle] placeholderImage:[UIImage imageNamed:@"app_default.png"]];
                [cell setCellDataDuration:info.voiceLength stdTime:info.ntime.longLongValue isPlay:YES];
                [cell changeSubViews];
                cell.delegate = self;
                
                return cell;
            }
        }else if ([info.lightappType isEqualToString:KEY_IMAGE])
        {
            TalkToImgCell *cell=(TalkToImgCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToImgCell1"];
            if(!cell)
            {
                cell = [[TalkToImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToImgCell1"];
                [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)withRowNum:indexPath.row]];
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
    }else{
        // if (self.tableView.dragging == NO && self.tableView.decelerating == NO
        ConversationInfo *info = (ConversationInfo *)bmi;
        if (info.msgInfo.isTxtMsg) {

            if (info.isSend) {

                TalkToTextCell *cell=(TalkToTextCell *)[tableView dequeueReusableCellWithIdentifier:@"TalkToTextCell"];
                if(!cell)
                {
                    cell = [[TalkToTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TalkToTextCell"];
                    cell.textView.delegate =self;
                    [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)withRowNum:indexPath.row]];
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
                    cell.txtView.delegate =self;
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
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
                    [cell.headImageview addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageview.frame.size.width, cell.headImageview.frame.size.height)withRowNum:indexPath.row]];
                    [self addTapGestureToView:cell.contentImg];
                }

                [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageview forJid:inputJid];

                [cell setupCell:info withCallback:^{
                    dispatch_block_t tableViewReloadBlock = ^{
                        NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                        NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
                        [mainContent reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
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
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];

                    [self addTapGestureToView:cell.contentImg];
                }

                [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
                [cell setupCell:info withCallback:^{
                    dispatch_block_t tableViewReloadBlock = ^{
                        NSIndexPath *indexPath_1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                        NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
                        [mainContent reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
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
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
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
                    [cell.headImageView addSubview:[self createFriendHeaderImageButtonWithFrame:CGRectMake(0, 0, cell.headImageView.frame.size.width, cell.headImageView.frame.size.height)withRowNum:indexPath.row]];
                }
                [ImUtils setHeadViewImage:info.extraInfo withImageView:cell.headImageView forJid:inputJid];
                [cell setCellDataDuration:info.msgInfo.duration stdTime:info.msgInfo.stdtime isPlay:info.msgInfo.isPlay];
                [cell changeSubViews];
                cell.delegate = self;
                
                return cell;
            }
        }
    }
    return [[TalkFromTextCell alloc] init];
}

- (UIButton *)createFriendHeaderImageButtonWithFrame:(CGRect)frame withRowNum:(NSInteger)rowNum;
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    [button setTag:rowNum];
    [button addTarget:self action:@selector(personImagebuttonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
    return button;
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
    
   
    [self.navigationController pushViewController:controller animated:NO];
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

// 好友头像点击事件
- (void)personImagebuttonPressed:(UIButton *)button event:(UIEvent *)event
{
    if([ImUtils getChatType:inputJid] ==SessionType_LightApp)
        return;
    NSSet *set = [event allTouches];
    UITouch *touch = [set anyObject];
    CGPoint point = [touch locationInView:self.mainContent];
    NSIndexPath *indexPath = [mainContent indexPathForRowAtPoint:point];
    ConversationInfo *convInfo =[entityArray objectAtIndex:indexPath.row];
    FriendInfo *info =convInfo.extraInfo;
    if ([info.jid isEqualToString:[RosterManager shareInstance].mySelf.jid]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenPersonalTab" object:[NSNumber numberWithBool:YES]];
        PersonalInfoViewController *controller =  [[PersonalInfoViewController alloc] init];
        controller.isPushFromTalkController = YES;
        self.navigationController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else
    {
        PersonCardViewController * cardViewController = [[PersonCardViewController alloc] init];
        cardViewController.hidesBottomBarWhenPushed = YES;
        
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
    
}

-(void) showOtherMsg:(ConversationInfo *)conversationInfo
{
    NSString  *showName = conversationInfo.showName.length>0?conversationInfo.showName: ((FriendInfo *)conversationInfo.extraInfo).showName;
    if (conversationInfo.msgInfo.isImgMsg) {
        [otherMsgBtn setTitle:@"[图片]"forState:UIControlStateNormal];
    }else if (conversationInfo.msgInfo.isVideoMsg)
    {
        [otherMsgBtn setTitle:@"[语音]"forState:UIControlStateNormal];
    }else
    {
        [otherMsgBtn setTitle:[NSString stringWithFormat:@"%@:%@",showName,[ImUtils flattenHTML:[parser pasrePushMessageToSmily:conversationInfo.content] trimWhiteSpace:YES]] forState:UIControlStateNormal];
    }
    [otherMsgBtn setHidden:NO];
    
    otherConversationInfo = conversationInfo;
    [otherMsgBtn addTarget:self action:@selector(showOtherMsgInNew:) forControlEvents:UIControlEventTouchUpInside];
    if (self.msgTimer) {
        [self.msgTimer invalidate];
    }
    self.msgTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideOherBtn) userInfo:nil repeats:NO];

}

-(void)hideOherBtn
{
    [otherMsgBtn setHidden:YES];
}

-(IBAction)showOtherMsgInNew:(id)sender
{
    
    showOtherFlag = false;
    PrivateTalkViewController *controller = [[PrivateTalkViewController alloc] init];
    controller.groupType = OTHER_CONVERSATION;
    controller.hidesBottomBarWhenPushed = YES;

    switch ([ImUtils  getChatType:otherConversationInfo.jid]) {
        case SessionType_Conversation:
            controller.inputObject = otherConversationInfo.extraInfo;

            break;
        case SessionType_Crowd:
            controller.inputObject = otherConversationInfo.crowdOrDiscussion;
            break;
        case SessionType_Discussion:
             controller.inputObject = otherConversationInfo.crowdOrDiscussion;
            break;
        default:
            controller.inputObject = otherConversationInfo.extraInfo;
            break;
    }
    
    
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)reloadTableViewDataSource{
    if(countAll< self.messageCount)
    {
        _reloading = YES;
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
//        [self performSelector:@selector(doneLoadingTableViewData)];
    }else
    {
        if(_reloading)
        {
            return;
        }
        _reloading = YES;
        self.messageCount += 15;
        [self obtainConversationHistory];
//        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    }
    
   
}

- (void)doneLoadingTableViewData{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mainContent];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	//[super scrollViewDidScroll:scrollView];
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
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
    self.picker  = nil;
    fileManager = nil;
    _refreshHeaderView=nil;
    [entityArray removeAllObjects];
    [popUpWindowArray removeAllObjects];
    self.mainContent = nil;
    self.operatePanel = nil;
    self.inputField = nil;
    self.inputObject = nil;
    self.view = nil;
    self.morePanel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteConverSationHistory" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [otherMsgBtn setHidden:YES];
    m_canRequestNext = NO;
}
#pragma mark - QTVoicePanel delegate methods
-(void)start
{
    [self clearHUD];

    QTTalkHUD * hud = [[QTTalkHUD alloc]initWithFrame:CGRectMake(0, operatePanel.frame.origin.y - 50, 320, 50)];
    hud.tag = 10000;
    [self.view addSubview:hud];
    [[amrEnDecodeManager sharedManager] startRecord];
}
-(void)recordWillCancel
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud willCancel];
}
-(void)resetHUD
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud reSet];
}
-(void)cancel
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud warnError:@"取消发送语音"];
    [[amrEnDecodeManager sharedManager] cancelRecord];

    [UIView animateWithDuration:1 animations:^{
        hud.alpha = 0;
    }];
}
-(void)end
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [UIView animateWithDuration:1 animations:^{
        hud.alpha = 0;
    }];
    [[amrEnDecodeManager sharedManager] stopRecord:^(NSDictionary *dict) {
        if (dict) {
            [self sendVoiceMessage:[dict objectForKey:@"filePath"] andDuration:[[dict objectForKey:@"recordTime"] integerValue]];
//            [[amrEnDecodeManager sharedManager] deleteFile:[dict objectForKey:@"filePath"]];
        }
    }];
}
#pragma mark - RecordSoundManagerDelegate (amrEnDecodeManager) Methods -
-(void)changeHUDTimeLabelText:(NSString *)time
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud changeTimeLabelText:time];
}
-(void)error:(NSString *)error
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud warnError:error];
    [[amrEnDecodeManager sharedManager] cancelRecord];
    hud.alpha = 0;
    [self clearHUD];
    [voicePanel setUserInteractionEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(beginRecord) userInfo:nil repeats:NO];
//    [Button setUserInteractionEnabled:NO];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clearHUD) userInfo:nil repeats:NO];
//    [UIView animateWithDuration:1 animations:^{
//        hud.alpha = 0;
//    }];
}
-(void)beginRecord
{
    [voicePanel setUserInteractionEnabled:YES];
}

-(void)ended
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [UIView animateWithDuration:1 animations:^{
        hud.alpha = 0;
    }];
    [[amrEnDecodeManager sharedManager] stopRecord:^(NSDictionary *dict) {
        if (dict) {
            [self sendVoiceMessage:[dict objectForKey:@"filePath"] andDuration:[[dict objectForKey:@"recordTime"] integerValue]];
//            [[amrEnDecodeManager sharedManager] deleteFile:[dict objectForKey:@"filePath"]];
        }
    }];
}
-(void)changeMicImageAccoerdingPeakpower:(double)peakPower
{
    [voicePanel changeBgImageAccordingPeakPower:peakPower];
}
-(void)loopPlay
{
    if ([ImUtils getChatType:inputJid] == SessionType_LightApp) {
        if (indexForCurrentPlay <entityArray.count) {
            LightAppMessageInfo * info = [entityArray objectAtIndex:indexForCurrentPlay];
            if ([info.lightappType isEqualToString:KEY_MUSIC]) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:indexForCurrentPlay inSection:0];
                id Cell = [mainContent cellForRowAtIndexPath:indexPath];
                [Cell setSelected:YES];
                [Cell beganAnimation];

                NSString * voiceFile = info.url;
                isPlay = YES;
                [[amrEnDecodeManager sharedManager] startPlay:voiceFile];
                indexForCurrentPlay ++;
            }else{
                isPlay = NO;
                indexForCurrentPlay ++;
                [self loopPlay];
            }
        }else{
            isPlay = NO;
        }
    }else{
        if (indexForCurrentPlay <entityArray.count) {
            if ([[entityArray objectAtIndex:indexForCurrentPlay] msgInfo].isVoiceMsg) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:indexForCurrentPlay inSection:0];
                id Cell = [mainContent cellForRowAtIndexPath:indexPath];
                [Cell setSelected:YES];
                [Cell beganAnimation];

                ConversationInfo *info = [entityArray objectAtIndex:indexForCurrentPlay];
                NSString * voiceFile = info.msgInfo.src;
                isPlay = YES;
                [[amrEnDecodeManager sharedManager] startPlay:voiceFile];

                [[MessageManager shareInstance] markVoiceOrVideoMsgRead:info callback:^(BOOL isOK) {
                    if (isOK) {

                    }else{
                        LOG_NETWORK_INFO(@"mark read error !");
                    }
                }];
                indexForCurrentPlay ++;
            }else{
                isPlay = NO;
                indexForCurrentPlay ++;
                [self loopPlay];
            }
        }else{
            isPlay = NO;
        }
    }
}

-(void)clearHUD
{
    QTTalkHUD *hud = (QTTalkHUD *)[self.view viewWithTag:10000];
    [hud.layer removeAllAnimations];
    [hud removeFromSuperview];
}

#pragma mark - QTVoiceMessageCellDelegate methods
-(void)voiceMessageButtonPressedAtCell:(id)cell
{
    if ([cell getSelected]) {
        if (isPlay) {
            [self clearCellAnimationAndPlayer];
        }
        NSIndexPath * indexPath = [mainContent indexPathForCell:cell];
        indexForCurrentPlay = indexPath.row;
        [self loopPlay];
    }else{
        [cell stopAnimation];
        [[amrEnDecodeManager sharedManager] stopPlay];
    }
}

-(void)clearCellAnimationAndPlayer
{
    NSIndexPath * indexPath1 = [NSIndexPath indexPathForRow:indexForCurrentPlay-1 inSection:0];
    id currentCell = [mainContent cellForRowAtIndexPath:indexPath1];
    [currentCell stopAnimation];
    [[amrEnDecodeManager sharedManager] stopPlay];
    isPlay = NO;
}

-(UIColor*)attributedLabel:(OHAttributedLabel*)attrLabel colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline
{
	return [UIColor whiteColor];
}
-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo event:(UIEvent *)event
{
    NSLog(@"attributedLabel string is %@",attributedLabel.attributedText.string);
    [attributedLabel setNeedsRecomputeLinksInText];
    if([attributedLabel.attributedText.string rangeOfString:@"(点击参与)"].location !=NSNotFound)
    {
        
        NSSet *set = [event allTouches];
        UITouch *touch = [set anyObject];
        CGPoint point = [touch locationInView:self.mainContent];
        NSIndexPath *indexPath = [mainContent indexPathForRowAtPoint:point];
        ConversationInfo *convInfo =[entityArray objectAtIndex:indexPath.row];
        
        if (m_canRequestNext) {
            m_canRequestNext = NO;
            [[CrowdManager shareInstance] voteDetail:convInfo.msgInfo.gid voteId:convInfo.msgInfo.vid jid:convInfo.msgInfo.jid callback:^(CrowdVoteInfo * info) {
                if(info)
                {
                    dispatch_block_t tableViewReloadBlock = ^{
                        CrowdVoteViewController * controller = [[CrowdVoteViewController alloc] init];
                        controller.m_crowdVoteInfo = info;
                        [self.navigationController pushViewController:controller animated:YES];
                        m_canRequestNext = NO;
                    };
                    dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
                    
                    
                }else
                {
                    m_canRequestNext = YES;
                }
            }];
        }
    }
     return NO;
}
-(void)hidePanel
{
    [inputField resignFirstResponder];
    emoPanel.hidden = YES;
    voicePanel.hidden = YES;
    morePanel.hidden = YES;
    
    operatePanel.frame = CGRectMake(0,kScreenHeight-20-44-operatePanel.frame.size.height, kScreenWidth,  operatePanel.frame.size.height);
    mainContent.frame = CGRectMake(0, mainContent.frame.origin.y, kScreenWidth, kScreenHeight-20-44-operatePanel.frame.size.height);
    voicePanel.frame = CGRectMake(0, kScreenHeight - 22 - 44, kScreenWidth, 216);
    morePanel.frame = voicePanel.frame;
    
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more.png"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"talk_dock_more_pre.png"] forState:UIControlStateHighlighted];
    
    [lightContantView setHidden:YES];
    [lightDropView setHidden:YES];
}

- (void)addTapGestureToView:(UIView *)view {
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImagePreView:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[view addGestureRecognizer:tapRecognizer];
}

- (void)addTapGestureToNewsView:(UIView *)view {
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsView:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[view addGestureRecognizer:tapRecognizer];
}

@end
