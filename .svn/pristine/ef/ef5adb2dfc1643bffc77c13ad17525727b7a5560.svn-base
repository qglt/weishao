//
//  NoticeManager.h
//  WhistleIm
//
//  Created by wangchao on 13-8-14.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manager.h"

@class ChatRecordForNotice;

@protocol NoticeDelegate <NSObject>

@optional

/**
 *  通知列表更新
 *
 *  @param noticeList 通知的集合（ChatRecordForNotice的集合）
 */
- (void) noticeListChanged:(NSMutableArray*) noticeList;


/**
 *  获取应用提醒成功
 *
 *  @param appList 应用提醒消息的集合
 */
- (void) getNoticeFinish:(NSMutableArray*) appList;
/**
 *  获取应用提醒失败
 */
- (void) getNoticeFailure;

/**
 *  后台推送应用提醒消息后的事件,可用于后台提醒
 */

- (void) recvNoticeUpdate:(ChatRecordForNotice*) info;
/**
 *  更新所有应用提醒未读的数据
 *
 *  @param count 未读数据
 */
- (void) updateNoticeUnReadCount:(NSUInteger) count;

@end




@interface NoticeManager : Manager

SINGLETON_DEFINE(NoticeManager)

/**
 *  设置一个通知为已读，callback返回成功或者失败信息
 *
 *  @param entry 通知类
 */
-(void)markRead: (ChatRecordForNotice *)entry withCallback:(void(^)(BOOL)) callback;

/**
 *  删除一个通知，callback返回成功或者失败信息
 *
 *  @param entry 通知类
 */
- (void)deleteNotice:(ChatRecordForNotice *)entry withCallback:(void(^)(BOOL)) callback;

- (void) deleteReadedNotice:(void(^)(BOOL)) callback;

- (void) deleteAllNotice:(void(^)(BOOL)) callback;

/**
 *  原则上不需要手动调用，在register4Biz中已经调用。只是在获取通知失败后再手动调用该方法
 */
- (void) getNoticeList;


@end
