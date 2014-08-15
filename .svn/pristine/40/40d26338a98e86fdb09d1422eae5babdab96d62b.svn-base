//
//  AppContentController.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootScrollView.h"
@interface AppContentController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
    //页面展示部分
    UITableView *_schoolAppTableView;
    UITableView *_whistleAppTableView;
    //数据部分
    NSArray *couponArry;
    NSArray *groupbuyArry;

}
@property (nonatomic, strong) UIButton *schoolAppButton;//校园应用
@property (nonatomic, strong) UIButton *whistleButton;//微哨应用
@property (nonatomic, strong) UILabel  *slidLabel;//用于指示作用
@property (nonatomic, strong) UIScrollView *scrollView;
@end
