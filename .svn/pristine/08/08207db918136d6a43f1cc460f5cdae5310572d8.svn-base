//
//  CrowdListViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdListViewController.h"
#import "FriendsAndGroupView.h"
#import "CrowdAndGroupInfo.h"
#import "FriendsAndGroupViewCell.h"
#import "PrivateTalkViewController.h"
#import "NBNavigationController.h"
#import "CrowdInfoViewController.h"
#import "ImUtils.h"
#import "CreateCrowdViewController.h"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"

#define ADD_CROWD_MEMBERS @"addCrowdMembers"
#define ADD_GROUP_MEMBERS_NONE @"addGroupMembersNone"
#define ADD_GROUP_MEMBERS_DEFAULT @"addGroupMembersDefault"

@interface CrowdListViewController ()
<FriendsAndGroupViewDelegate, CrowdAndGroupInfoDelegate, UITableViewDataSource, UITableViewDelegate, FriendsAndGroupViewCellDelegate>
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

@implementation CrowdListViewController

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

    [self createCrowdInfo];
    [self getCrowdData];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"create" andLeftTitle:@"群" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    [self createCrowd];
}

- (void)createCrowd
{
    CreateCrowdViewController * controller = [[CreateCrowdViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

// 初始化群和讨论组数据封装类
- (void)createCrowdInfo
{
    self.m_crowdAndGroupInfo = [[CrowdAndGroupInfo alloc] init];
    self.m_crowdAndGroupInfo.m_delegate = self;
}

// 获取 群data
- (void)getCrowdData
{
    [self.m_crowdAndGroupInfo getCrowdData];
}

// 群 数据源 回调
- (void)sendCrowdAllData:(NSMutableArray *)dataArr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_arrTableData = [NSMutableArray arrayWithArray:dataArr];
        [self.m_tableView reloadData];
    });
}

- (void)sendGroupAllData:(NSMutableArray *)dataArr
{

}

- (void)createTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height - 64;
    if (isIOS7) {
        y += 64;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, 320, height) style:UITableViewStylePlain];
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
    cell.m_isCrowd = YES;
    CrowdInfo * crowdInfo = (CrowdInfo *)[self.m_arrTableData objectAtIndex:indexPath.row];
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
    
    // 冻结了  NSInteger status;//0-正常，1-冻结
    CrowdInfo * crowdInfo = [self.m_arrTableData objectAtIndex:indexPath.row];
    if (crowdInfo.status == 0) {
        [self didSelectRowAtIndexPathWithCrowdInfo:crowdInfo];
    } else if (crowdInfo.status == 1){  // 冻结了
        [[[CustomAlertView alloc] initWithTitle:@"系统提示" message:@"操作失败，该群已被冻结" delegate:nil cancelButtonTitle:nil confrimButtonTitle:@"确定"] show];
    }
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
    CrowdInfo * crowdInfo = (CrowdInfo *)[self.m_arrTableData objectAtIndex:indexPath.row];
    
    if (crowdInfo.status == 0) {
        [self gotoCrowdInfoViewControllerWith:crowdInfo];
    }  else if (crowdInfo.status == 1){  // 冻结了
        [[[CustomAlertView alloc] initWithTitle:@"系统提示" message:@"操作失败，该群已被冻结" delegate:nil cancelButtonTitle:nil confrimButtonTitle:@"确定"] show];
    }
}

- (void)didSelectRowAtIndexPathWithCrowdInfo:(CrowdInfo *)crowdInfo
{
    PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = crowdInfo;
    controller.title = crowdInfo.name;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoCrowdInfoViewControllerWith:(CrowdInfo *)crowdInfo
{
    CrowdInfoViewController * controller = [[CrowdInfoViewController alloc] init];
    controller.m_crowdInfo = crowdInfo;
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
