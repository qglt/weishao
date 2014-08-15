//
//  CloudConfigurationView.h
//  WhistleIm
//
//  Created by 移动组 on 13-12-10.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteConfigInfo.h"

@protocol CloudConfigurationDelegate <NSObject>
@optional
//系统推荐学校
- (void)downLoadButton:(UIButton *)sender;
- (void)selectButton:(UIButton *)button;

@end

@interface CloudConfigurationView : UIView

@property (nonatomic, weak) id<CloudConfigurationDelegate>cloudDelegate;
@property (nonatomic, strong)UIButton *recommendButton;
@end
