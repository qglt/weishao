//
//  AppIntrodutionView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedFlowView.h"
@class BaseAppInfo;

@protocol AppIntrodutionViewDelegate <NSObject>

- (void)downLoad:(BaseAppInfo *)info;
- (void)collect:(BaseAppInfo *)info;

@end
@interface AppIntrodutionView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UILabel *lalel;
@property (nonatomic, strong) UILabel *lable2;
@property (nonatomic, strong) UILabel *lable3;
@property (nonatomic, strong) PagedFlowView *hFlowView;
@property (nonatomic, strong) UIPageControl *hPageControl;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UILabel *versionLable;
@property (nonatomic, strong) UILabel *organisationNameLabel;
@property (nonatomic, strong) UILabel *organisationLabel;
@property (nonatomic, strong) UILabel *popularityLable;
@property (nonatomic, strong) UILabel *updateLabel;
@property (nonatomic, strong) UILabel *summaryLable;
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, strong) UIButton *downLoadBtn;
@property (nonatomic, strong) UIButton *markBtn;
@property (nonatomic, weak) id <AppIntrodutionViewDelegate>appIntrodutionDelegate;

//- (void)pageControlValueDidChange:(id)sender;

@end
