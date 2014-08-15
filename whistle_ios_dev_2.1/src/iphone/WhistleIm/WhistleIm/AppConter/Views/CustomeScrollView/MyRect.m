//
//  MyRect.m
//  IPhoneTest
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 曾长欢. All rights reserved.
//

#import "MyRect.h"

@implementation MyRect

- (MyRect *)initWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
{
    if (self = [super init])
    {
        self.x = x;
        self.y = y;
        self.width = width;
        self.height = height;
    }
    return self;
}

- (MyRect *)initWithCGRect:(CGRect)rect
{
    if (self = [super init])
    {
        self.x = rect.origin.x;
        self.y = rect.origin.y;
        self.width = rect.size.width;
        self.height = rect.size.height;
    }
    return self;
}

- (CGRect)rect
{
    return CGRectMake(self.x, self.y, self.width, self.height);
}

- (CGPoint)center
{
    return CGPointMake(self.x + self.width / 2.f, self.y + self.height / 2.f);
}

@end
