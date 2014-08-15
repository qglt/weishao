//
//  ImRosterViewController.m
//  Whistle2013
//
//  Created by wangchao on 13-6-18.
//  Copyright (c) 2013年 ruijie. All rights reserved.
//

#import "ImRosterViewController.h"
#import "Constants.h"
#import "Whistle.h"
#import "FriendInfo.h"
//#import "LocalSearchResultCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkEnv.h"
#import "GetFrame.h"
#import "FriendsAndGroupView.h"
#import "SearchFriendsTableView.h"
#import "FriendsSectionInfo.h"
#import "PrivateTalkViewController.h"
#import "AddRostersViewController.h"
#import "RosterManager.h"
#import "CrowdAndGroupInfo.h"
#import "GroupCellData.h"
#import "CrowdInfo.h"
#import "AddFriendsViewController.h"
#import "FriendGroupSectionInfo.h"
#import "FriendInfo.h"
#import "PersonCardViewController.h"
#import "NBNavigationController.h"
#import "RootView.h"
#import "LocalSearchData.h"
#import "CrowdListViewController.h"
#import "GroupListViewController.h"
#import "AddRostersViewController.h"
#import "LeveyTabBarController.h"
#import "ImUtils.h"
#import "CommonRespondView.h"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"


#define LEFT_ITEM_TAG 2000

@interface ImRosterViewController ()
<UIScrollViewDelegate, NetworkBrokenDelegate, FriendsAndGroupViewDelegate, SearchFriendsTableViewDelegate, FriendsSectionInfoDelegate>
{
    BOOL _isShowNetworkView ;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    CGRect m_frame;
    
    FriendsAndGroupView * m_friendView;
    UIScrollView * m_scrollView;
    SearchFriendsTableView * m_searchFriendsTableView;
    NSMutableArray * m_arrSearchData;
    NSMutableDictionary * m_dictAllData;
    FriendsSectionInfo * m_info;
    NSString * m_searchText;
    
    // 可以再一次进入好友名片标志位
    BOOL m_canRequestNext;
    
}
@property (nonatomic,strong) FriendsSectionInfo * m_info;

@property (nonatomic,strong) NSMutableArray * m_arrSearchData;
@property (nonatomic,strong)  NSMutableDictionary * m_dictAllData;
@property (nonatomic,strong) UIImageView *switchView;
@property (nonatomic,strong) FriendsAndGroupView * m_friendView;
@property (nonatomic,strong) UIScrollView * m_scrollView;
@property (nonatomic,strong) SearchFriendsTableView * m_searchFriendsTableView;

@property (nonatomic, strong) NSString * m_searchText;


@end

@implementation ImRosterViewController

@synthesize m_info;
@synthesize m_arrSearchData;
@synthesize m_dictAllData;
@synthesize m_friendView;
@synthesize m_scrollView;
@synthesize m_searchFriendsTableView;
@synthesize m_searchText;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)changeTheme:(NSNotification *)notification
{
    [self createNavigationBar:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_canRequestNext = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [self setbasicCondition];
    [self createNavigationBar:YES];

    [self createFriendsSectionInfo];
    
    [self createScrollView];
    [self createSearchFriendTableView];
    
    [self createFriendsView];
    [self getDataFromFriendsSeactionInfo:NO];
}

- (void)setbasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    _isShowNetworkView = NO;
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

// 初始化好友数据封装类
- (void)createFriendsSectionInfo
{
    self.m_info = [[FriendsSectionInfo alloc] init];
    self.m_info.m_delegate = self;
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:@"add" andLeftTitle:@"联系人" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    [self clearUI];
    AddRostersViewController * controller = [[AddRostersViewController alloc] init];
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getDataFromFriendsSeactionInfo:(BOOL)isRefresh
{
    [self.m_info getAllFriendsSectionsAndDataDictWith:isRefresh];
}

- (void)sendFriendData:(NSMutableDictionary *)friendDataDict
{
    self.m_dictAllData = friendDataDict;
    if (self.m_friendView) {
        [self.m_friendView refreshTableView:self.m_dictAllData];
    }
}

- (void)createScrollView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        if (m_is4Inch) {
            height = m_frame.size.height - 64 - 50;
        } else {
            height = m_frame.size.height - 64 - 50;
        }
    } else {
        height = m_frame.size.height - 44 - 44;
    }
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, height)];
    self.m_scrollView.delegate = self;
    self.m_scrollView.showsHorizontalScrollIndicator = YES;
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.userInteractionEnabled = YES;
    self.m_scrollView.scrollEnabled = NO;
    [self.m_scrollView setContentSize:CGSizeMake(m_frame.size.width, height)];
    self.m_scrollView.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview: [[RootView alloc] initWithView: self.m_scrollView]];
}

- (void)createSearchFriendTableView
{
    self.m_searchFriendsTableView = [[SearchFriendsTableView alloc] initWithFrame:CGRectMake(0, 50, self.m_scrollView.frame.size.width, self.m_scrollView.frame.size.height - 50)];
    self.m_searchFriendsTableView.m_delegate = self;
    self.m_searchFriendsTableView.hidden = YES;
    self.m_searchFriendsTableView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    [self.m_scrollView addSubview:self.m_searchFriendsTableView];
}

// SearchFriendsTableView delegate 滑动的时候
- (void)searchFriendsTableViewScrolled
{
    [self.m_friendView closeKeyBoard];
}

// SearchFriendsTableView delegate
- (void)didSelectFriendIndexWithID:(LocalSearchData *)searchData andType:(NSString *)type
{
    [self clearUI];
    [self pushToTalkViewControllerFromSearchTableView:searchData andType:type];
}

- (void)showCrowdAlockingAlert
{
    [[[CustomAlertView alloc] initWithTitle:@"系统提示" message:@"操作失败，该群已被冻结" delegate:nil cancelButtonTitle:nil confrimButtonTitle:@"确定"] show];
}

- (void)pushToTalkViewControllerFromSearchTableView:(LocalSearchData *)searchData andType:(NSString *)type
{
    if ([type isEqualToString:@"conversation"]) {
        FriendInfo * selectedFriendInfo = nil;
        NSMutableArray * dataArr = [self.m_dictAllData objectForKey:ALL_SECTION_DATA];
        
        for (NSUInteger i = 0; i < [dataArr count]; i++) {
            NSMutableArray * eachSectionArr = [dataArr objectAtIndex:i];
            for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
                FriendInfo * friendInfo = [eachSectionArr objectAtIndex:j];
                if ([friendInfo.jid isEqualToString:searchData.m_jid]) {
                    selectedFriendInfo = friendInfo;
                    break;
                }
            }
        }
        
        [self pushToTalkViewControllerWithFriendInfo:selectedFriendInfo];
    } else {
        
        id object = nil;
        
        if ([type isEqualToString:@"crowd_chat"]) {
            object = searchData.m_crowdInfo;
        } else if ([type isEqualToString:@"group_chat"]) {
            object = searchData.m_chatGroupInfo;
        }
        PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
        controller.inputObject = object;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)createFriendsView
{
    self.m_friendView = [[FriendsAndGroupView alloc] initWithFrame:CGRectMake(0, 0, self.m_scrollView.frame.size.width, self.m_scrollView.frame.size.height) andIsGroup:NO withDataDict:self.m_dictAllData];
    self.m_friendView.clipsToBounds = YES;
    self.m_friendView.backgroundColor = [UIColor clearColor];
    self.m_friendView.m_delegate = self;
    [self.m_scrollView addSubview:self.m_friendView];
}

- (void)showNoneTextAlert
{
    [CommonRespondView respond:@"请输入查找条件"];
}

- (void)pushToCrowdListViewController
{
    [self clearUI];
    CrowdListViewController * controller = [[CrowdListViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToGroupListViewController
{
    [self clearUI];
    GroupListViewController * controller = [[GroupListViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// group cell delegate
- (void)didSelectRowAtIndexPathWithGroupJid:(GroupCellData *)groupCellData;
{
    [self clearUI];
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = groupCellData.m_chatGroupInfo;
    controller.title = groupCellData.m_strGroupName;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// crowd cell delegate
- (void)didSelectRowAtIndexPathWithCrowdInfo:(CrowdInfo *)crowdInfo
{
    [self clearUI];
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = crowdInfo;
    controller.title = crowdInfo.name;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

// FriendsAndGroupView delegate 滑动的时候
- (void)cancelButtonPressed
{
    [self clearUI];
}

// FriendsAndGroupView delegate
- (void)searchBarTextDidChanged:(NSString *)text
{
    NSLog(@"search bar did change text == %@", text);
    self.m_searchText = text;
    [self.m_info findContactWithSeachText:text];
}

// FriendsAndGroupView delegate
- (void)pullDownToReloadData
{
    [self getDataFromFriendsSeactionInfo:YES];
}

// FriendsSectionInfo delegate
- (void)sendSearchData:(NSMutableArray *)searchDataArr
{
    NSLog(@"searchDataArr to controller == %@", searchDataArr);
    self.m_arrSearchData = searchDataArr;
    self.m_searchFriendsTableView.hidden = NO;
    [self.m_scrollView bringSubviewToFront:self.m_searchFriendsTableView];
    [self.m_searchFriendsTableView refreshTableViewWithDataArr:self.m_arrSearchData andSearchText:self.m_searchText];
}

// FriendsAndGroupView delegate
- (void)didSelectRowAtIndexPath:(FriendInfo *)friendInfo
{
    NSLog(@"didSelectRowAtIndexPath friendInfo == %@", friendInfo);
    [self pushToTalkViewControllerWithFriendInfo:friendInfo];
}

// 好友头像进入名片页面
- (void)cellButtonPressedInFriendsAndGroupView:(NSIndexPath *)indexPath
{
    if (m_canRequestNext) {
        m_canRequestNext = NO;
        
        LOG_UI_INFO(@"cellButtonPressedInFriendsAndGroupView indexPath == %@", indexPath);
        NSLog(@"friend image is pressed");
        NSMutableArray * allSectionData = [self.m_dictAllData objectForKey:ALL_SECTION_DATA];
        FriendInfo * friendInfo = [[allSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [[RosterManager shareInstance] getRelationShip:friendInfo.jid WithCallback:^(enum FriendRelation relationShip) {
            BOOL isStranger = NO;
            if (relationShip == RelationStranger || relationShip == RelationNone) {
                isStranger = YES;
            } else if (relationShip == RelationContact) {
                isStranger = NO;
            } else if (relationShip == RelationError) {
                m_canRequestNext = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self clearUI];
                PersonCardViewController * controller = [[PersonCardViewController alloc] init];
                controller.m_jid = friendInfo.jid;
                controller.m_isStranger = isStranger;
                [controller setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:controller animated:YES];
                m_canRequestNext = NO;
            });
        }];
    }
}

- (void)pushToTalkViewControllerWithFriendInfo:(FriendInfo *)friendInfo
{
    [self clearUI];
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = friendInfo;
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    [self clearUI];
    m_canRequestNext = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearUI];
    m_canRequestNext = NO;
}

- (void)clearUI
{
    [self.m_friendView closeKeyBoard];
    [self.m_friendView clearSearchBarText];
    [self.m_friendView hiddenDeleteBtn];
    self.m_searchFriendsTableView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.leveyTabBarController hidesTabBar:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
