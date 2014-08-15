//
//  SystemMsgManager.h
//  WhistleIm
//
//  Created by liuke on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Manager.h"
#import "CrowdInfo.h"
#import "FriendInfo.h"
#import "SystemMessageInfo.h"


@protocol SystemMsgDelegate <NSObject>

@optional
/**
 *  系统消息列表变更事件，消息完整后会发此事件
 *
 *  @param sysList 系统消息的集合
 */
- (void) systemMsgListChanged:(NSArray*) sysList;
/**
 *  得到系统消息成功,一般情况下是默认数据
 *
 *  @param sysList 系统消息列表
 */
- (void) getSystemMsgListFinish:(NSArray*) sysList countAll:(int) count_all;

/**
 *  得到系统消息失败
 */
- (void) getSystemMsgListFailure;

- (void) deleteSystemMsgAtSystemMgr;


@end

/**
 *  系统消息的管理类
 */
@interface SystemMsgManager : Manager

SINGLETON_DEFINE(SystemMsgManager)

- (void) getSystemMsgList:(int) index withCount:(NSUInteger) count;

- (void) deleteSystemMsg:(SystemMessageInfo*) info withCallback:(void(^)(BOOL)) callback;

- (void) deleteAllSystemMsgWithCallback:(void(^)(BOOL)) callback;

- (void) ackAddFriendInvite:(NSString*) jid isAgree:(BOOL)isAgree withCallback:(void (^)(BOOL))callback;

- (void) addFriend:(NSString*) jid withMsg:(NSString*) msg withCallback:(void(^)(BOOL)) callback;

- (void) getExtraInfo:(SystemMessageInfo*) sinfo withCallback:(void(^)()) callback;

- (void) markSystemRead:(SystemMessageInfo*) info withCallback:(void(^)(BOOL)) callback;

@end
