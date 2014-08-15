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
@interface AppCenterViewController ()

@end

@implementation AppCenterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [Globle shareInstance].globleWidth = screenRect.size.width; //屏幕宽度
    [Globle shareInstance].globleHeight = screenRect.size.height-20;  //屏幕高度（无顶栏）
    [Globle shareInstance].globleAllHeight = screenRect.size.height;  //屏幕高度（有顶栏）

    
    [self.view addSubview:[TopScrollView shareInstance]];
    [self.view addSubview:[RootScrollView shareInstance]];
    //设置代理
    [RootScrollView shareInstance].scrollViewDelegate = self;
    
}
#pragma mark -

#pragma mark RootScrollViewDelegate
- (void)pushAppCententController
{
    AppContentController *appContentController = [AppContentController new];
    appContentController.title = @"应用中心";
    [appContentController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:appContentController animated:YES];
}
@end
