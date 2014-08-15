//
//  AppMessageManager.h
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manager.h"

@class RecentAppMessageInfo;

@protocol AppMsgDelegate <NSObject>

@optional
/**
 *  应用消息列表变更事件，每种应用消息只显示最新数据
 *
 *  @param appList 应用消息集合
 */
- (void) appMsgListChanged:(NSMutableArray*) appList;

/**
 *  获取应用提醒成功
 *
 *  @param appList 应用提醒消息的集合
 */
- (void) getAppMsgFinish:(NSMutableArray*) appList;
/**
 *  获取应用提醒失败
 */
- (void) getAppMsgFailure;

/**
 *  后台推送应用提醒消息后的事件,可用于后台提醒
 */

- (void) recvAppMsgUpdate:(RecentAppMessageInfo*) info;
/**
 *  更新所有应用提醒未读的数据
 *
 *  @param count 未读数据
 */
- (void) updateAppMsgUnReadCount:(NSUInteger) count;

@end

@interface AppMessageManager : Manager

SINGLETON_DEFINE(AppMessageManager)


-(void)markRead:(RecentAppMessageInfo*) app WithCallback:(void(^)(BOOL)) callback;

- (void) deleteRecentAppMessage:(RecentAppMessageInfo *)msg withCallback:(void(^)(BOOL)) callback;

- (void) deleteAllReadAppMessage:(void(^)(BOOL)) callback;

- (void) deleteAllAppMessage:(void(^)(BOOL)) callback;
/**
 *  获取应用消息的历史消息
 *
 *  @param serviceID 服务id
 *  @param callback AppMsgInfo的数组
 */
- (void) getAppMsgHistoryBySID:(NSString*) serviceID withCallback:(void(^)(NSArray*)) callback;

- (void) getAppMsgHistoryBySID:(NSString*) serviceID withIndex:(NSInteger) index withCount:(NSUInteger) count withCallback:(void(^)(NSArray*)) callback;

/**
 *  获取应用消息的历史消息
 *
 *  @param appmsg 最近应用提醒对象
 *  @param callback AppMsgInfo的数组
 */
- (void) getAppMsgHistory:(RecentAppMessageInfo*) appmsg withCallback:(void(^)(NSArray*)) callback;

- (void) getAppMsgHistory:(RecentAppMessageInfo*) appmsg withIndex:(NSInteger) index withCount:(NSUInteger) count withCallback:(void(^)(NSArray*)) callback;


/**
 *  原则上不需要手动调用，在register4Biz中已经调用。只是在获取通知失败后再手动调用该方法
 */
- (void) getAppList;
- (void) getAppList:(NSInteger) index count:(NSInteger) count;

@end
