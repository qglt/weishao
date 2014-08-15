//
//  AddRostersViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AddRostersViewController.h"
#import "AddFriendsViewController.h"
#import "AddCrowdViewController.h"
#import "GetFrame.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "CreateCrowdViewController.h"
#import "PersonalSettingData.h"
#import "PersonalTableViewCell.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "CrowdManager.h"

#define LEFT_ITEM_TAG 2000
#define HEADER_HEIGHT 8.0f
#define ADD_GROUP_MEMBERS_NONE @"addGroupMembersNone"


@interface AddRostersViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@end

@implementation AddRostersViewController

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
    [self setbasicCondition];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"添加" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setMemoryData
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    [self.m_arrTableData addObject:[self getSecondSectionArr]];
    [self.m_arrTableData addObject:[self getThirdSectionArr]];
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * addFriend = [[PersonalSettingData alloc] init];
    addFriend.m_title = @"加好友";
    addFriend.m_cellHeight = 45;
    addFriend.m_hasHeaderLine = YES;
    addFriend.m_hasIndicator = YES;
    [sectionArr addObject:addFriend];
    
    return  sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * createGroup = [[PersonalSettingData alloc] init];
    createGroup.m_title = @"创建讨论组";
    createGroup.m_cellHeight = 45.0f;
    createGroup.m_hasHeaderLine = YES;
    createGroup.m_hasIndicator = YES;
    [sectionArr addObject:createGroup];
    
    return  sectionArr;
}

- (NSMutableArray *)getThirdSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    PersonalSettingData * addCrowd = [[PersonalSettingData alloc] init];
    addCrowd.m_title = @"添加群";
    addCrowd.m_hasHeaderLine = YES;
    addCrowd.m_cellHeight = 45;
    addCrowd.m_hasIndicator = YES;

    [sectionArr addObject:addCrowd];
    
    PersonalSettingData * createCrowd = [[PersonalSettingData alloc] init];
    createCrowd.m_title = @"创建群";
    createCrowd.m_cellHeight = 45;
    createCrowd.m_hasIndicator = YES;

    [sectionArr addObject:createCrowd];
    
    return sectionArr;
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
        [self addFriend];
    } else if (indexPath.section == 1) {
        [self createGroup];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self addCrowd];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self createCrowd];
    }
}

- (void)addFriend
{
    AddFriendsViewController * addController = [[AddFriendsViewController alloc] init];
    [addController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)createGroup
{
    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
    controller.m_type = ADD_GROUP_MEMBERS_NONE;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addCrowd
{
    AddCrowdViewController * controller = [[AddCrowdViewController alloc]init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createCrowd
{
    CreateCrowdViewController * controller = [[CreateCrowdViewController alloc] init];
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

@end
