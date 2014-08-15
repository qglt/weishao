//
//  NoticeTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>


// 通知
@class ChatRecordForNotice;
@class RecentAppMessageInfo;

@protocol NoticeTableViewDelegate <NSObject>

@optional
//- (void)noticeDidSelectedRow:(ChatRecordForNotice *)notice;

// 点击push详情页面
- (void)cellDidSelectedRow:(NSUInteger)selectedRow andIsNotice:(BOOL)isNotice;
- (void)NotificationCellDidSelected:(NSIndexPath *)indexPath;

// 删除单条列表消息
- (void)deleteNoticeInTheMemory:(ChatRecordForNotice *)notice;
- (void)deleteNotificationInTheMemory:(RecentAppMessageInfo *)notification;

// 通知和提醒标记为已读
- (void)noticeMarkRead:(ChatRecordForNotice *)notice;
- (void)notificationMarkRead:(RecentAppMessageInfo *)notification;

// 未读消息数量发给controller
- (void)sendNoticeUnreadCounter:(NSUInteger)counter andIsUpdate:(BOOL)isUpdate;
- (void)sendNotificationUnreadCounter:(NSUInteger)counter andIsUpdate:(BOOL)isUpdate;

- (void)clearEditStateNoneData;

//- (void)hiddenEditBarButton:(BOOL)hidden isNotice:(BOOL)isNotice;
- (void)hiddenNoticeEditBarButton:(NSUInteger)noticeCount andIsEditState:(BOOL)isEdit;
- (void)hiddenNotificationEditBarButton:(NSUInteger)NotificationCount andIsEditState:(BOOL)isEdit;


@end

@interface NoticeTableView : UIView
{
    __weak id <NoticeTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <NoticeTableViewDelegate> m_delegate;

- (void)editTableView:(BOOL)canEdit;
- (void)clearEditState;

- (void)refreshNoticeTableView:(NSMutableDictionary *)dataDict isNotice:(BOOL)isNotice isUpdate:(BOOL)isUpdate;
-(void)removeAll;
-(void)removeRead;
@end
