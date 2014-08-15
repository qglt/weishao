//
//  WhistlePageController.m
//  ios_nav3
//
//  Created by liuke on 13-9-26.
//  Copyright (c) 2013年 liuke. All rights reserved.
//

#import "WhistlePageController.h"

@interface WhistlePageController()
{
    UIImage* activeImage;
    UIImage* inactiveImage;
}

@end

@implementation WhistlePageController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        activeImage = [UIImage imageNamed:@"guide_foucs.png"];
        inactiveImage = [UIImage imageNamed:@"guide_nor.png"];
        [self setEnabled:NO];
    }
    return self;
}

- (void) setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    for (int i = 0; i < [self.subviews count]; i ++) {
        UIView* view = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* _v in view.subviews) {
            if ([_v isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView*)_v;
                break;
            }
        }
        if (nil == dot) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
        if ([dot isKindOfClass:[UIImageView class]]) {
            if (i == self.currentPage) {
                //            dot.image = activeImage;
                [dot setImage:activeImage];
            }else{
                //            dot.image = inactiveImage;
                [dot setImage:inactiveImage];
            }
        }
        
    }
}


@end
