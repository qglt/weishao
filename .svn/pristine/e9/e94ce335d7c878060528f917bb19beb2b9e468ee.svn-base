//
//  FocusImageFrame.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FocusImageItme.h"
@class FocusImageFrame;

#pragma mark FocusImageFrameDelegate
@protocol FocusImageFrameDelegate <NSObject>

- (void)foucusImageFrame:(FocusImageFrame *)imageFrame didSelectItem:(FocusImageItme *)item;

@end

@interface FocusImageFrame : UIView

@property (nonatomic, weak)id<FocusImageFrameDelegate>delegate;

-(void)clickPageImage:(UIButton *)sender;
- (id)initWithFrame:(CGRect)frame delegate:(id<FocusImageFrameDelegate>)delegate focusImageItems:(FocusImageItme *)items, ... NS_REQUIRES_NIL_TERMINATION;
@end
