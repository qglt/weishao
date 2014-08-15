//
//  AppContentController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Globle : NSObject

@property (nonatomic,assign) float globleWidth;
@property (nonatomic,assign) float globleHeight;
@property (nonatomic,assign) float globleAllHeight;

+ (Globle *)shareInstance;
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString;

@end
