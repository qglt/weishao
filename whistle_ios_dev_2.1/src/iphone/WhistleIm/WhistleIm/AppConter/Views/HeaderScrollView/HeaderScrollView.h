//
//  HeaderScrollView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootScrollView.h"
@interface HeaderScrollView : UIView
{
    NSMutableArray * m_slideImages;
}
@property (nonatomic, strong)  NSMutableArray * m_slideImages;
@property (nonatomic, weak)id<RootScrollViewDelegate>scrollViewDelegate;
- (id)initWithFrame:(CGRect)frame withImageArr:(NSMutableArray *)imageArr;
- (void)clearTimer;
- (void)addImagesToScrollView:(NSArray *)arr;
@end

