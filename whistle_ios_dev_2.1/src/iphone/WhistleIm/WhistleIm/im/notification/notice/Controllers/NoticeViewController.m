//
//  NoticeViewController.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-2.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import "NoticeViewController.h"
#import "NoticeTableView.h"
#import "NoticesDetailViewController.h"
#import "NoticeManager.h"
#import "ChatRecordForNotice.h"
#import "NBNavigationController.h"
#import "RootView.h"
#import "CustomActionSheet.h"

#define SEND_DATE @"date"
#define ALL_DATA  @"data"

@interface NoticeViewController ()
<NoticeTableViewDelegate, NBNavigationControllerDelegate,UIActionSheetDelegate, CustomActionSheetDelegate>
{
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    CGRect m_frame;
    
    NoticeTableView * m_noticeTableView;
    NoticeAndNotificationInfo * m_dataInfo;
    NSUInteger m_noticeUnreadCounter;
    NSInteger m_noticeCounter;
}
@property (nonatomic,strong) NoticeTableView * m_noticeTableView;
@property (nonatomic,strong) NoticeAndNotificationInfo * m_dataInfo;

@end

@implementation NoticeViewController
@synthesize m_noticeTableView;
@synthesize m_allDataDict;
@synthesize m_dataInfo;

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
    [self createNoticeTableView];
}
#pragma mark - 设置基本信息
- (void)setBasicConditions
{
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    [[GetFrame shareInstance] setNavigationBarForController:self];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - noticeAndnotification - delegate methods
- (void)updateNotice:(NSMutableDictionary *)dataDict
{
    self.m_allDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    [self.delegate updateNoticeData:dataDict];
    [self.m_noticeTableView refreshNoticeTableView:self.m_allDataDict isNotice:YES isUpdate:YES];
}
#pragma mark - 处理未读通知
- (void)sendNoticeUnreadCounter:(NSUInteger)counter andIsUpdate:(BOOL)isUpdate
{
    m_noticeUnreadCounter = counter;
    [self.delegate sendNoticeUnReadCount:counter];
    [self getUnreadCounterIsUpdate:isUpdate];
}

- (void)getUnreadCounterIsUpdate:(BOOL)isUpdate
{
    [self.delegate getUnreadCounter];
}
- (void)playSoundWithCount:(NSUInteger)unReadCount AndIsNotice:(BOOL)isNotice;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPromptNotification" object:nil];
}
#pragma mark - create and edit notice tableView
- (void)createNoticeTableView
{
    CGFloat y=0;
    if (isIOS7) {
        y = 20 +44;
    }
    self.m_noticeTableView = [[NoticeTableView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height- 20 - 44)];
    self.m_noticeTableView.clipsToBounds = YES;
    self.m_noticeTableView.backgroundColor = [UIColor clearColor];
    [self.m_noticeTableView refreshNoticeTableView:self.m_allDataDict isNotice:YES isUpdate:NO];
    self.m_noticeTableView.m_delegate = self;
    [self.view addSubview:self.m_noticeTableView];
}
- (void)editNoticeTableView:(BOOL)canEdit
{
    [self.m_noticeTableView editTableView:canEdit];
}

#pragma mark -  NoticeTableView delegate methods
- (void)noticeMarkRead:(ChatRecordForNotice *)notice
{
    LOG_UI_INFO(@"notice mark read use delegate in controller");
    [[NoticeManager shareInstance] markRead:notice withCallback:^(BOOL remarked) {
        
    }];
}

// NoticeTableView delegate push notice detail controller
- (void)cellDidSelectedRow:(NSUInteger)selectedRow andIsNotice:(BOOL)isNotice
{
    NSMutableArray * noticeDataArr = [self.m_allDataDict objectForKey:ALL_DATA];
    NoticesDetailViewController * controller = [[NoticesDetailViewController alloc] init];
    controller.m_selectedIndex = selectedRow;
    controller.m_arrNoticeData = noticeDataArr;
    controller.isNotice = YES;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// NoticeTableView delegate delete notice
- (void)deleteNoticeInTheMemory:(ChatRecordForNotice *)notice
{
    [[NoticeManager shareInstance] deleteNotice:notice withCallback:^(BOOL deleted) {
        
    }];
}
#pragma mark - 设置按钮的显示时机
- (void)hiddenNoticeEditBarButton:(NSUInteger)noticeCount andIsEditState:(BOOL)isEdit
{
//    m_noticeCounter = noticeCount;
    [self resetDeleteButtonHidden:(noticeCount <= 0)];
}

- (void)hiddenDeleteButton
{
    m_noticeCounter = [[m_allDataDict objectForKey:SEND_DATE] count];
    [self resetDeleteButtonHidden:(m_noticeCounter <= 0)];
}

- (void)clearEditState
{
    [self.m_noticeTableView clearEditState];
}

#pragma mark - navigation bar sett
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"delete" andLeftTitle:@"通知" andRightTitle:nil andNeedCreateSubViews:needCreate];
}
- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
//    UIActionSheet* actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消删除" destructiveButtonTitle:nil otherButtonTitles:@"删除已读",@"全部删除", nil];
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
        [self.m_noticeTableView removeAll];
    }
}


- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)editButtonPressedWithState:(BOOL)isEditState
{
    NSLog(@"NotificationViewController edit state is == %d", isEditState);
    [self editNoticeTableView:isEditState];
}

- (void)resetDeleteButtonHidden:(BOOL)hidden
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav resetDeleteButtonHidden:hidden];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    [self hiddenDeleteButton];
    [self clearEditState];
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
#pragma mark - delete Action - Actionsheet Delegate

//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"%d",buttonIndex);
//    if (buttonIndex == 0) {
////       [self.m_noticeTableView removeRead];
//        [self removeRead];
//    }else if(buttonIndex == 1){
//        NSLog(@"â==============aaa=========aaa===========aaa");
//        [self.m_noticeTableView removeAll];
//    }
//}

-(void)removeRead
{
    NSMutableArray * noticeDataArr = [self.m_allDataDict objectForKey:ALL_DATA];
    ChatRecordForNotice * notice = nil;
    
    NSMutableArray * flagArray = [NSMutableArray array];

    for (int i = 0; i<noticeDataArr.count; i++) {
        NSMutableArray * array = [noticeDataArr objectAtIndex:i];
        for (int j = 0; j<array.count; j++) {
            notice = [array objectAtIndex:j];
            if (notice.isRead) {
                [flagArray addObject:notice];
            }
        }
    }
    LOG_GENERAL_INFO(@"已读通知标记数组（flagArray）＝ %@",flagArray);
    if (flagArray.count>0) {
        for (int i = 0; i<flagArray.count; i ++) {
            [self deleteNoticeInTheMemory:[flagArray objectAtIndex:i]];
        }
    }
}
@end
