//
//  MyTabBarViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "ConversationViewController.h"
#import "GroupViewController.h"
#import "NotificationViewController.h"
#import "SettingViewController.h"
#import "NBNavigationController.h"
#import "ImNoticeViewController.h"
#import "ImRosterViewController.h"
#import "PersonalInfoViewController.h"
#import "PromptToneSetting.h"
#import "WhistleAppDelegate.h"
#import "AppCenterViewController.h"
#import "LeveyTabBarController.h"
#import "ReceivedNewInfo.h"

@interface MyTabBarViewController ()
<ReceivedNewInfoDelegate>
{
    LeveyTabBarController * m_leveyTabBarController;
    ReceivedNewInfo * m_newInfo;
    
    BOOL m_hiddenPersonalTab;
}

@property (nonatomic, strong) LeveyTabBarController * m_leveyTabBarController;
@property (nonatomic, strong) ReceivedNewInfo * m_newInfo;

@end

@implementation MyTabBarViewController
@synthesize m_leveyTabBarController;
@synthesize m_newInfo;

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
    [self addNotifications];
    [self createSubViews];
    [self createUnreadInfo];
}

- (void)createUnreadInfo
{
    self.m_newInfo = [[ReceivedNewInfo alloc] init];
    self.m_newInfo.m_delegate = self;
}

// ReceivedNewInfo delegate
- (void)hiddenOrShowRedSpotIndicatorWithIndex:(NSUInteger)index andIsHidden:(BOOL)hidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_leveyTabBarController showRedSpotIndicatorWithIndex:index andIsHidden:hidden];
    });
}

- (void)createSubViews
{
	NSArray * ctrlArr = [self getNavController];
    NSArray * imgArr = [self getNavControllerConfig];
    NSArray * titleArr = [self getTitles];
    
	self.m_leveyTabBarController = [[LeveyTabBarController alloc] initWithViewControllers:ctrlArr imageArray:imgArr andTitleArr:titleArr];
    [self.m_leveyTabBarController.tabBar setBackgroundImage:[self getTabBarBGImage]];

	[self.m_leveyTabBarController setTabBarTransparent:YES];
    [self.view addSubview:self.m_leveyTabBarController.view];
}

- (UIImage *)getTabBarBGImage
{
    UIImage * image = nil;
    
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    NSString * themeType = [themeDefault objectForKey:@"theme"];
    
    if ([themeType isEqualToString:@"blue"]) {
        image = [UIImage imageNamed:@"blue_tabbar.png"];
    } else if ([themeType isEqualToString:@"red"]) {
        image = [UIImage imageNamed:@"red_tabbar.png"];
    } else if ([themeType isEqualToString:@"black"]) {
        image = [UIImage imageNamed:@"black_tabbar.png"];
    }
    
    return image;
}

- (NSArray *)getNavController
{
    AppCenterViewController * appCenterVC = [[AppCenterViewController alloc] init];
    NBNavigationController * appCenterNav = [[NBNavigationController alloc] initWithRootViewController:appCenterVC];
    appCenterNav.delegate = (id)self;
    
	ConversationViewController * conversationVC = [[ConversationViewController alloc] init];
    NBNavigationController * conversationNav = [[NBNavigationController alloc] initWithRootViewController:conversationVC];
    conversationNav.delegate = (id)self;
    
    
	ImRosterViewController * rosterVC = [[ImRosterViewController alloc] init];
    NBNavigationController * rosterNav = [[NBNavigationController alloc] initWithRootViewController:rosterVC];
    rosterNav.delegate = (id)self;
    
	ImNoticeViewController * noticeVC = [[ImNoticeViewController alloc] init];
    NBNavigationController * noticeNav = [[NBNavigationController alloc] initWithRootViewController:noticeVC];
    noticeNav.delegate = (id)self;
    
    PersonalInfoViewController * personalVC = [[PersonalInfoViewController alloc] init];
    NBNavigationController * personalNav = [[NBNavigationController alloc] initWithRootViewController:personalVC];
    personalNav.delegate = (id)self;
    
	NSArray * ctrlArr = [NSArray arrayWithObjects:appCenterNav, conversationNav, rosterNav, noticeNav, personalNav, nil];
    return ctrlArr;
}

- (NSArray *)getNavControllerConfig
{
    NSMutableDictionary * appDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [appDict setObject:[UIImage imageNamed:@"appItemNormal.png"] forKey:@"Default"];
	[appDict setObject:[UIImage imageNamed:@"appItemSelected.png"] forKey:@"Highlighted"];
	[appDict setObject:[UIImage imageNamed:@"appItemSelected.png"] forKey:@"Seleted"];
    
	NSMutableDictionary * conversationDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [conversationDict setObject:[UIImage imageNamed:@"infoItemNormal.png"] forKey:@"Default"];
	[conversationDict setObject:[UIImage imageNamed:@"infoItemSelected.png"] forKey:@"Highlighted"];
	[conversationDict setObject:[UIImage imageNamed:@"infoItemSelected.png"] forKey:@"Seleted"];
    
	NSMutableDictionary * rosterDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [rosterDict setObject:[UIImage imageNamed:@"contactsItemNormal.png"] forKey:@"Default"];
	[rosterDict setObject:[UIImage imageNamed:@"contactsItemSelected.png"] forKey:@"Highlighted"];
	[rosterDict setObject:[UIImage imageNamed:@"contactsItemSelected.png"] forKey:@"Seleted"];
    
	NSMutableDictionary * noticeDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [noticeDict setObject:[UIImage imageNamed:@"dynamicItemNormal.png"] forKey:@"Default"];
	[noticeDict setObject:[UIImage imageNamed:@"dynamicItemSelected.png"] forKey:@"Highlighted"];
	[noticeDict setObject:[UIImage imageNamed:@"dynamicItemSelected.png"] forKey:@"Seleted"];
    
    NSMutableDictionary * personalDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [personalDict setObject:[UIImage imageNamed:@"mineItemNormal.png"] forKey:@"Default"];
	[personalDict setObject:[UIImage imageNamed:@"mineItemSelected.png"] forKey:@"Highlighted"];
	[personalDict setObject:[UIImage imageNamed:@"mineItemSelected.png"] forKey:@"Seleted"];
	
	NSArray * imgArr = [NSArray arrayWithObjects:appDict, conversationDict, rosterDict, noticeDict, personalDict, nil];
    return imgArr;
}

- (NSArray *)getTitles
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"应用", @"消息", @"联系人", @"动态", @"我", nil];
    return titleArr;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController isKindOfClass:[AppCenterViewController class]]) {
        [self.m_leveyTabBarController hidesTabBar:NO animated:YES];
	} else if ([viewController isKindOfClass:[ConversationViewController class]]){
        [self.m_leveyTabBarController hidesTabBar:NO animated:YES];
    } else if ([viewController isKindOfClass:[ImRosterViewController class]]){
        [self.m_leveyTabBarController hidesTabBar:NO animated:YES];
    } else if ([viewController isKindOfClass:[ImNoticeViewController class]]){
        [self.m_leveyTabBarController hidesTabBar:NO animated:YES];
    } else if ([viewController isKindOfClass:[PersonalInfoViewController class]]){
        [self.m_leveyTabBarController hidesTabBar:m_hiddenPersonalTab animated:YES];
        NSLog(@"PersonalInfoViewController viewWillAppear");
    }
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promptPlay) name:@"playPromptNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenPersonalTab:) name:@"hiddenPersonalTab" object:nil];
}

- (void)hiddenPersonalTab:(NSNotification *)notification
{
    NSNumber * hidden = notification.object;
    m_hiddenPersonalTab = [hidden boolValue];
}

- (void)changeTheme:(NSNotification *)notification
{
    [self.m_leveyTabBarController.tabBar setBackgroundImage:[self getTabBarBGImage]];
}

- (void)promptPlay
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSArray * arr = [userDefault objectForKey:@"soundSetting"];
    NSLog(@"system setting arr in ImCoreViewController == %@", arr);
    BOOL type = NO;
    NSInteger index = -1;
    for (NSUInteger i = 0; i < [arr count]; i++) {
        NSNumber * promptType = [arr objectAtIndex:i];
        type = [promptType boolValue];
        if (type) {
            index = i;
            break;
        }
    }
    
    NSString * settingType = nil;
    if (index >= 0 && type == YES) {
        
        // 0,声音；1，震动；2，声音和震动；3无提示
        if (index == 0) {
            settingType = TONE_TYPE;
        } else if (index == 1) {
            settingType = SHAKE_TYPE;
        } else if (index == 2) {
            settingType = TONE_AND_SHAKE_TYPE;
        } else if (index == 3) {
            NSLog(@"settingType == %@ index == %d", settingType, index);
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PromptToneSetting * setting = [PromptToneSetting sharedInstance];
        setting.m_promptType = settingType;
        [setting playPromptToneOrShake];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playPromptNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeTheme" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hiddenPersonalTab" object:nil];
}

@end
