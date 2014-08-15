//
//  AppContentController.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootScrollView.h"

@class HeaderScrollView;
@class AppCenterViewController;
@interface AppContentController : UIViewController<UITableViewDelegate,UITableViewDataSource,RootScrollViewDelegate>
{
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;

}
@property (nonatomic, strong) UIButton *schoolAppButton;//校园应用
@property (nonatomic, strong) UIButton *whistleButton;//微哨应用
@property (nonatomic, strong) UILabel  *slidLabel;//用于指示作用
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *headerScrollView;
@property (nonatomic, strong) NSMutableArray *slideImages;
@property (nonatomic, strong) HeaderScrollView *headerView;
@property (nonatomic, strong) UITableView *schoolAppTableView;
@property (nonatomic, strong) UITableView *whistleAppTableView;

@end
