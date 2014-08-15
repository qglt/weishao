//
//  AddMembersAndPerfectInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-12.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddMembersAndPerfectInfoViewController.h"
#import "PersonalTableViewCell.h"
#import "PersonalSettingData.h"
#import "ImUtils.h"
#import "NBNavigationController.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "CrowdInfoViewController.h"
#import "CrowdListViewController.h"
#import "AddRostersViewController.h"
#import "Toast.h"

#define HEADER_HEIGHT 8.0f
#define ADD_CROWD_MEMBERS @"addCrowdMembers"


@interface AddMembersAndPerfectInfoViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@end

@implementation AddMembersAndPerfectInfoViewController

@synthesize m_arrTableData;
@synthesize m_tableView;
@synthesize m_crowdSessionID;
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
    [self setbasicCondition];
    [Toast show:@"创建群成功"];
    [self createNavigationBar:YES];
    [self setMemoryData];
    [self createTableView];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"编辑资料" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{    
    [self popToCorrespondingViewController];
}

- (void)popToCorrespondingViewController
{
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

- (void)setMemoryData
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    [self.m_arrTableData addObject:[self getSecondSectionArr]];
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * addMembers = [[PersonalSettingData alloc] init];
    addMembers.m_title = @"添加群成员";
    addMembers.m_cellHeight = 45;
    addMembers.m_hasHeaderLine = YES;
    addMembers.m_hasIndicator = YES;
    [sectionArr addObject:addMembers];
    
    return  sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * perfectCrowd = [[PersonalSettingData alloc] init];
    perfectCrowd.m_title = @"完善群资料";
    perfectCrowd.m_cellHeight = 45.0f;
    perfectCrowd.m_hasHeaderLine = YES;
    perfectCrowd.m_hasIndicator = YES;
    [sectionArr addObject:perfectCrowd];
    
    return  sectionArr;
}

- (void)createTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 64) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.scrollEnabled = NO;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.m_arrTableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * data = [eachSectionArr objectAtIndex:indexPath.row];
    return data.m_cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"addOrPerfect";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    [cell setCellWithSettingData:settingData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self addCrowdMembers];
    } else if (indexPath.section == 1) {
        [self perfectCrowdInfo];
    }
}

- (void)addCrowdMembers
{
    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
    controller.m_type = ADD_CROWD_MEMBERS;
    controller.m_crowdSessionID = self.m_crowdSessionID;
    controller.m_maxLimit = self.m_maxLimit;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)perfectCrowdInfo
{
    CrowdInfoViewController * controller = [[CrowdInfoViewController alloc] init];
    controller.m_crowdSessionID = self.m_crowdSessionID;
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

@end
