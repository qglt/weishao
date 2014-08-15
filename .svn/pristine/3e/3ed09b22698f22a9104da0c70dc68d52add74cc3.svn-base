//
//  AddMembersToCrowdAndGroupViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddMembersToCrowdAndGroupViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "AddMembersScrollView.h"
#import "AddMembersTableView.h"
#import "AddmemberInfo.h"
#import "SearchMembersTableView.h"
#import "FriendInfo.h"
#import "LocalSearchData.h"
#import "FriendGroupSectionInfo.h"
#import "RosterManager.h"
#import "MemberImageView.h"
#import "DiscussionManager.h"
#import "AddRostersViewController.h"
#import "WhistleAppDelegate.h"
#import "PrivateTalkViewController.h"
#import "CrowdListViewController.h"
#import "CrowdMembersViewController.h"
#import "GroupInfoViewController.h"
#import "NetworkBrokenAlert.h"
#import "CommonRespondView.h"

#define ADD_CROWD_MEMBERS @"addCrowdMembers"
#define ADD_GROUP_MEMBERS_NONE @"addGroupMembersNone"
#define ADD_GROUP_MEMBERS_DEFAULT @"addGroupMembersDefault"
#define ADD_GROUP_MEMBERS_DEFAULT_STRANGER @"addGroupMembersDefaultStranger"

#define ADD_CROWD_MEMBERS_FROM_INFO @"addCrowdMembersFromInfo"
#define ADD_GROUP_MEMBERS_FROM_INFO @"addGroupMembersFromInfo"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"

@interface AddMembersToCrowdAndGroupViewController ()
<AddmemberInfoDelegate, AddMembersTableView, SearchMembersTableViewDelegate, UITableViewDataSource, UITableViewDelegate, MemberImageViewDelegate, DiscussionDelegate>
{
    CGRect m_frame;
    NSUInteger m_totalMembers;
    AddMembersScrollView * m_memberScrollView;
    
    //
    NSMutableArray * m_arrImages;
    
    
    // 临时数据index
    NSUInteger m_index;
    
    AddMembersTableView * m_membersTableView;
    SearchMembersTableView * m_searchTableView;
    AddmemberInfo * m_info;
    NSMutableDictionary * m_dictAllData;
    
    NSString * m_searchText;
    
    // 搜索页保存数组
    NSMutableArray * m_arrSearchData;

    NSMutableArray * m_arrCommonSelectedJid;
    
    NSMutableArray * m_arrStrangerAndBlackListJid;
    
    UITableView * m_tableView;
    
    NSUInteger m_addMemberSuccessNum;
}

@property (nonatomic, strong) AddMembersScrollView * m_memberScrollView;
@property (nonatomic, strong) NSMutableArray * m_arrImages;
@property (nonatomic, strong) AddMembersTableView * m_membersTableView;
@property (nonatomic, strong) SearchMembersTableView * m_searchTableView;

@property (nonatomic, strong) AddmemberInfo * m_info;
@property (nonatomic, strong) NSMutableDictionary * m_dictAllData;
@property (nonatomic, strong) NSString * m_searchText;
@property (nonatomic, strong) NSMutableArray * m_arrSearchData;
@property (nonatomic, strong) NSMutableArray * m_arrCommonSelectedJid;
@property (nonatomic, strong) NSMutableArray * m_arrStrangerAndBlackListJid;
@property (nonatomic, strong) UITableView * m_tableView;

@end

@implementation AddMembersToCrowdAndGroupViewController

@synthesize m_type;

@synthesize m_memberScrollView;
@synthesize m_arrImages;

@synthesize m_membersTableView;
@synthesize m_searchTableView;
@synthesize m_info;
@synthesize m_dictAllData;
@synthesize m_searchText;
@synthesize m_arrSearchData;
@synthesize m_arrCommonSelectedJid;
@synthesize m_arrStrangerAndBlackListJid;
@synthesize m_tableView;
@synthesize m_crowdSessionID;
@synthesize m_friendJid;
@synthesize m_arrHadMembersJid;
@synthesize m_maxLimit;

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
    [[DiscussionManager shareInstance] addListener:self];
    NSLog(@"self.m_arrHadMembersJid == %@", self.m_arrHadMembersJid);

    [self setbasicCondition];
    [self createNavigationBar:YES];
    [self regNotification];
    
    [self createTableView];
    [self createSearchFriendTableView];
    [self createhengTableView];
    
    [self createMemory];
    [self createAddmemberInfo];
    [self getDataFromAddmemberInfo];
}

- (void)createMemory
{
    self.m_arrCommonSelectedJid = [[NSMutableArray alloc] initWithCapacity:0];
    if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT] && self.m_friendJid) {
        [self.m_arrCommonSelectedJid addObject:self.m_friendJid];
    }

    self.m_arrStrangerAndBlackListJid = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)setbasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    
    NSString * title = nil;
    if ([self.m_type isEqualToString:ADD_CROWD_MEMBERS]) {
        title = @"添加群成员";
        m_totalMembers = self.m_maxLimit - 1;
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_NONE]) {
        title = @"添加组成员";
        m_totalMembers = 19;
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT]) {
        title = @"添加组成员";
        m_totalMembers = 19;
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT_STRANGER]) {
        title = @"添加组成员";
        m_totalMembers = 18;
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO]) {
        title = @"添加组成员";
        m_totalMembers = 20 - [self.m_arrHadMembersJid count];
    } else if ([self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO]) {
        title = @"添加群成员";
        m_totalMembers = self.m_maxLimit - [self.m_arrHadMembersJid count];
    }

    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"finish" andLeftTitle:title andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    if ([self.m_type isEqualToString:ADD_CROWD_MEMBERS] || [self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO]) {
        [self addCrowdMembers];
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_NONE] || [self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT] || [self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT_STRANGER]) {
        [self createGroup];
    } else if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO]) {
        [self addGroupMembers];
    }
}

- (void)createGroup
{
    if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_DEFAULT_STRANGER] && self.m_friendJid) {
        [self.m_arrCommonSelectedJid addObject:self.m_friendJid];
    }
    
    NSLog(@"create group member jid arr == %@, and count == %d", self.m_arrCommonSelectedJid, [self.m_arrCommonSelectedJid count]);

    if ([self.m_arrCommonSelectedJid count] > 0) {
        [[DiscussionManager shareInstance] createChatGroup:nil friends:self.m_arrCommonSelectedJid callback:^(BOOL success) {
            NSLog(@"create chat group success == %d", success);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    
                }
            });
        }];
    } else {
        [self createAlertViewWithMessage:@"请添加讨论组成员"];
    }
}

- (void)addGroupMembers
{
    if ([self.m_arrCommonSelectedJid count] > 0) {
        
        [[DiscussionManager shareInstance] inviteIntoDiscussion:self.m_crowdSessionID friend:self.m_arrCommonSelectedJid callback:^(BOOL success) {
            NSLog(@"add chat group member success == %d", success);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO] || [self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO] ) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            });
        }];
        
    } else {
        [self createAlertViewWithMessage:@"请添加讨论组成员"];
    }
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)createDiscussionFinish:(ChatGroupInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
        controller.inputObject = info;
        controller.groupType = self.m_type;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    });
}

- (void)addCrowdMembers
{
    if ([self.m_arrCommonSelectedJid count] > 0) {
        NSUInteger totalNum = [self.m_arrCommonSelectedJid count];
        for (NSUInteger i = 0; i < [self.m_arrCommonSelectedJid count]; i++) {
            NSString * friendId = [self.m_arrCommonSelectedJid objectAtIndex:i];
            [[CrowdManager shareInstance] inviteIntoCrowd:self.m_crowdSessionID friend:friendId callback:^(BOOL isSucess) {
                NSLog(@"add member to my crowd success == %d", isSucess);
                if (isSucess) {
                    m_addMemberSuccessNum++;
                }
                
                NSLog(@"add member to my crowd success total number== %d", m_addMemberSuccessNum);
                
                if (m_addMemberSuccessNum == totalNum) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO] || [self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO] ) {
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [self popToCorrespondingViewController];
                        }
                    });
                }
            }];
        }
    } else {
        [self createAlertViewWithMessage:@"请添加群成员"];
    }
}

- (void)popToCorrespondingViewController
{
    NSLog(@"self.navigationController in add member controller == %@", self.navigationController);

    NSArray * controllerArr = self.navigationController.viewControllers;
    for (UIViewController * controller in controllerArr) {
        if ([controller isKindOfClass:[AddRostersViewController class]]) {
            AddRostersViewController * addRosterVC = (AddRostersViewController *)controller;
            [self.navigationController popToViewController:addRosterVC animated:YES];
            
            NSLog(@"had AddRostersViewController");
            NSLog(@"self.navigationController in add member controller == %@", self.navigationController);

        } else if ([controller isKindOfClass:[CrowdListViewController class]]) {
            CrowdListViewController * crowdListVC = (CrowdListViewController *)controller;
            [self.navigationController popToViewController:crowdListVC animated:YES];
            
            NSLog(@"had CrowdListViewController");
            NSLog(@"self.navigationController in add member controller == %@", self.navigationController);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

// 创建数据源类
- (void)createAddmemberInfo
{
    self.m_info = [[AddmemberInfo alloc] init];
    self.m_info.m_delegate = self;
}

// 获取好友数据
- (void)getDataFromAddmemberInfo
{
    [self.m_info getAllFriendsSectionsAndDataDict];
}

// 返回好友数据
- (void)sendFriendData:(NSMutableDictionary *)friendDataDict
{
    self.m_arrStrangerAndBlackListJid = [self getStangerAndBlackListJidWithDict:friendDataDict];
    self.m_dictAllData = [self getNoneStrangerAndBlackListDataWithDict:friendDataDict];
    [self.m_membersTableView refreshTableView:self.m_dictAllData andSelectedJidArr:self.m_arrCommonSelectedJid];
}

// 获取陌生人和黑名单的jid
- (NSMutableArray *)getStangerAndBlackListJidWithDict:(NSDictionary *)dataDict
{
    NSMutableArray * titleArr = [dataDict objectForKey:SECTION_TITLE];
    NSMutableArray * allDataArr = [dataDict objectForKey:ALL_SECTION_DATA];
    NSMutableArray * strangerAndBlackListArr = [[NSMutableArray alloc] initWithCapacity:0];
    // log
    for (NSUInteger i = 0; i < [titleArr count]; i++) {
        FriendGroupSectionInfo * sectionInfo = [titleArr objectAtIndex:i];
        NSLog(@"section name == %@", sectionInfo.name);
    }
    
    for (NSUInteger i = 0; i < [titleArr count]; i++) {
        FriendGroupSectionInfo * sectionInfo = [titleArr objectAtIndex:i];
        if ([sectionInfo.name isEqualToString:@"黑名单"] || [sectionInfo.name isEqualToString:@"陌生人"] ) {
            NSMutableArray * eachSectionArr = [allDataArr objectAtIndex:i];
            for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
                FriendInfo * friendInfo = [eachSectionArr objectAtIndex:j];
                [strangerAndBlackListArr addObject:friendInfo.jid];
            }
        }
    }
    
    NSLog(@"strangerAndBlackListArr == %@", strangerAndBlackListArr);
    
    return strangerAndBlackListArr;
}

// 去掉陌生人和黑名单的title和数据部分
- (NSMutableDictionary *)getNoneStrangerAndBlackListDataWithDict:(NSDictionary *)dataDict
{
    NSMutableDictionary * allDataDict = [NSMutableDictionary dictionary];
    NSMutableArray * titleArr = [dataDict objectForKey:SECTION_TITLE];
    NSMutableArray * allDataArr = [dataDict objectForKey:ALL_SECTION_DATA];
    
    NSInteger strangerIndex = -1;
    NSInteger blackListIndex = -1;
    
    for (NSUInteger i = 0; i < [titleArr count]; i++) {
        FriendGroupSectionInfo * sectionInfo = [titleArr objectAtIndex:i];
        NSLog(@"section name == %@", sectionInfo.name);
        if ([sectionInfo.name isEqualToString:@"黑名单"]) {
            blackListIndex = i;
        } else if ([sectionInfo.name isEqualToString:@"陌生人"]) {
            strangerIndex = i;
        }
    }
    
    NSLog(@"title blackListIndex == %d", blackListIndex);
    NSLog(@"title strangerIndex == %d", strangerIndex);
    
    // 去掉陌生人和黑名单的section title
    // 去掉陌生人和黑名单对应的数据部分
    if (blackListIndex > 0) {
        [titleArr removeObjectAtIndex:blackListIndex];
        [allDataArr removeObjectAtIndex:blackListIndex];
    }
        
    if (strangerIndex > 0) {
        [titleArr removeObjectAtIndex:strangerIndex];
        [allDataArr removeObjectAtIndex:strangerIndex];
    }
    
    
    
    NSLog(@"好友页面去掉黑名单和陌生人的title数组 == %@", titleArr);
    NSLog(@"好友页面去掉黑名单和陌生人的数据数组 == %@", allDataArr);
    
    for (NSUInteger i = 0 ; i < [allDataArr count]; i++) {
        NSLog(@"each arr == %@, and count == %d", [allDataArr objectAtIndex:i], [[allDataArr objectAtIndex:i] count]);
    }

    
    if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO] || [self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO]) {
        allDataDict = [self getNewMembersWithTitleArr:titleArr andDataArr:allDataArr];
    } else {
        [allDataDict setValue:titleArr forKey:SECTION_TITLE];
        [allDataDict setValue:allDataArr forKey:ALL_SECTION_DATA];
    }
    return allDataDict;
}

// 好友页面，在去除陌生人和黑名单的数组中，去掉已经在群里或讨论组里地成员
- (NSMutableDictionary *)getNewMembersWithTitleArr:(NSMutableArray *)titleArr andDataArr:(NSMutableArray *)dataArr
{
    NSMutableDictionary * newDataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray * newSectionTitleArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * newAllDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        
        NSMutableArray * newEachSectionArr = [[NSMutableArray alloc] initWithCapacity:0];

        NSMutableArray * eachSectionArr = [dataArr objectAtIndex:i];
        for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
            FriendInfo * friendInfo = [eachSectionArr objectAtIndex:j];
            if (![self hadInCrowdOrGroup:friendInfo.jid]) {
                [newEachSectionArr addObject:friendInfo];
            }
        }
        
//        if ([newEachSectionArr count] > 0) {
            FriendGroupSectionInfo * sectionInfo = [titleArr objectAtIndex:i];
            [newSectionTitleArr addObject:sectionInfo];
            [newAllDataArr addObject:newEachSectionArr];
//        }
    }
    
    // 数据正常，但显示不对
    NSLog(@"去掉已经在群里或讨论组里面的title数组 == %@", newSectionTitleArr);
    NSLog(@"去掉已经在群里或讨论组里面的数据数组 == %@", newAllDataArr);
    
    for (NSUInteger i = 0 ; i < [newAllDataArr count]; i++) {
        NSLog(@"new each arr == %@, and count == %d", [newAllDataArr objectAtIndex:i], [[newAllDataArr objectAtIndex:i] count]);
    }
    
    [newDataDict setValue:newSectionTitleArr forKey:SECTION_TITLE];
    [newDataDict setValue:newAllDataArr forKey:ALL_SECTION_DATA];

    
    return newDataDict;
}

// 是否在群里或讨论组里面
- (BOOL)hadInCrowdOrGroup:(NSString *)friendJid
{
    BOOL result = NO;
    
    NSLog(@"friendJid == %@", friendJid);
    
    for (NSUInteger i = 0; i < [self.m_arrHadMembersJid count]; i++) {
        if ([friendJid isEqualToString:[self.m_arrHadMembersJid objectAtIndex:i]]) {
            result = YES;
            break;
        }
    }
    
    return result;
}

// AddMembersTableView delegate
- (void)cancelButtonPressed
{
    NSLog(@"delete button pressed in AddMembersToCrowdAndGroupViewController");
    self.m_searchTableView.hidden = YES;
    [self refreshFriendPageSelectedState];
}

- (void)refreshFriendPageSelectedState
{
    [self.m_searchTableView sendSelectedStateArr];
    [self.m_membersTableView refreshTableView:self.m_dictAllData andSelectedJidArr:self.m_arrCommonSelectedJid];
}

// AddMembersTableView  delegate 获取本地搜索
- (void)searchBarTextDidChanged:(NSString *)text
{
    NSLog(@"search bar did change text == %@", text);
    self.m_searchText = text;
    [self.m_info findContactWithSeachText:text];
}

- (void)showNoneTextAlert
{
    [CommonRespondView respond:@"请输入查找条件"];
}

// 本地搜索返回
- (void)sendSearchData:(NSMutableArray *)searchDataArr
{
    self.m_searchTableView.hidden = NO;
    self.m_arrSearchData = [self getSearchDataExceptStrangerAndBlackListWithArr:searchDataArr];
    [self.m_searchTableView refreshTableViewWithDataArr:self.m_arrSearchData andSearchText:self.m_searchText andSelectedJidArr:self.m_arrCommonSelectedJid];
}

// 本地搜索过滤掉陌生人和黑名单
- (NSMutableArray *)getSearchDataExceptStrangerAndBlackListWithArr:(NSMutableArray *)dataArr
{
    NSMutableArray * noneStrangerArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        LocalSearchData * data = [dataArr objectAtIndex:i];
        if (![self isStrangerAndBlackList:data.m_jid]) {
            [noneStrangerArr addObject:data];
        }
    }
    
    NSLog(@"搜索页，去掉黑名单和陌生人里面的人 == %@， and count == %d", noneStrangerArr, [noneStrangerArr count]);

    // 群或讨论组资料页面，添加成员，把已经在群或讨论组里的去掉
    if ([self.m_type isEqualToString:ADD_GROUP_MEMBERS_FROM_INFO] || [self.m_type isEqualToString:ADD_CROWD_MEMBERS_FROM_INFO]) {
        NSMutableArray * newMembersArr = [self getMembersNoneInTheCrowdOrGroupWithArr:noneStrangerArr];
        return newMembersArr;
    } else {
        return noneStrangerArr;
    }
}

// 本地搜索，在去除陌生人和黑名单的数组中，去掉已经在群里或讨论组里地成员
- (NSMutableArray *)getMembersNoneInTheCrowdOrGroupWithArr:(NSMutableArray *)noneStrangerArr
{
    NSMutableArray * newMemberArr = [[NSMutableArray alloc] initWithCapacity:0];

    for (NSUInteger i = 0; i < [noneStrangerArr count]; i++) {
        LocalSearchData * data = [noneStrangerArr objectAtIndex:i];
        if (![self hadInCrowdOrGroup:data.m_jid]) {
            [newMemberArr addObject:data];
        }
    }
    
    NSLog(@"搜索页，去掉已经在群或讨论组里面的人 == %@, and count == %d", newMemberArr, [newMemberArr count]);
    
    return newMemberArr;
}

- (BOOL)isStrangerAndBlackList:(NSString *)friendJid
{
    BOOL result = NO;
    
    NSLog(@"friendJid == %@", friendJid);
    NSLog(@"strangerAndBlackListArr == %@", self.m_arrStrangerAndBlackListJid);

    for (NSUInteger i = 0; i < [self.m_arrStrangerAndBlackListJid count]; i++) {
        if ([friendJid isEqualToString:[self.m_arrStrangerAndBlackListJid objectAtIndex:i]]) {
            result = YES;
            break;
        }
    }
    
    return result;
}

// 搜索tableview滚动
- (void)searchFriendsTableViewScrolled
{
    [self.m_membersTableView resignFirstResponderForSearchBar];
}

// 创建好友页
- (void)createTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (isIOS7) {
        y += 64;
        if (is4Inch) {
            height = m_frame.size.height - 64 - 49;
        } else {
            height = m_frame.size.height - 64 - 49;
        }
    } else {
        height = m_frame.size.height - 44 - 44;
    }
    
    self.m_membersTableView = [[AddMembersTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withDataDict:self.m_dictAllData];
    self.m_membersTableView.clipsToBounds = YES;
    self.m_membersTableView.m_delegate = self;
    self.m_membersTableView.m_maxLimitNum = m_totalMembers;
    self.m_membersTableView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    [self.view addSubview:self.m_membersTableView];
}

// 创建搜索页
- (void)createSearchFriendTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (isIOS7) {
        y += 64;
        if (is4Inch) {
            height = m_frame.size.height - 64 - 49;
        } else {
            height = m_frame.size.height - 64 - 49;
        }
    } else {
        height = m_frame.size.height - 44 - 44;
    }
    
    y += 45.0f;
    height -= 45;
    
    self.m_searchTableView = [[SearchMembersTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_searchTableView.hidden = YES;
    self.m_searchTableView.m_delegate = self;
    self.m_searchTableView.m_maxLimitNum = m_totalMembers;
    self.m_searchTableView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    [self.view addSubview:self.m_searchTableView];
}

// 好友页cell点击代理
- (void)friendCellDidSelectedWithIndexPath:(NSIndexPath *)indexPath andSelectedJidArr:(NSMutableArray *)selectedJidArr
{
    NSLog(@"common selected jid arr in controller for friend page == %@", self.m_arrCommonSelectedJid);
    self.m_arrCommonSelectedJid = selectedJidArr;
    [self reloadTableView];
}

// 本地搜索页cell点击代理
- (void)searchCellDidSelectedWithIndexPath:(NSIndexPath *)indexPath andSelectedJidArr:(NSMutableArray *)selectedJidArr
{
    NSLog(@"common selected jid arr in controller for search page == %@", self.m_arrCommonSelectedJid);
    self.m_arrCommonSelectedJid = selectedJidArr;
    [self reloadTableView];
}

- (void)reloadTableView
{
    [self.m_tableView reloadData];
    
    NSUInteger indexRow = 0;
    if ([self.m_arrCommonSelectedJid count] < m_totalMembers) {
        indexRow = [self.m_arrCommonSelectedJid count];
    } else {
        indexRow = m_totalMembers - 1;
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:indexRow inSection:0];
    [self.m_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void)createhengTableView
{
    CGFloat y = m_frame.size.height;
    if (isIOS7 == NO) {
        y -= 64.0f;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.m_tableView.backgroundColor = [UIColor whiteColor];
    [self.m_tableView.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    self.m_tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.frame = CGRectMake(0, y, 320, 49);
    self.m_tableView.rowHeight = 58.0;
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.backgroundColor = [ImUtils colorWithHexString:@"#333333"];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.m_arrCommonSelectedJid count] < m_totalMembers) {
        return [self.m_arrCommonSelectedJid count] + 1;
    } else {
        return [self.m_arrCommonSelectedJid count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        MemberImageView * imageView = [[MemberImageView alloc] initWithFrame:CGRectMake(7, 15, 35, 35) andWithImage:[UIImage imageNamed:@"emptyRound.png"] andWithNumbers:@""];
        imageView.tag = 1000;
        imageView.m_delegate = self;
        imageView.transform = CGAffineTransformMakeRotation(-M_PI * 1.5);
        [cell addSubview:imageView];
    }
    
    MemberImageView * imageView = (MemberImageView *)[cell viewWithTag:1000];
    if (indexPath.row < [self.m_arrCommonSelectedJid count]) {
        NSString * jid = [self.m_arrCommonSelectedJid objectAtIndex:indexPath.row];
        [[RosterManager shareInstance] getFriendInfoByJid:jid checkStrange:YES WithCallback:^(FriendInfo * friendInfo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:friendInfo convertToGray:NO];
                [imageView resetImageViewWithImage:image andResetLabelWith:nil];
            });
        }];
    } else {
        NSString * num = [NSString stringWithFormat:@"%d", m_totalMembers - [self.m_arrCommonSelectedJid count]];
        [imageView resetImageViewWithImage:[UIImage imageNamed:@"emptyRound.png"] andResetLabelWith:num];
    }
  
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = [UIColor whiteColor];
//}

// MemberImageView delegate
- (void)deleteImageButtonPressedInMemberImageView:(MemberImageView *)mySelf
{
    UITableViewCell * cell = nil;
    if (isIOS7) {
        cell = (UITableViewCell *)mySelf.superview.superview;
    } else {
        cell = (UITableViewCell *)mySelf.superview;
    }
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    
    
    NSLog(@"m_arrCommonSelectedJid == %@", self.m_arrCommonSelectedJid);
    NSLog(@"delete image row == %d", indexPath.row);
    
    if ([self.m_arrCommonSelectedJid count] > 0 && indexPath.row < [self.m_arrCommonSelectedJid count]) {
        [self.m_arrCommonSelectedJid removeObjectAtIndex:indexPath.row];
        [self reloadTableView];
        
        [self.m_searchTableView refreshTableViewWithDataArr:self.m_arrSearchData andSearchText:self.m_searchText andSelectedJidArr:self.m_arrCommonSelectedJid];
        [self.m_membersTableView refreshTableView:self.m_dictAllData andSelectedJidArr:self.m_arrCommonSelectedJid];
    }
}

#pragma mark - notification handler

// 键盘高度变化通知
- (void)regNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSLog(@"endKeyboardRect == %@", NSStringFromCGRect(endKeyboardRect));
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.m_tableView.frame;
        if (isIOS7) {
            frame.origin.y = endKeyboardRect.origin.y;
        } else {
            frame.origin.y = endKeyboardRect.origin.y - 64;
        }
        self.m_tableView.frame = frame;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
