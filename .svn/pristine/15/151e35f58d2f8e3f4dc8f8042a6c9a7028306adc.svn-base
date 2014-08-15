//
//  SettingsViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "SettingsViewController.h"
#import "NBNavigationController.h"
#import "PersonalTableViewCell.h"
#import "AboutOurViewController.h"
#import "FeedbackViewController.h"
#import "WhistleAppDelegate.h"
#import "LoginViewController.h"
#import "AccountManager.h"
#import "PersonalSettingData.h"
#import "ChangeThemeViewController.h"
#import "ImUtils.h"
#import "NetworkBrokenAlert.h"

#define SOUND_TYPE_COUNT 4
#define HEADER_HEIGHT 8.0f


@interface SettingsViewController ()
<UITableViewDataSource, UITableViewDelegate, PersonalTableViewCellDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    NSMutableArray * m_arrSwitchState;
}
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableArray * m_arrSwitchState;



@end

@implementation SettingsViewController
@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_arrSwitchState;

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
    [self setSwitchStateArr];
    [self setMemoryData];
    
    [self createTableView];
    [self createChangeAccountButton];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"设置" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSwitchStateArr
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray * defaultStateArr = (NSMutableArray *)[userDefault objectForKey:@"soundSetting"];
    self.m_arrSwitchState  = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (defaultStateArr == nil) {
        [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
        [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
    } else {
        NSInteger index = -1;
        BOOL type = NO;
        for (NSUInteger i = 0; i < [defaultStateArr count]; i++) {
            NSNumber * promptType = [defaultStateArr objectAtIndex:i];
            type = [promptType boolValue];
            if (type) {
                index = i;
                break;
            }
        }
        
        if (index >= 0) {
            if (index == 0) {
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:NO]];
            } else if (index == 1) {
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:NO]];
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
            } else if (index == 2) {
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:YES]];
            } else if (index == 3) {
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:NO]];
                [self.m_arrSwitchState addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    
    NSLog(@"m_arrSwitchState == %@", self.m_arrSwitchState);
}

- (void)setMemoryData
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    [self.m_arrTableData addObject:[self getSecondSectionArr]];
    
    if ( [[AccountManager shareInstance] isCanChangePwd]) {
        [self.m_arrTableData addObject:[self getThirdSectionArr]];
    }
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * themeData = [[PersonalSettingData alloc] init];
    themeData.m_title = @"主题设置";
    themeData.m_cellHeight = 45;
    themeData.m_hasHeaderLine = YES;
    themeData.m_hasIndicator = YES;
    [sectionArr addObject:themeData];
    
    PersonalSettingData * soundData = [[PersonalSettingData alloc] init];
    soundData.m_title = @"声音";
    soundData.m_cellHeight = 45;
    soundData.m_hasSwitch = YES;
    soundData.m_switchState = [[self.m_arrSwitchState objectAtIndex:0] floatValue];
    [sectionArr addObject:soundData];
    
    PersonalSettingData * shakeData = [[PersonalSettingData alloc] init];
    shakeData.m_title = @"震动";
    shakeData.m_cellHeight = 45;
    shakeData.m_hasSwitch = YES;
    shakeData.m_switchState = [[self.m_arrSwitchState objectAtIndex:1] floatValue];
    [sectionArr addObject:shakeData];
    
    return  sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * aboutData = [[PersonalSettingData alloc] init];
    aboutData.m_title = @"关于";
    aboutData.m_cellHeight = 45.0f;
    aboutData.m_hasHeaderLine = YES;
    aboutData.m_hasIndicator = YES;
    
    [sectionArr addObject:aboutData];
    
    PersonalSettingData * adviceData = [[PersonalSettingData alloc] init];
    adviceData.m_title = @"意见反馈";
    adviceData.m_cellHeight = 45.0f;
    adviceData.m_hasIndicator = YES;
    
    [sectionArr addObject:adviceData];
    return  sectionArr;
}

- (NSMutableArray *)getThirdSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    PersonalSettingData * passWordData = [[PersonalSettingData alloc] init];
    passWordData.m_title = @"修改密码";
    passWordData.m_hasHeaderLine = YES;
    passWordData.m_cellHeight = 45;
    passWordData.m_hasIndicator = YES;
    
    [sectionArr addObject:passWordData];
    
    return sectionArr;
}

- (void)createTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    CGFloat height = 0.0f;
    if ( [[AccountManager shareInstance] isCanChangePwd]) {
        height = HEADER_HEIGHT * 3 + 45 * 6;
    } else {
        height = HEADER_HEIGHT * 2 + 45 * 5;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) style:UITableViewStylePlain];
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
    static NSString * cellID = @"personal";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.m_delegate = self;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 1 || indexPath.row == 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
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
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self gotoAboutViewController];
        } else if (indexPath.row == 1) {
            [self gotoFeedBackViewController];
        }
    } else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self gotoChangeThemeViewController];
        }
    }else if (indexPath.section == 2 && indexPath.row == 0){
        
        if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
            return;
        }
        
        [[AccountManager shareInstance] changePwd:^(NSString *url) {
            if (url) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];                
            }
        }];
    }
}

- (void)gotoAboutViewController
{
    AboutOurViewController * controller = [[AboutOurViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoFeedBackViewController
{
    FeedbackViewController * controller = [[FeedbackViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoChangeThemeViewController
{
    ChangeThemeViewController * controller = [[ChangeThemeViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createChangeAccountButton
{
    CGFloat height = 0.0f;
    if ( [[AccountManager shareInstance] isCanChangePwd]) {
        height = HEADER_HEIGHT * 3 + 45 * 6;
    } else {
        height = HEADER_HEIGHT * 2 + 45 * 5;
    }
    CGFloat y = height + HEADER_HEIGHT;
    if (isIOS7) {
        y += 64.0f;
    }
    // redBtnImageNormal.png   redBtnImageHighLight.png
    UIButton * button = [self createButtonsWithFrame:CGRectMake(0, y, m_frame.size.width, 45) andTitle:@"退出当前账号" andImage:@"redBtnImageNormal.png" andSelectedImage:@"redBtnImageHighLight.png" andTag:1000];
    [self.view addSubview:button];
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(functionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)functionButtonPressed:(UIButton *)button
{
    [self changeAccountButtonPressed];
}

- (void)changeAccountButtonPressed
{
    [[AccountManager shareInstance] changeUser];
    [LoginViewController shareInstance].m_isChangeAccount = YES;
    WhistleAppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    NBNavigationController * navigationController = (NBNavigationController *)delegate.window.rootViewController;
    [navigationController popToViewController:[LoginViewController shareInstance] animated:YES];
}


- (void)switchClicked:(id)sender
{
    UISwitch * mySwitch = (UISwitch *)sender;
    PersonalTableViewCell * cell = nil;
    if (isIOS7) {
        cell = (PersonalTableViewCell *)mySwitch.superview.superview;
    } else {
        cell = (PersonalTableViewCell *)mySwitch.superview;
    }
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    [self.m_arrSwitchState replaceObjectAtIndex:indexPath.row - 1 withObject:[NSNumber numberWithBool:mySwitch.on]];
    
    NSMutableArray * soundArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < SOUND_TYPE_COUNT; i++) {
        [soundArr addObject:[NSNumber numberWithBool:NO]];
    }
    BOOL isSound = NO;
    BOOL isShake = NO;
    for (NSUInteger i = 0; i < [self.m_arrSwitchState count]; i++) {
        BOOL state = [[self.m_arrSwitchState objectAtIndex:i] boolValue];
        if (i == 0) {
            isSound = state;
        } else if (i == 1) {
            isShake = state;
        }
    }
    
    if (isSound && !isShake) {
        [soundArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
    } else if (!isSound && isShake) {
        [soundArr replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
    } else if (isSound && isShake) {
        [soundArr replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:YES]];
    } else if (!isSound && !isShake) {
        [soundArr replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
    }
    
    NSLog(@"sound array == %@", soundArr);

    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:soundArr forKey:@"soundSetting"];
    [userDefault synchronize];
    NSArray * arr = [userDefault objectForKey:@"soundSetting"];
    NSLog(@"arr arrarrarr == %@", arr);
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
