//
//  NetworkBrokenAlert.m
//  WhistleIm
//
//  Created by liuke on 13-10-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NetworkBrokenAlert.h"
#import "MBProgressHUD.h"
#import "NetworkManager.h"
#import "Toast.h"

@implementation NetworkBrokenAlert

+ (BOOL) isNetworkBrokenAndShowTip
{
    if ([NetworkManager shareInstance].isOnlineState) {
        return NO;
    } else {
        [Toast show:@"网络连接失败，请检查网络状态！"];
        return YES;
    }
    return NO;
}

@end
