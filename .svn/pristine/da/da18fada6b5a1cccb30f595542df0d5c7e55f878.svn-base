//
//  ReceivedNewInfo.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ReceivedNewInfo.h"
#import "NoticeManager.h"
#import "LocalRecentListManager.h"
#import "AppMessageManager.h"

@interface ReceivedNewInfo ()
<NoticeDelegate, LocalRecentListDelegate, AppMsgDelegate>

@end

@implementation ReceivedNewInfo
@synthesize m_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        [[NoticeManager shareInstance] addListener:self];
        [[LocalRecentListManager shareInstance] addListener:self];
        [[AppMessageManager shareInstance] addListener:self];
    }
    return self;
}

- (void)updateRecentListUnReadCount:(NSUInteger)count
{
    if (count > 0) {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:1 andIsHidden:NO];
    } else {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:1 andIsHidden:YES];
    }
}

- (void)updateNoticeUnReadCount:(NSUInteger)count
{
    if (count > 0) {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:3 andIsHidden:NO];
    } else {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:3 andIsHidden:YES];
    }
}

- (void)updateAppMsgUnReadCount:(NSUInteger)count
{
    if (count > 0) {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:3 andIsHidden:NO];
    } else {
        [m_delegate hiddenOrShowRedSpotIndicatorWithIndex:3 andIsHidden:YES];
    }
}
@end
