//
//  MyNotificationViewController.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-2.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import "MyNotificationViewController.h"
#import "Constants.h"
#import "Whistle.h"
#import "AppMessageManager.h"
#import "GetFrame.h"
#import "NoticeTableView.h"
#import "NoticeAndNotificationInfo.h"
#import "NoticesDetailViewController.h"
#import "NoticeManager.h"
#import "RecentAppMessageInfo.h"
#import "NBNavigationController.h"
#import "PrivateTalkViewController.h"
#import "RootView.h"
#import "NoticeViewController.h"
#import "CustomActionSheet.h"

#define LEFT_ITEM_TAG 2000

#define SEND_DATE @"date"
#define ALL_DATA  @"data"

#define NOTIFICATION_DATA @"notification_data"
#define NOTIFICATION_DATE @"notification_date"


@interface MyNotificationViewController ()
<NoticeTableViewDelegate, NoticeAndNotificationInfoDelegate, NBNavigationControllerDelegate,UIActionSheetDelegate, CustomActionSheetDelegate>
{
    BOOL _isShowNetworkView;
    
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    CGRect m_frame;
    
    NoticeTableView * m_notificationTableView;
    
    NSUInteger m_notificationUnreadCounter;
    NSInteger m_notificationCounter;
}
@property (nonatomic,strong) NoticeTableView * m_notificationTableView;
@property (nonatomic,strong) NoticeAndNotificationInfo * m_dataInfo;

@end

@implementation MyNotificationViewController

@synthesize m_notificationTableView;
@synthesize m_dataInfo;
@synthesize m_notificationAllDataDict;


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

    [self createNavigationBar:YES];
    [self setBasicConditions];
    
    [self createNotificationTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    [self hiddenDeleteButton];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 设置基本信息
- (void)setBasicConditions
{
    _isShowNetworkView = NO;//默认网络状态通知页面不显示
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    [[GetFrame shareInstance] setNavigationBarForController:self];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNotificationTableView
{
    self.m_notificationTableView = [[NoticeTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- 20 - 44)];
    self.m_notificationTableView.clipsToBounds = YES;
    self.m_notificationTableView.backgroundColor = [UIColor clearColor];
    self.m_notificationTableView.m_delegate = self;
    [self.m_notificationTableView refreshNoticeTableView:self.m_notificationAllDataDict isNotice:NO isUpdate:NO];
    [self.view addSubview:[[RootView alloc] initWithView:self.m_notificationTableView]];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"delete" andLeftTitle:@"应用提醒" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

#pragma mark - noticeAndnotyification delegate method
- (void)updateNotification:(NSMutableDictionary *)dataDict
{
    self.m_notificationAllDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    [self.delegate updateNotificationData:dataDict];
    [self.m_notificationTableView refreshNoticeTableView:self.m_notificationAllDataDict isNotice:NO isUpdate:YES];
}
- (void)getUnreadCounterIsUpdate:(BOOL)isUpdate
{
    [self.delegate getUnreadCounter];
}
- (void)playSoundWithCount:(NSUInteger)unReadCount AndIsNotice:(BOOL)isNotice;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPromptNotification" object:nil];
}
#pragma mark - noticeTableView delegate method
- (void)sendNotificationUnreadCounter:(NSUInteger)counter andIsUpdate:(BOOL)isUpdate
{
    m_notificationUnreadCounter = counter;
    [self.delegate sendNotificationUnReadCount:counter];
    [self getUnreadCounterIsUpdate:isUpdate];
}
- (void)notificationMarkRead:(RecentAppMessageInfo *)notification
{
    LOG_UI_INFO(@"notificationMarkRead");
    [[AppMessageManager shareInstance] markRead:notification WithCallback:^(BOOL remarked) {
        
    }];
}
- (void)NotificationCellDidSelected:(NSIndexPath *)indexPath
{
    NSMutableArray * notificationDataArr = [self.m_notificationAllDataDict objectForKey:NOTIFICATION_DATA];
    NoticesDetailViewController * controller = [[NoticesDetailViewController alloc] init];
    controller.m_selectedIndex = indexPath.row;
    controller.m_arrNoticeData = notificationDataArr;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (void)deleteNotificationInTheMemory:(RecentAppMessageInfo *)notification
{
    NSLog(@"delete notification");
    [[AppMessageManager shareInstance] deleteRecentAppMessage:notification withCallback:^(BOOL is) {
        
    }];
}
#pragma mark - set edit state - methods

- (void)hiddenNotificationEditBarButton:(NSUInteger)NotificationCount andIsEditState:(BOOL)isEdit
{
    m_notificationCounter = NotificationCount;
    [self hiddenDeleteButton];
}

- (void)hiddenDeleteButton
{
    [self resetDeleteButtonHidden:(m_notificationCounter <= 0)];
}
#pragma mark - navigation bar button pressent
- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
//    UIActionSheet* actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消删除" destructiveButtonTitle:nil otherButtonTitles:@"删除已读",@"删除全部", nil];
//    [actionsheet showInView:self.view];
    
    NSArray * titleArr = [NSArray arrayWithObjects:@"全部删除", @"删除已读", @"取消", nil];
    [[[CustomActionSheet alloc] initWithTitleArr:titleArr andDelegate:self andDescription:nil] show];
}

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 1) {
        [self removeRead];
    }else if(buttonIndex == 0){
        [self.m_notificationTableView removeAll];
    }
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetDeleteButtonHidden:(BOOL)hidden
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav resetDeleteButtonHidden:hidden];
}

//#pragma mark - UIActionsheet delegate methods
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"%d",buttonIndex);
//    if (buttonIndex == 0) {
//        [self removeRead];
//    }else if(buttonIndex == 1){
//        [self.m_notificationTableView removeAll];
//    }
//}

-(void)removeRead
{
    NSMutableArray * notificationDataArr = [self.m_notificationAllDataDict objectForKey:NOTIFICATION_DATA];
    RecentAppMessageInfo * notification = nil;

    NSMutableArray * flagArray = [NSMutableArray array];

    for (int i = 0; i<notificationDataArr.count; i++) {
        NSMutableArray * array = [notificationDataArr objectAtIndex:i];
        for (int j = 0; j<array.count; j++) {
            notification = [array objectAtIndex:j];
            if (notification.isRead) {
                [flagArray addObject:notification];
            }
        }
    }
    LOG_GENERAL_INFO(@"已读通知标记数组（flagArray）＝ %@",flagArray);
    if (flagArray.count>0) {
        for (int i = 0 ; i< flagArray.count; i ++) {
            [self deleteNotificationInTheMemory:[flagArray objectAtIndex:i]];
        }
    }
    
}
@end
