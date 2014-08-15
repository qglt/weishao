//
//  NoticesGlanceView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatRecordForNotice;
@class RecentAppMessageInfo;
@interface NoticesGlanceView : UIView
{
    ChatRecordForNotice * m_notice;
    RecentAppMessageInfo * m_notification;
}
@property (nonatomic,strong) RecentAppMessageInfo * m_notification;
@property (nonatomic, strong) ChatRecordForNotice * m_notice;

- (id)initWithFrame:(CGRect)frame andData:(ChatRecordForNotice *)notice;
- (id)initWithFrame:(CGRect)frame andNotificationData:(RecentAppMessageInfo *)notification;
@end
