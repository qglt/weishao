//
//  CommonView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class BaseAppInfo;
@protocol CommonViewDelegate <NSObject>

- (void)sendExpressInfoWhenTouched:(BaseAppInfo *)expressInfo;
- (void)deleteCommonExpressWithExpressInfo:(BaseAppInfo *)expressInfo;
@end
@interface CommonView : UIView
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) CGPoint startPoint;
@property (strong, nonatomic) BaseAppInfo * expressInfo;
@property (assign, nonatomic) id<CommonViewDelegate> delegate;

@property (strong, nonatomic) UIImageView * closeImageView;
@property (strong, nonatomic) UITapGestureRecognizer * tapGesture;
@property (strong, nonatomic) UITapGestureRecognizer * closeTapGesture;


//- (void)addCloseView;
//- (void)stopEditingCommonView;
//- (id)initWithFrame:(CGRect)frame appInfo:(BaseAppInfo *)appInfo;
@end
