//
//  Toast.m
//  WhistleIm
//
//  Created by liuke on 14-3-4.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Toast.h"
#import "ImUtils.h"
#import "UIResource.h"


static UIView* view = nil;

@implementation Toast

+ (void) show:(NSString *)text duration:(CGFloat)time
{
    if (view) {
        return;
    }
    UIFont* font = [UIResource getDefaultFont:11.0f];
    CGSize size = [text sizeWithFont:font];
    
    view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.backgroundColor = [ImUtils colorWithHexString:@"#000000"];
    view.alpha = 0.55;
    view.layer.zPosition = MAXFLOAT;
    
    UIView* window = nil;
    if ([[UIApplication sharedApplication] windows].count > 1) {
        window = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    }else{
        window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    }
    [window addSubview:view];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[view(%f)]-75-|", size.height + 20] options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"H:[view(%f)]", size.width + 20] options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    
    UILabel* label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.font = font;
    label.textColor = [UIColor whiteColor];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:label];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                          [NSString stringWithFormat:@"H:|-10-[label]-10-|"] options:0 metrics:0 views:NSDictionaryOfVariableBindings(label)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
                          [NSString stringWithFormat:@"V:|-10-[label]-10-|"] options:0 metrics:0 views:NSDictionaryOfVariableBindings(label)]];
    [UIView animateWithDuration:0.3 delay:time options:0 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        view = nil;
    }];
}

+ (void) show:(NSString *)text
{
    [Toast show:text duration:2];
}

@end
