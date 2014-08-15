//
//  AppDetailController.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootScrollView.h"
#import "AppIntrodutionView.h"
#import "CommentaryView.h"



@interface AppDetailController : UIViewController<UIScrollViewDelegate,RootScrollViewDelegate>
{
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;

}
@property (nonatomic, strong) UIButton *IntroductionButton;
@property (nonatomic, strong) UIButton *commentaryButton;
@property (nonatomic, strong) UILabel *slidLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, strong) AppIntrodutionView *introdutionView;
@property (nonatomic, strong) CommentaryView *commentrayView;
@end
