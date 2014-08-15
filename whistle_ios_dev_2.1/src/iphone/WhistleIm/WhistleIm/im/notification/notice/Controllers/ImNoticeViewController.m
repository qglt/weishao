//
//  ImNoticeViewController.m
//  Whistle2013
//
//  Created by wangchao on 13-6-18.
//  Copyright (c) 2013年 ruijie. All rights reserved.
//

#import "ImNoticeViewController.h"
#import "NBNavigationController.h"
#import "RootView.h"
#import "NoticeViewController.h"
#import "MyNotificationViewController.h"
#import "baseTableViewCell.h"
#import "LeveyTabBarController.h"
#import "NoticeAndNotificationInfo.h"
#import "CampusMapViewController.h"
#import "ImUtils.h"
#import "QTNoticeDelegate.h"
#import "CloudAccountManager.h"
#import "NoticeManager.h"
#import "AppMessageManager.h"

@interface ImNoticeViewController ()
< NBNavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,NoticeAndNotificationInfoDelegate,QTNoticeDelegate, NoticeDelegate, AppMsgDelegate>
{
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    CGRect m_frame;
    BOOL m_isNotice;
    NSArray * cellData;
    int unreadNotice;
    int unreadAppMsg;

    NSUInteger m_totalUnreadCounter;
    NSUInteger m_noticeUnreadCounter;
    NSUInteger m_notificationUnreadCounter;

}
@property (nonatomic,strong) UITableView* baseTableView;
@property (nonatomic,strong) NoticeAndNotificationInfo * m_dataInfo;
@property (nonatomic,strong) NSMutableDictionary * m_NoticeallDataDict;
@property (nonatomic,strong) NSMutableDictionary * m_notificationAllDataDict;
@end

@implementation ImNoticeViewController
@synthesize m_dataInfo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self createDataInfo];
        unreadAppMsg = 0;
        unreadNotice = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NoticeManager shareInstance] addListener:self];
    [[AppMessageManager shareInstance] addListener:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [self getNoticeData];
    [self getNotificationsData];

    [self createNavigationBar:YES];
    [self setBasicConditions];
    
    [self createBaseTableView];///////////////
    [self addSeparatorLine];

}
-(void)addSeparatorLine
{
    UIView * SPL = [[UIView alloc]initWithFrame:CGRectMake(0, 9, 320, 1)];
    SPL.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [self.view insertSubview:[[RootView alloc]initWithView:SPL] atIndex:0];
}
- (void)setBasicConditions
{
    cellData = [NSArray arrayWithObjects:@"通知",@"应用提醒",@"notice",@"appnotice", @"微时空",@"布告栏",@"myspace",@"board",nil];
    m_isNotice = NO;
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    [[GetFrame shareInstance] setNavigationBarForController:self];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:nil andLeftTitle:@"动态" andRightTitle:nil andNeedCreateSubViews:needCreate];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    self.m_dataInfo.m_delegate = self;
//    [self getNoticeData];
//    [self getNotificationsData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createDataInfo
{
    self.m_dataInfo = [[NoticeAndNotificationInfo alloc]init];
    self.m_dataInfo.m_delegate = self;
}
- (void)getNoticeData
{
    [self.m_dataInfo constructTableViewData];
}
- (void)getNotificationsData
{
    [self.m_dataInfo constructTableViewNotificationData];
}
#pragma mark - NoticeAndNotificationDelegate - Methods
-(void)updateNotice:(NSMutableDictionary *)dataDict
{
    self.m_NoticeallDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
}
-(void)updateNotification:(NSMutableDictionary *)dataDict
{
    self.m_notificationAllDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
}

#pragma mark - QTNoticeDelegate Methods -
- (void)updateNoticeData:(NSMutableDictionary *)dataDict
{
    self.m_NoticeallDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
}
- (void)updateNotificationData:(NSMutableDictionary *)dataDict
{
    self.m_notificationAllDataDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
}
- (void)getUnreadCounter
{
    m_totalUnreadCounter = m_noticeUnreadCounter + m_notificationUnreadCounter;
    if (m_totalUnreadCounter <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNoticebadgevalue" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNoticebadgevalue" object:@""];
    }
}
- (void)sendNoticeUnReadCount:(NSUInteger)count
{
    m_noticeUnreadCounter = count;
}
- (void)sendNotificationUnReadCount:(NSUInteger)count
{
    m_notificationUnreadCounter = count;
}
- (void)playSoundWithCount:(NSUInteger)unReadCount AndIsNotice:(BOOL)isNotice;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playPromptNotification" object:nil];
}
#pragma mark - -------------------------------------------
- (void)changeTheme:(NSNotification *)notification
{
    [self createNavigationBar:NO];
}
#pragma mark - baseTableView methods
-(void)createBaseTableView
{
    self.baseTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 280) style:UITableViewStylePlain];
    _baseTableView.dataSource = self;
    _baseTableView.delegate = self;
    _baseTableView.backgroundColor = [UIColor clearColor];
    _baseTableView.scrollEnabled = NO;
    [_baseTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview: [[RootView alloc] initWithView: self.baseTableView]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0;
}
    
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//[self.tableSections count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (void) updateNoticeUnReadCount:(NSUInteger)count
{
    unreadNotice = count;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_baseTableView reloadData];
    });
}

- (void) updateAppMsgUnReadCount:(NSUInteger)count
{
    unreadAppMsg = count;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_baseTableView reloadData];
    });
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifeir = @"identifeir";
    baseTableViewCell* Cell = [tableView dequeueReusableCellWithIdentifier:identifeir];
    if (!Cell) {
        Cell = [[baseTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifeir];
        Cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    Cell.textLabel.text = [cellData objectAtIndex:(4 * indexPath.section + indexPath.row)];
    Cell.imageView.image = [UIImage imageNamed:[cellData objectAtIndex:(4 * indexPath.section + indexPath.row+2)]];
    if (indexPath.row == 0) {
        [Cell setUnreadNum:unreadNotice];
    }else if(indexPath.row == 1){
        [Cell setUnreadNum:unreadAppMsg];
    }
    
    return Cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    
    if (indexPath.row == 0) {
        m_isNotice = YES;
        NoticeViewController* NVC = [[NoticeViewController alloc]init];
        self.m_dataInfo.m_delegate = NVC;
        NVC.m_allDataDict = _m_NoticeallDataDict;
        NVC.delegate = self;
        NVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:NVC animated:YES];
    }else{
        m_isNotice = NO;
        MyNotificationViewController* MNVC = [[MyNotificationViewController alloc]init];
        self.m_dataInfo.m_delegate = MNVC;
        MNVC.m_notificationAllDataDict = _m_notificationAllDataDict;
        MNVC.delegate = self;
        MNVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:MNVC animated:YES];
    }
    }else{
        if([[CloudAccountManager shareInstance] isCloudOpen]){
            if(indexPath.row == 0){
            
                CampusMapViewController *wmvc = [[CampusMapViewController alloc] init];
                wmvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wmvc animated:YES];
                
                //[self presentViewController:wmvc animated:YES completion:nil];
            }else{

            }
        }else{
            NSLog(@"CloudManager report NO for open %d",[[CloudAccountManager shareInstance] isCloudAvaible]);
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.leveyTabBarController hidesTabBar:YES animated:YES];
}
@end


