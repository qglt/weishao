//
//  CommonBackGroudView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CommonBackGroudView.h"

@implementation CommonBackGroudView
+ (UIView *)getBackGroudView
{
    BOOL m_isIOS7 =[[GetFrame shareInstance] isIOS7Version];
    CGRect m_frame = [[UIScreen mainScreen] bounds];

    CGFloat y = 0;
    if (m_isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44 - 49;

    UIView * BGView = [[UIView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    BGView.backgroundColor = [UIColor blueColor];
    return BGView;
}
@end
