//
//  AppSearchViewController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppSearchViewController.h"
#import "AppSearchView.h"
#import "AppManager.h"
#import "AppDetailController.h"
#import "PrivateTalkViewController.h"
#import "SVWebViewController.h"
#import "NBNavigationController.h"
@interface AppSearchViewController ()<AppCenterDelegate,AppSearchViewDelegate,JGScrollableTableViewCellDelegate>
{
    AppSearchView *searchView;
    NSIndexPath *indexPath;
    CustomScrollTableViewCell *packUpCell;
}
@end

@implementation AppSearchViewController

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
//    [self createNavigationBar:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [self setNavBar];
    searchView = [[AppSearchView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    searchView.appSearchDelegate = self;
    [self.view addSubview:searchView];
    [[AppManager shareInstance] addListener:self];
}
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:@"back" andLeftTitle:@"应用详情" andRightTitle:nil andNeedCreateSubViews:needCreate];
}
#pragma mark - setNavBar
- (void) setNavBar
{
    [self.navigationController  setNavigationBarHidden:NO animated:YES];
    
    //设置Navigation Bar颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(30/255.0) green:(175/255.0) blue:(200/255.0) alpha:1];
    UIButton *BackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 164.0, 45, 45)];
    [BackBtn setTitle:@"返回" forState:UIControlStateNormal];
	[BackBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:BackBtn];
	temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
	self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}
- (void) backAction
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AppCenterDelegate
- (void) getQueryAppFinish:(NSArray *)list
{
    [self refreshSearchCell:list];
}

- (void) queryAppListChanged:(NSArray *)list
{
    [self refreshSearchCell:list];

}

- (void) getQueryAppFailure
{
    
}

- (void) refreshSearchCell:(NSArray *)list
{
    dispatch_async(dispatch_get_main_queue(), ^{
        searchView.dataArray = list;
        [searchView.tableView reloadData];
    });
}

#pragma mark - AppSearchViewDelegate

- (void) searchApp:(NSString *)searchString
{
    [[AppManager shareInstance]queryApp:searchString offset:0 count:10];
}

- (void) pushDetail:(BaseAppInfo *)info
{
    AppDetailController *detailVC = [AppDetailController new];
    detailVC.info = info;
    [detailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void) pushTalk:(BaseAppInfo *)info
{
    if ([info isLightApp]) {
        //
        PrivateTalkViewController *vc = [PrivateTalkViewController new];
        vc.inputObject = info;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([info isNativeApp])
    {
        //启动本地应用
    } else if ([info isWebApp])
    {
        NSURL *URL = [NSURL URLWithString:info.url];
        SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:URL];
        [webVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:webVC animated:YES];
    }

}
@end
