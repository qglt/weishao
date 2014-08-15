//
//  AppCenterViewController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppCenterViewController.h"
#import "Globle.h"
#import "TopScrollView.h"
#import "RootScrollView.h"
#import "AppContentController.h"
#import "AppDetailController.h"
#import "AppManager.h"
#import "BaseAppInfo.h"
#import "NativeAppInfo.h"
#import "WebAppInfo.h"
#import "LightAppInfo.h"
#import "CustomeView.h"
#import "LeveyTabBarController.h"
#import "NBNavigationController.h"
#import "PrivateTalkViewController.h"
#import "SVWebViewController.h"
#import "SettingTableView.h"
#import "TileView.h"
#import "RootView.h"
@interface AppCenterViewController ()<AppCenterDelegate,TileViewDelegate>
{
    
}
@property (nonatomic, strong) SettingTableView* settingTable;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIScrollView *commonScrollView;
@property (nonatomic, strong) AppContentController *contentVC;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *whistleArray;
@end


@implementation AppCenterViewController

- (void)changeTheme:(NSNotification *)notification
{
//    [self createNavigationBar:NO];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setNavBar];
//    [self createNavigationBar:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];
//    self.title = @"应用";
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [Globle shareInstance].globleWidth = screenRect.size.width; //屏幕宽度
    [Globle shareInstance].globleHeight = screenRect.size.height;  //屏幕高度（无顶栏）
    [Globle shareInstance].globleAllHeight = screenRect.size.height;  //屏幕高度（有顶栏）

    
    [self.view addSubview:[TopScrollView shareInstance]];
    [self.view addSubview:[RootScrollView shareInstance]];
    //设置代理
    [RootScrollView shareInstance].scrollViewDelegate = self;
   
    [[AppManager shareInstance] addListener:self];
    self.dataArray = [NSMutableArray array];
    [[AppManager shareInstance] getRecommandCampusApp:0 count:10];
    [[AppManager shareInstance] getRecommandWhistleApp:0 count:10];
    [[AppManager shareInstance] getMyCollectApp:0 count:10];
    
    [RootScrollView shareInstance].collectView.customeDelegate = self;
//    [self.view addSubview: [[RootView alloc] initWithView: [RootScrollView shareInstance]]];


}
#pragma mark - setNavBar
- (void) setNavBar
{
    //标题栏
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    //加粗
    title.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    title.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"应用";
    self.navigationItem.titleView = title;
}

- (void)removeAppList
{
  
    [self.array removeAllObjects];
    [self.whistleArray removeAllObjects];
    
}
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:nil andLeftTitle:nil andRightTitle:nil andNeedCreateSubViews:needCreate];
}
- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self createNavigationBar:NO];
//}

#pragma mark -

#pragma mark RootScrollViewDelegate

- (void)pushAppDetailController
{
    AppDetailController *detailVC = [AppDetailController new];
    detailVC.title = @"应用详情";
    [detailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark --　AppCenterDelegate
#pragma 接收manager的代理
//得到校内应用成功事件
- (void) getRecommandCampusAppListFinish:(NSArray *)list total:(NSInteger)total
{
    NSArray* mylist = [list copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RootScrollView shareInstance].customeView removeFromSuperviewToRootView];
        [[RootScrollView shareInstance].customeView addRecommend:mylist];
        [RootScrollView shareInstance].customeView.customeDelegate = self;        
    });

}
- (void) recommandCampusAppListChanged:(NSArray *)list
{
    NSLog(@"list = %d",[list count]);
    //customeView加一个方法接收这个list数组作为参数，先clear掉所的view，再根据list添加view
    //先clear掉所的view，再根据list添加view
    NSArray* mylist = [list copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RootScrollView shareInstance].customeView removeFromSuperviewToRootView];
        [[RootScrollView shareInstance].customeView addRecommend:mylist];
        [RootScrollView shareInstance].customeView.customeDelegate = self;
    });
    


}
- (void) getRecommandCampusAppListFailure
{
    //如果请求数据失败应该再调用请求数据的方法
    [[AppManager shareInstance] getRecommandCampusApp:0 count:10];

}
//得到微哨推荐应用成功事件
- (void)getRecommandWhistleAppListFinsih:(NSArray *)list total:(NSInteger)total
{
    [self refreshWhistelView:list];
}
// 微哨推荐应用列表更新事件
- (void) recommandWhsitleAppListChanged:(NSArray*) list
{
    [self refreshWhistelView:list];
}
- (void)refreshWhistelView:(NSArray *)list
{
    [[RootScrollView shareInstance].whistelView removeFromSuperviewToRootView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RootScrollView shareInstance].whistelView addRecommend:list];
    });
    [RootScrollView shareInstance].whistelView.customeDelegate = self;
}
- (void) getRecommandWhistleAppListFailure
{
    //如果请求数据失败应该再调用请求数据的方法
    [[AppManager shareInstance] getRecommandWhistleApp:0 count:10];
}
//得到我的收藏列表成功事件
- (void) getMyCollectAppFinish:(NSArray*) list total:(NSInteger) total;
{

    [self refreshCollect:list];

}
//我的收藏列表变更事件
- (void) myCollectAppListChanged:(NSArray*) list
{

    [self refreshCollect:list];

}

- (void) refreshCollect:(NSArray *)list
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //先清除之前的view,再根据list添加view
        [[RootScrollView shareInstance].collectView removeCollectSubviews];

        //RootScrollView里去处理逻辑
        [[RootScrollView shareInstance].collectView addCollect:list];
        
    });
}
- (void) getMyCollectAppFailure
{
    
}

//校内应用列表更新事件
- (void) campusAppListChanged:(NSArray *)list
{
 
    
    
}
//得到校内应用失败事件
- (void) getCampusAppListFailure
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.leveyTabBarController hidesTabBar:YES animated:YES];
}
#pragma mark - CustomeViewDelegate
- (void)pushVC:(BaseAppInfo *)info
{
    if ([info isLightApp]) {
        //
        PrivateTalkViewController *vc = [[PrivateTalkViewController alloc] init];
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

- (void) deleteCollect:(BaseAppInfo *)info
{
    //执行manager代理方法自动更新数据
    
    [[AppManager shareInstance] removeFromMyCollectApp:info callback:^(BOOL isSuccess) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //代理方法传到详情控制，更新tableViewCell
            });
        }
    }];
}

- (void) pushAppCententController
{
    AppContentController *appContentController = [AppContentController new];
    [appContentController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:appContentController animated:YES];

}
@end
