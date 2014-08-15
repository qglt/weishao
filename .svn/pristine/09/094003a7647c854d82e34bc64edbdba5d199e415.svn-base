//
//  LoginViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "LoginViewController.h"
#import "MyTabBarViewController.h"
#import "CircularHeaderImageView.h"
#import "LoginTextView.h"
#import "ImageUtil.h"
#import "CheckBoxView.h"
#import "AccountManager.h"
#import "AccountInfo.h"
#import "NoticeManager.h"
#import "AppMessageManager.h"
#import "RosterManager.h"
#import "CrowdManager.h"
#import "CloudConfigurationController.h"
#import "RemoteConfigInfo.h"
#import "LocalRecentListManager.h"
#import "SystemMsgManager.h"
#import "GetFrame.h"
#import "AppManager.h"
#import "SelectSchoolTableViewController.h"
#import "ImUtils.h"
#import "LoginView.h"
#import "Toast.h"

@interface LoginViewController ()
<LoginStateDelegate, LoginViewDelegate>
{
    //liuke
    LoginView* view_;
    AccountInfo * currentAccount_;
    NSMutableArray* otherAccount_;
}

@end

@implementation LoginViewController

SINGLETON_IMPLEMENT(LoginViewController)

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
    self.m_isChangeAccount = NO;
    view_ = [[LoginView alloc] init];
    view_.delegate = self;
    [self.view addSubview:view_];
}



- (void) login:(NSString *)user pwd:(NSString *)pwd savepwd:(BOOL)save invisible:(BOOL)invisible
{
    if ([@"" isEqualToString:user] || [@"" isEqualToString:pwd]) {
        [view_ loading:NO];
        [Toast show:@"请输入账号或密码"];
    }else{
        [view_ loading:YES];
        [[AccountManager shareInstance] addListener:self];
        [[AccountManager shareInstance] login:user withPwd:pwd SavePWD:save invisible:invisible];
    }
}

- (void) deleteAccount:(NSString *)user
{
    [[AccountManager shareInstance] deleteAccount:user callback:^(BOOL isSucess) {
        if (isSucess) {
            [self getLoginHistory];
        }
    }];
}

#pragma mark -

#pragma mark LoginStateDelegate

- (void)disconnected:(NSDictionary*) data
{
    NSLog(@"disconnected");
}

- (void)loginSucess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [view_ loading:NO];
        [self createMainPage];
        LOG_UI_DEBUG(@"登录成功,启动主界面");
    });
    [[AccountManager shareInstance] removeListener:self];
}

- (void)loginFailure:(NSDictionary*) data
{
    NSLog(@"loginFailure");
    ResultInfo* result = [[AccountManager shareInstance] parseCommandResusltInfo:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [view_ loading:NO];
        [self createAlertView: result.errorMsg];
//        [self clearBGImageView];
    });
}
- (void) recvCloudConfig:(NSArray*) list
{
    //实现代理，确定是否展示推荐学校
    dispatch_async(dispatch_get_main_queue(), ^{
        
        RemoteConfigInfo *object = nil;
        for (RemoteConfigInfo *remoteConfigObj in list) {
            if (remoteConfigObj.isRecommand) {
                object = remoteConfigObj;
                break;
            }
        }
        if (!object) {
            [self createSearchSchool:list];
        }else{

            [self createCloudConfigurationView:object searchSchool:list];
        }
    });

}
- (void)createSearchSchool:(NSArray *)list{
    SelectSchoolTableViewController *VC = [[SelectSchoolTableViewController alloc] init];
    VC.tableDataArray = [NSMutableArray arrayWithArray:list];
    VC.remoteConfigObj = nil;
    [self.navigationController pushViewController:VC animated:YES];
//    [self presentViewController:VC animated:YES completion:^{
//        
//    }];
//    [self addChildViewController:VC];
//    VC.view.frame = self.view.bounds;
//    [self.view addSubview: VC.view];
//    [VC didMoveToParentViewController:self];
}
- (void)createCloudConfigurationView:(RemoteConfigInfo *)remoteConfigObj searchSchool:(NSArray *)list
{
    CloudConfigurationController *cloudConfigVC = [[CloudConfigurationController alloc] init];
    cloudConfigVC.remoteConfigObj = remoteConfigObj;
    cloudConfigVC.remoteConfigArray = [NSMutableArray arrayWithArray:list];
    [self.navigationController pushViewController:cloudConfigVC animated:YES];
}

- (void)createAlertView:(NSString *)title
{
    [self.navigationController setNavigationBarHidden:YES];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)createMainPage
{
    LOG_UI_DEBUG(@"loginviewcon1:%@",self.navigationController.viewControllers);

    [self.navigationController setNavigationBarHidden:YES];
    MyTabBarViewController * tabBarController = [[MyTabBarViewController alloc] init];
    LOG_UI_DEBUG(@"loginviewcon2:%@",self.navigationController.viewControllers);

    [self.navigationController pushViewController:tabBarController animated:NO];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    LOG_UI_DEBUG(@"loginviewcon3:%@",self.navigationController.viewControllers);

}



- (void) setCurrentAccount:(AccountInfo*) account
{
    view_.currentAccount = account;
    view_.user = [account.userName copy];
    view_.pwd = [account.password copy];
    view_.rememberPwd = account.savePasswd;
    view_.head = [account.headImg copy];
    if (account.savePasswd && !(self.m_isChangeAccount)) {
        [view_ loading:YES];
        [[AccountManager shareInstance] login:account.userName withPwd:account.password SavePWD:YES invisible:[account isInvisibleLogin]];
    }
}

- (void) setOtherAccount:(NSArray*) users
{
    view_.moreAccount = users;
}

- (void) getLoginHistory
{
    [[AccountManager shareInstance] fetchAccountHistory:^(NSArray *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (user && user.count > 0) {
                [self setCurrentAccount: user[0]];
                [self setOtherAccount:user];
            }else{
                [self setCurrentAccount:nil];
                [self setOtherAccount:nil];
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self getLoginHistory];
    if (self.m_isChangeAccount) {
        //切换账号
        [view_ loading:NO];
    }
    [super viewDidAppear:animated];
    [[AccountManager shareInstance] addListener:self];
    if (self.selectedConfig) {
        [[AccountManager shareInstance] selectCouldConfig:self.selectedConfig];
        self.selectedConfig = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
