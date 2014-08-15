//
//  CommonRespondView.m
//  WhistleIm
//
//  Created by liuke on 13-12-16.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CommonRespondView.h"
#import "MBProgressHUD.h"
#import "Toast.h"
@implementation CommonRespondView

+ (void) respond:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Toast show:text];
    });
}

@end
