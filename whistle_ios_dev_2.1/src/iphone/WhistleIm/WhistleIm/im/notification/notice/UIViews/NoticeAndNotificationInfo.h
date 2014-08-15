//
//  NoticeAndNotificationInfo.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoticeAndNotificationInfoDelegate <NSObject>

@optional
- (void)updateNotice:(NSMutableDictionary *)dataDict;
- (void)updateNotification:(NSMutableDictionary *)dataDict;
- (void)playSoundWithCount:(NSUInteger)unReadCount AndIsNotice:(BOOL)isNotice;
@end

@interface NoticeAndNotificationInfo : NSObject
{
    __weak id <NoticeAndNotificationInfoDelegate> m_delegate;
}
@property (nonatomic, weak) __weak id <NoticeAndNotificationInfoDelegate> m_delegate;

-(void)constructTableViewData;
-(void)constructTableViewNotificationData;

@end
