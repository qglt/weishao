//
//  DisconnectedByLogOnSameDevieceAlert.m
//  WhistleIm
//
//  Created by liuke on 13-10-16.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "DisconnectedByLogOnSameDevieceAlert.h"
#import "AccountManager.h"
#import "CustomAlertView.h"

@interface DisconnectedByLogOnSameDevieceAlert() <UIAlertViewDelegate>
{
    CustomAlertView * alert;
}
@end

@implementation DisconnectedByLogOnSameDevieceAlert

- (BOOL) show
{
    alert = [[CustomAlertView alloc] initWithTitle:@"下线通知" message:@"你的账号在另一个IOS设备登录，请检查是否是自己主动登录" delegate:self cancelButtonTitle:@"确定"
                                confrimButtonTitle:@"重新登录"];
    [alert show];
    return YES;
}
- (void)customAlertView:(CustomAlertView *)customAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (buttonIndex) {
            case 0:
                //点击确定
                break;
            case 1:
                //点击重新登录
                [[AccountManager shareInstance] login];
                break;
            default:
                break;
        }
    });
}
@end
