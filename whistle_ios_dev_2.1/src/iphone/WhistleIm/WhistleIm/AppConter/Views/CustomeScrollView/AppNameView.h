//
//  AppNameView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-3-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppInfo.h"
@interface AppNameView : UIView
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UILabel *labelName;
- (id)initWithFrame:(CGRect)frame info:(BaseAppInfo *)info;
@end
