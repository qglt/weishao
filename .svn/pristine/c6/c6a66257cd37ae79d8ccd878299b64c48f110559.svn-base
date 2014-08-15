//
//  WhistleAppDelegate.m
//  WhistleIm
//
//  Created by wangchao on 13-6-21.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "WhistleAppDelegate.h"
#import "NBNavigationController.h"
#import "LoginViewController.h"
#import "WelcomeViewController.h"
#import "Manager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "LocalNotificationOnBackground.h"
#import <SDWebImage/SDImageCache.h>
#import "CacheManager.h"
#import "APIKey.h"
#import <MAMapKit/MAMapKit.h>

@interface WhistleAppDelegate ()

@end

//BMKMapManager* _mapManager;

#define SOUND_TYPE_COUNT 4
UIBackgroundTaskIdentifier taskID;
static BOOL isRegisterLocalNotify_ = NO;
@implementation WhistleAppDelegate


- (void)configureAPIKey
{
    
    if ([APIKey length] == 0)
    {
        NSString *name   = [NSString stringWithFormat:@"\nSDKVersion:%@\nFILE:%s\nLINE:%d\nMETHOD:%s", [MAMapServices sharedServices].SDKVersion, __FILE__, __LINE__, __func__];
        NSString *reason = [NSString stringWithFormat:@"请首先配置APIKey.h中的APIKey, 申请APIKey参考见 http://api.amap.com"];
        
        @throw [NSException exceptionWithName:name
                                       reason:reason
                                     userInfo:nil];
    }
    
    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
    
    /*
    // 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:@"qhrCEXFUZxjXNGNmbQQGqATb" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    */

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Manager appInit];
    [self configureAPIKey];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);//设置程序崩溃处理
    
    //INIT IMAGE CACHE
    NSString *bundledPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CustomPathImages"];
    
    BOOL isDir = NO;
    
    if ( !(isDir && [[NSFileManager defaultManager] fileExistsAtPath:bundledPath isDirectory:&isDir]) )
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:bundledPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [[SDImageCache sharedImageCache] addReadOnlyCachePath:bundledPath];
    
    isRegisterLocalNotify_ = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self setAudioSetting];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (!isIOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString * first = [userDefault objectForKey:@"first"];
    if (first == nil) {
        WelcomeViewController * controller = [[WelcomeViewController alloc] init];
        NBNavigationController * nav = [[NBNavigationController alloc] initWithRootViewController:controller];
        [nav setNavigationBarHidden:YES];
        [self.window setRootViewController:nav];
        [userDefault setObject:@"first" forKey:@"first"];
        [userDefault synchronize];
    } else {
        LoginViewController * controller = [LoginViewController shareInstance];//[[LoginViewController alloc] init];
        NBNavigationController * nav = [[NBNavigationController alloc] initWithRootViewController:controller];
        [nav setNavigationBarHidden:YES];
        [self.window setRootViewController:nav];
    }
    
    NSUserDefaults * userSetting = [NSUserDefaults standardUserDefaults];
    NSArray * arr = [userSetting objectForKey:@"soundSetting"];
    if (arr == nil) {
        [self setPromptToneDefault];
    }
    

    
    
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    NSString * themeType = [themeDefault objectForKey:@"theme"];
    if (themeType == nil) {
        [self setTheme];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setPromptToneDefault
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray * soundArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < SOUND_TYPE_COUNT; i++) {
        if (i == 2) {
            [soundArr addObject:[NSNumber numberWithBool:YES]];
        } else {
            [soundArr addObject:[NSNumber numberWithBool:NO]];
        }
    
    }
    NSLog(@"sound array in appdelegate== %@", soundArr);
    
    [userDefault setObject:soundArr forKey:@"soundSetting"];
    
//    NSArray * arr = [userDefault objectForKey:@"soundSetting"];
//    NSLog(@"arr arrarrarr appdelegate == %@", arr);
}

- (void)setAudioSetting
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)setTheme
{
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    [themeDefault setObject:@"blue" forKey:@"theme"];
    [themeDefault synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    LOG_NETWORK_DEBUG(@"程序进入后台");
    taskID = UIBackgroundTaskInvalid;
    UIApplication* app = [UIApplication sharedApplication];
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        LOG_NETWORK_ERROR(@"后台运行时间将耗尽");
        [app endBackgroundTask:taskID];
        taskID = UIBackgroundTaskInvalid;
    }];
    if (!isRegisterLocalNotify_) {
        [[LocalNotificationOnBackground shareInstance] registerListener];
        isRegisterLocalNotify_ = YES;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

void uncaughtExceptionHandler(NSException *exception) {
    LOG_GENERAL_FATAL(@"程序崩溃信息：%@", exception);
    LOG_GENERAL_FATAL(@"程序崩溃栈信息：%@", [exception callStackSymbols]);
    LoggerFlush(NULL, YES);
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[CacheManager shareInstance] serialization];
}

@end
