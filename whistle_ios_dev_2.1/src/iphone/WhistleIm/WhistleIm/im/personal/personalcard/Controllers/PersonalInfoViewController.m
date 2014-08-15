//
//  PersonalInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "NBNavigationController.h"
#import "PersonalInfoView.h"
#import "ChangeRemarkViewController.h"
#import "RosterManager.h"
#import "SettingsViewController.h"
#import "EditPersonalInfoViewController.h"
#import "PersonalSettingData.h"
#import "CrowdVoteViewController.h"
#import "LeveyTabBarController.h"
#import "ImUtils.h"
#import "ChangeTextInfoViewController.h"

@interface PersonalInfoViewController ()
<PersonalInfoViewDelegate, RosterDelegate,NBNavigationControllerDelegate>
{
    CGRect m_frame;
    PersonalInfoView * m_personalInfoView;
    FriendInfo * m_myInfo;
    NSMutableArray * m_arrTableData;
}

@property (nonatomic, strong) PersonalInfoView * m_personalInfoView;
@property (nonatomic, strong) FriendInfo * m_myInfo;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@end

@implementation PersonalInfoViewController

@synthesize m_personalInfoView;
@synthesize m_myInfo;
@synthesize m_arrTableData;
@synthesize isPushFromTalkController;

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
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [self setbasicCondition];
    [self createNavigationBar:YES];

    [[RosterManager shareInstance] addListener:self];
    [[RosterManager shareInstance] getMyself];

    [self setTableDataArr];
    [self createPersonalInfoView];
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
    [nav setNavigationController:self leftBtnType:isPushFromTalkController?@"back":nil andRightBtnType:nil andLeftTitle:@"我" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)setTableDataArr
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    [self.m_arrTableData addObject:[self getSecodnSectionArr]];
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];

    PersonalSettingData * settingData = [[PersonalSettingData alloc] init];
    settingData.m_title = @"个性签名";
    settingData.m_content = self.m_myInfo.moodWords;
    settingData.m_cellHeight = 45;
    settingData.m_hasHeaderLine = YES;
    settingData.m_hasLabel = YES;
    settingData.m_hasIndicator = YES;
    
    [sectionArr addObject:settingData];
    
    PersonalSettingData * data = [[PersonalSettingData alloc] init];
    data.m_title = @"编辑资料";
    data.m_cellHeight = 45.0f;
    data.m_hasHeaderLine = NO;
    data.m_hasIndicator = YES;

    [sectionArr addObject:data];
    return  sectionArr;
}

- (NSMutableArray *)getSecodnSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];

    PersonalSettingData * data = [[PersonalSettingData alloc] init];
    data.m_title = @"设置";
    data.m_cellHeight = 45.0f;
    data.m_hasHeaderLine = YES;
    data.m_hasIndicator = YES;
    
    [sectionArr addObject:data];
    return  sectionArr;
}

- (void)createPersonalInfoView
{
    CGFloat y = 0.0f;
    
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44 - 49;
    self.m_personalInfoView = [[PersonalInfoView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withTableDataArr:self.m_arrTableData];
    self.m_personalInfoView.m_delegate = self;
    [self.view addSubview:self.m_personalInfoView];
}

// PersonalInfoView delegate
- (void)cellDidSelected:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self changeRemark];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self editPersonalInfo];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self personalSetting];
    }
}

- (void)changeRemark
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = @"个性签名";
    controller.m_placeHolder = self.m_myInfo.moodWords;
    controller.m_numberOfWords = 50;
    controller.m_type = @"myMoodWords";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)editPersonalInfo
{
    EditPersonalInfoViewController * controller = [[EditPersonalInfoViewController alloc] init];
    controller.m_friendInfo = self.m_myInfo;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)personalSetting
{
    SettingsViewController * controller = [[SettingsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateMyInfo:(FriendInfo *)my
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_myInfo = my;
        [self resetMoodWordsWithFriendInfo:self.m_myInfo];
        [self.m_personalInfoView refreshViews:self.m_myInfo andTableDataArr:self.m_arrTableData];
    });
}

- (void)resetMoodWordsWithFriendInfo:(FriendInfo *)friendInfo
{
    NSMutableArray * sectionArr = nil;
    if ([self.m_arrTableData count] > 0) {
        sectionArr = [self.m_arrTableData objectAtIndex:0];
    }
    
    if ([sectionArr count] > 0) {
        PersonalSettingData * settingData = [sectionArr objectAtIndex:0];
        settingData.m_content = friendInfo.moodWords;
        CGSize textSize = [friendInfo.moodWords sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        
        
        if (textSize.height < 30) {
            settingData.m_cellHeight = 45;
        } else {
            settingData.m_cellHeight = textSize.height + 10;
        }
        settingData.m_textHeight = textSize.height;
        NSLog(@"textSize for sign == %@", NSStringFromCGSize(textSize));
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

-(void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenPersonalTab" object:[NSNumber numberWithBool:NO]];
    [self.navigationController popViewControllerAnimated:YES];
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
