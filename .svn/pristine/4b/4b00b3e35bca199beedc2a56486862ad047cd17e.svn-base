//
//  LocalNotificationOnBackground.m
//  WhistleIm
//
//  Created by liuke on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "LocalNotificationOnBackground.h"
#import "JSONObjectHelper.h"
#import "BizlayerProxy.h"
#import "ChatRecordForNotice.h"
#import "NoticeInfo.h"
#import "MessageManager.h"
#import "NoticeManager.h"
#import "AppMessageManager.h"
#import "RecentAppMessageInfo.h"
#import "RecentRecord.h"
#import "RecentAppMessageInfo.h"
#import "LocalRecentListManager.h"
#import "SystemMessageInfo.h"
#import "FriendInfo.h"


@interface LocalNotificationOnBackground() <NoticeDelegate, AppMsgDelegate, MessageManagerDelegate, LocalRecentListDelegate>
{
    NSUInteger count_;
}

@end


@implementation LocalNotificationOnBackground

SINGLETON_IMPLEMENT(LocalNotificationOnBackground)

- (id) init
{
    self = [super init];
    if (self) {
        count_ = 0;
    }
    return self;
}

- (void) registerListener
{
    [[NoticeManager shareInstance] addListener:self];
    [[AppMessageManager shareInstance] addListener:self];
    [[MessageManager shareInstance] addListener:self];
    [[LocalRecentListManager shareInstance] addListener:self];
}

- (void) sendLocalNotify:(NSString*) title withMsg:(NSString*) msg
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        //后台运行时消息提醒
        UILocalNotification* local = [[UILocalNotification alloc] init];
        if (local) {
            local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            local.timeZone = [NSTimeZone defaultTimeZone];
            local.repeatInterval = NSWeekCalendarUnit;
            local.soundName = UILocalNotificationDefaultSoundName;
            NSString* t;
            if (!title || [@"" isEqualToString:title]) {
                t = @"微哨用户";
            }else{
                t = title;
            }
            NSString* m;
            if (!msg || [@"" isEqualToString:msg]) {
                m = @"有新消息";
            }else{
                m = msg;
            }

            local.alertBody = [NSString stringWithFormat:@"%@:%@", t, m];
            LOG_NETWORK_INFO(@"后台提醒title:%@, msg:%@", title, msg);
            [[UIApplication sharedApplication] scheduleLocalNotification:local];
        }
    }
}

- (void) sendIconBadgeNumber:(NSInteger) count
{
    UILocalNotification* local = [[UILocalNotification alloc] init];
    if (local) {
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        local.timeZone = [NSTimeZone defaultTimeZone];
        local.repeatInterval = NSWeekCalendarUnit;
        local.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] scheduleLocalNotification:local];
    }
}

#pragma mark 应用提醒
- (void) recvAppMsgUpdate:(RecentAppMessageInfo *)info
{
    [self sendLocalNotify:@"应用提醒" withMsg: info.serviceInfo.name];
}

- (void) updateAppMsgUnReadCount:(NSUInteger)count
{
//    [self sendIconBadgeNumber:count];
}

#pragma mark 通知
- (void) recvNoticeUpdate:(ChatRecordForNotice *)info
{
    [self sendLocalNotify:@"通知" withMsg: info.noticeInfo.title];
}
- (void) updateNoticeUnReadCount:(NSUInteger)count
{
    
}


#pragma mark    聊天信息，包括双人、群和讨论组

- (void) msgItemUpdate:(ConversationInfo *)msg
{
//    [self sendLocalNotify:msg.showName withMsg:msg.content];
    if ([msg msgType] == SessionType_Conversation) {
        [self sendLocalNotify:((FriendInfo*)msg.extraInfo).showName withMsg:msg.content];
    }else if([msg msgType] == SessionType_Crowd){
        [self sendLocalNotify:msg.showName withMsg:msg.content];
    }else if ([msg msgType] == SessionType_Discussion){
        [self sendLocalNotify:msg.showName withMsg:msg.content];
    }
        
}

#pragma mark  系统消息

- (void) updateRecentRecord:(RecentRecord*) rec
{
    if ([rec getType] == RecentRecord_System) {
        [self sendLocalNotify:rec.speaker withMsg:[((SystemMessageInfo*)rec.extraInfo) getShowTxt]];
    }
}

@end
