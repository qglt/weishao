//
//  CustomeView.h
//  vishao
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 曾长欢. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppInfo.h"
#import "TileView.h"

@protocol CustomeViewDelegate <NSObject>
@optional
- (void)pushVC:(BaseAppInfo *)info;
- (void)deleteCollect:(BaseAppInfo *)info;
- (void)pushAppCententController;
@end



@interface CustomeView : UIView<TileViewDelegate,UIGestureRecognizerDelegate>
{
    BOOL isEditing;
    UITapGestureRecognizer *singletap;
    UIButton *appCenterButton;
    BOOL isHideButton;

}
//可编辑状态
@property (nonatomic, assign) BOOL edit;
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, strong) NSMutableArray *tileArray;
@property (nonatomic, strong) TileView *titleView;
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) id<CustomeViewDelegate>customeDelegate;

- (id) initWithFrame:(CGRect)frame isHide:(BOOL)isHide;
//添加应用图标方法
- (BOOL) addViewButtonTouch:(BaseAppInfo *)info;
- (void) removeFromSuperviewToRootView;
- (void) removeCollectSubviews;

//接收控制器代理方法中的list
- (void) addRecommend:(NSArray *)list;
- (void) addCollect:(NSArray *)list;
@end
