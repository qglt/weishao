//
//  GroupListViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "GroupListViewController.h"
#import "CrowdAndGroupInfo.h"
#import "ImUtils.h"
#import "FriendsAndGroupViewCell.h"
#import "GroupCellData.h"
#import "NBNavigationController.h"
#import "PrivateTalkViewController.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "GroupInfoViewController.h"

#define ADD_CROWD_MEMBERS @"addCrowdMembers"
#define ADD_GROUP_MEMBERS_NONE @"addGroupMembersNone"
#define ADD_GROUP_MEMBERS_DEFAULT @"addGroupMembersDefault"

@interface GroupListViewController ()
<FriendsAndGroupViewCellDelegate, CrowdAndGroupInfoDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CGRect m_frame;
    UITableView * m_tableView;
    
    CrowdAndGroupInfo * m_crowdAndGroupInfo;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic,strong) CrowdAndGroupInfo * m_crowdAndGroupInfo;
@property (nonatomic,strong) UITableView * m_tableView;
@property (nonatomic,strong) NSMutableArray * m_arrTableData;
@end

@implementation GroupListViewController

@synthesize m_crowdAndGroupInfo;
@synthesize m_tableView;
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
    [self setBasicCondition];
    [self createNavigationBar:YES];
    
    [self createTableView];
    [self createGroupInfo];
    [self getDisccussionGroupData];
}

- (void)setBasicCondition
{
    m_frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"create" andLeftTitle:@"讨论组" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    [self createGroup];
}

- (void)createGroup
{
    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
    controller.m_type = ADD_GROUP_MEMBERS_NONE;
    [self.navigationController pushViewController:controller animated:YES];
}

// 初始化群和讨论组数据封装类
- (void)createGroupInfo
{
    self.m_crowdAndGroupInfo = [[CrowdAndGroupInfo alloc] init];
    self.m_crowdAndGroupInfo.m_delegate = self;
}

// 获取 讨论组data
- (void)getDisccussionGroupData
{
    [self.m_crowdAndGroupInfo getDisccussionData];
}

// 讨论组 数据源 回调
- (void)sendGroupAllData:(NSMutableArray *)dataArr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_arrTableData = [NSMutableArray arrayWithArray:dataArr];
        [self.m_tableView reloadData];
    });
}

- (void)sendCrowdAllData:(NSMutableArray *)dataArr
{

}

- (void)createTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height - 64;
    if (isIOS7) {
        y += 64;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_arrTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    FriendsAndGroupViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[FriendsAndGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.m_delegate = self;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.m_isCrowd = NO;
    GroupCellData * crowdInfo = (GroupCellData *)[self.m_arrTableData objectAtIndex:indexPath.row];
    [cell setCrowdAndGroupData:crowdInfo];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didSelectRowAtIndexPathWithGroupJid:[self.m_arrTableData objectAtIndex:indexPath.row]];
}

// cell delegate
- (void)cellImageButtonPressed:(UIButton *)button
{
    FriendsAndGroupViewCell * cell = nil;
    if (isIOS7) {
        cell = (FriendsAndGroupViewCell *)button.superview.superview;
    } else {
        cell = (FriendsAndGroupViewCell *)button.superview;
    }
    
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    GroupCellData * crowdInfo = (GroupCellData *)[self.m_arrTableData objectAtIndex:indexPath.row];
    [self pushToCrowdInfoViewControllerWithGroupJid:crowdInfo.m_strGroupId];
}

- (void)pushToCrowdInfoViewControllerWithGroupJid:(NSString *)jid
{
    GroupInfoViewController * controller = [[GroupInfoViewController alloc] init];
    controller.m_groupJid = jid;
    [self.navigationController pushViewController:controller animated:YES];
}

// group cell delegate
- (void)didSelectRowAtIndexPathWithGroupJid:(GroupCellData *)groupCellData;
{
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = groupCellData.m_chatGroupInfo;
    controller.title = groupCellData.m_strGroupName;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.m_crowdAndGroupInfo.m_delegate = nil;
}

@end
