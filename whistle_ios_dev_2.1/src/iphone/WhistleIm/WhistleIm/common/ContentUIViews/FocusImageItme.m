//
//  FocusImageItme.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "FocusImageItme.h"

@implementation FocusImageItme
- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    self = [super init];
    if (self) {
        self.title = title;
        self.image = image;
        self.tag = tag;
    }
    
    return self;
}
@end
