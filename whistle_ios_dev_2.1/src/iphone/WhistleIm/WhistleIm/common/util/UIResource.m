//
//  UIResource.m
//  WhistleIm
//
//  Created by liuke on 14-2-25.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "UIResource.h"

@implementation UIResource

+ (UIFont*) getDefaultFont
{
    return [UIResource getDefaultFont:15.0f];
}

+ (UIFont*) getDefaultFont:(CGFloat)size
{
    static NSMutableDictionary* fonts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fonts = [[NSMutableDictionary alloc] init];
    });
    
    NSString* key = [NSString stringWithFormat:@"%d", (int)size];
    
    UIFont* font = [fonts valueForKey:key];
    if (!font) {
        font = [UIFont fontWithName:@"STHeitiSC-Thin" size:size];
        [fonts setObject:font forKey:key];
    }
    return font;
}

@end
