//
//  NoticeAndNotificationInfo.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticeAndNotificationInfo.h"

#import "ChatRecordForNotice.h"
#import "Whistle.h"
#import "NoticeManager.h"
#import "NoticeInfo.h"
#import "AppMessageManager.h"
#import "RecentAppMessageInfo.h"
#import "NoticeManager.h"


#define SEND_DATE @"date"
#define ALL_DATA  @"data"

#define NOTIFICATION_DATA @"notification_data"
#define NOTIFICATION_DATE @"notification_date"


@interface NoticeAndNotificationInfo ()
<NoticeDelegate, AppMsgDelegate>
{
    NSMutableArray * m_arrAllSectionData;
    NSMutableArray * m_arrSendDays;
    
    NSMutableArray * m_arrNotificationAllData;
    NSMutableArray * m_arrNotificationSendDays;
    
}

@property (nonatomic, strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic, strong) NSMutableArray * m_arrSendDays;

@property (nonatomic, strong) NSMutableArray * m_arrNotificationAllData;
@property (nonatomic, strong) NSMutableArray * m_arrNotificationSendDays;


@end

@implementation NoticeAndNotificationInfo

@synthesize m_arrAllSectionData;
@synthesize m_arrSendDays;

@synthesize m_arrNotificationAllData;
@synthesize m_arrNotificationSendDays;

@synthesize m_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMemory];
        [[NoticeManager shareInstance] addListener:self];
        [[AppMessageManager shareInstance] addListener:self];
    }
    return self;
}

- (void)setMemory
{
    self.m_arrAllSectionData = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrSendDays = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrNotificationAllData = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrNotificationSendDays = [[NSMutableArray alloc] initWithCapacity:0];
}

-(void)constructTableViewData
{
    [[NoticeManager shareInstance] getNoticeList];
}

/**
 *  通知列表更新
 *
 *  @param noticeList 通知的集合（ChatRecordForNotice的集合）
 */
- (void) noticeListChanged:(NSMutableArray*) noticeList
{
    [self sendNoticeWithArr:noticeList];
}


/**
 *  获取应用提醒成功
 *
 *  @param appList 应用提醒消息的集合
 */
- (void) getNoticeFinish:(NSMutableArray*) appList
{
    [self sendNoticeWithArr:appList];
}
/**
 *  获取应用提醒失败
 */
- (void) getNoticeFailure
{

}

/**
 *  更新所有应用提醒未读的数据
 *
 *  @param count 未读数据
 */
- (void) updateNoticeUnReadCount:(NSUInteger) count
{
    if (count > 0) {
        [m_delegate playSoundWithCount:count AndIsNotice:YES];
    }
}

- (void)sendNoticeWithArr:(NSMutableArray *)noticeArr
{
    [self clearNoticeMemory];
    [self addObjectsToSendDaysArr:noticeArr];
    NSMutableDictionary * dataDict = [self addNoticeToAllDataArr:noticeArr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate updateNotice:dataDict];
    });
}
/**
 *  应用消息列表变更事件，每种应用消息只显示最新数据
 *
 *  @param appList 应用消息集合
 */
- (void) appMsgListChanged:(NSMutableArray*) appList
{
    [self sendNotificationWithArr:appList];
}

/**
 *  获取应用提醒成功
 *
 *  @param appList 应用提醒消息的集合
 */
- (void) getAppMsgFinish:(NSMutableArray*) appList
{
    [self sendNotificationWithArr:appList];
}

/**
 *  获取应用提醒失败
 */
- (void) getAppMsgFailure
{

}

/**
 *  更新所有应用提醒未读的数据
 *
 *  @param count 未读数据
 */
- (void) updateAppMsgUnReadCount:(NSUInteger) count
{
    if (count > 0) {
        [m_delegate playSoundWithCount:count AndIsNotice:NO];
    }
}

- (void)sendNotificationWithArr:(NSMutableArray *)appArr
{
    [self clearNotificationMemory];
    
    [self logNotificationData:appArr];
    
    [self addNotificationsToSendDaysArr:appArr];
    
    NSMutableDictionary * dict = [self addNotificationsToAllDataArr:appArr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate updateNotification:dict];
    });

}



- (void)clearNoticeMemory
{
    [self.m_arrAllSectionData removeAllObjects];
    [self.m_arrSendDays removeAllObjects];
 }

- (void)clearNotificationMemory
{
    [self.m_arrNotificationSendDays removeAllObjects];
    [self.m_arrNotificationAllData removeAllObjects];
}

- (void)logData:(NSArray *)allNoticeArr
{
    for (int i = 0; i < [allNoticeArr count]; i++) {
        ChatRecordForNotice * notice = [allNoticeArr objectAtIndex:i];
        NSLog(@"title == %@", notice.noticeInfo.title);
        NSLog(@"notice.noticeInfo.signature == %@", notice.noticeInfo.signature);
        NSLog(@"notice.noticeInfo.publishTime == %@", notice.noticeInfo.publishTime);
        NSLog(@"notice.noticeInfo.priority == %@", notice.priority);
        NSLog(@"notice.noticeInfo.noticeId == %@", notice.noticeInfo.noticeId);
        NSLog(@"notice.noticeInfo.html == %@", notice.noticeInfo.html);
        NSLog(@"notice.noticeInfo.expiredTime == %@", notice.noticeInfo.expiredTime);
        NSLog(@"notice.noticeInfo.body == %@", notice.noticeInfo.body);
        
        // 取出年月日
        NSString * sendDate = [notice.noticeInfo.publishTime substringToIndex:10];
        NSLog(@"sendDate == %@", sendDate);
    }
}

// 取出所有通知的发送日期 ---> 年--月--日
- (void)addObjectsToSendDaysArr:(NSArray *)dateArr
{
    NSMutableArray * allSendDateArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [dateArr count]; i++) {
        ChatRecordForNotice * notice = [dateArr objectAtIndex:i];
        NSString * sendDate = [notice.noticeInfo.publishTime substringToIndex:10];
        [allSendDateArr addObject:sendDate];
    }
    
    NSLog(@"allSendDateArr == %@", allSendDateArr);
    [self deleteTheSameSendDate:allSendDateArr];
}

// 过滤掉相同的发送日期
- (void)deleteTheSameSendDate:(NSMutableArray *)dateArr
{
    for (NSUInteger i = 0; i < [dateArr count]; i++) {
        NSString * date = [dateArr objectAtIndex:i];
        
        if (![self.m_arrSendDays containsObject:date]) {
            [self.m_arrSendDays addObject:date];
        }
    }
    NSLog(@"notice m_arrSendDays == %@", self.m_arrSendDays);
}

- (NSMutableDictionary *)addNoticeToAllDataArr:(NSArray *)copy
{
    for (NSUInteger i = 0; i < [self.m_arrSendDays count]; i++) {
        
        NSMutableArray * eachSendDateArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSString * sendDate = [self.m_arrSendDays objectAtIndex:i];
        
        for (NSUInteger j = 0; j < [copy count]; j++) {
            ChatRecordForNotice * notice = [copy objectAtIndex:j];
            
            // 取出年月日
            NSString * eachNoticeSendDate = [notice.noticeInfo.publishTime substringToIndex:10];
            
            if ([eachNoticeSendDate isEqualToString:sendDate]) {
                [eachSendDateArr addObject:notice];
            }
        }
        
        [self.m_arrAllSectionData addObject:eachSendDateArr];
    }
    
    NSLog(@"m_arrAllSectionData === %@", self.m_arrAllSectionData);
    NSLog(@"m_arrSendDays === %@", self.m_arrSendDays);
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dict setObject:self.m_arrSendDays forKey:SEND_DATE];
    [dict setObject:self.m_arrAllSectionData forKey:ALL_DATA];

    return dict;
}

-(void)constructTableViewNotificationData
{
    [[AppMessageManager shareInstance] getAppList];
}

- (void)logNotificationData:(NSArray *)notificationArr
{
    for (NSUInteger i = 0; i < [notificationArr count]; i++) {
        RecentAppMessageInfo * notification = [notificationArr objectAtIndex:i];
        NSLog(@"unreadCount == %d", notification.unreadCount);
        NSLog(@"countAll == %d", notification.countAll);


        NSLog(@"message.sendTime == %@", notification.message.sendTime);
        NSLog(@"message.body == %@", notification.message.body);
        
        NSLog(@"notification.message.html == %@", notification.message.html);
        NSLog(@"notification.message.hyperlink == %@", notification.message.hyperlink);
        NSLog(@"notification.message.msgId == %d", notification.message.msgId);
        NSLog(@"notification.message.isRead == %d", notification.message.isRead);
        NSLog(@"notification.message.showText == %@", notification.message.showText);

        
        
        
        NSLog(@"serviceInfo.name == %@", notification.serviceInfo.name);
        NSLog(@"serviceInfo.icon == %@", notification.serviceInfo.icon);
//        NSLog(@"serviceInfo.icon == %@", notification.serviceInfo.id);
        NSLog(@"serviceInfo.icon == %@", notification.serviceInfo.jsonObj);

    }
    
}

// 取出所有通知的发送日期 ---> 年--月--日
- (void)addNotificationsToSendDaysArr:(NSArray *)dateArr
{
    NSMutableArray * allSendDateArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [dateArr count]; i++) {
        RecentAppMessageInfo * notification = [dateArr objectAtIndex:i];
        NSString * sendDate = [notification.message.sendTime substringToIndex:10];
        [allSendDateArr addObject:sendDate];
    }
    NSLog(@"notification allSendDateArr == %@", allSendDateArr);
    [self deleteTheSameNotificationsSendDate:allSendDateArr];
}

// 过滤掉相同的发送日期
- (void)deleteTheSameNotificationsSendDate:(NSMutableArray *)dateArr
{
    for (NSUInteger i = 0; i < [dateArr count]; i++) {
        NSString * date = [dateArr objectAtIndex:i];
        
        if (![self.m_arrNotificationSendDays containsObject:date]) {
            [self.m_arrNotificationSendDays addObject:date];
        }
    }
    NSLog(@"m_arrNotificationSendDays == %@", self.m_arrNotificationSendDays);
}

- (NSMutableDictionary *)addNotificationsToAllDataArr:(NSArray *)copy
{
    for (NSUInteger i = 0; i < [self.m_arrNotificationSendDays count]; i++) {
        
        NSMutableArray * eachSendDateArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSString * sendDate = [self.m_arrNotificationSendDays objectAtIndex:i];
        
        for (NSUInteger j = 0; j < [copy count]; j++) {
            RecentAppMessageInfo * notification = [copy objectAtIndex:j];
            
            // 取出年月日
            NSString * eachNoticeSendDate = [notification.message.sendTime substringToIndex:10];
            
            if ([eachNoticeSendDate isEqualToString:sendDate]) {
                [eachSendDateArr addObject:notification];
            }
        }
        
        [self.m_arrNotificationAllData addObject:eachSendDateArr];
    }
    
    NSLog(@"m_arrNotificationAllData === %@", self.m_arrNotificationAllData);
    NSLog(@"m_arrNotificationSendDays === %@", self.m_arrNotificationSendDays);
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dict setObject:self.m_arrNotificationSendDays forKey:NOTIFICATION_DATE];
    [dict setObject:self.m_arrNotificationAllData forKey:NOTIFICATION_DATA];
    
    return dict;
}

@end
