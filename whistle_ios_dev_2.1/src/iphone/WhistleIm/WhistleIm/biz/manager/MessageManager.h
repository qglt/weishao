//
//  PushMessageManager.h
//  WhistleIm
//
//  Created by wangchao on 13-8-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BizBridge.h"
#import "Manager.h"
#import "Constants.h"
#import "ConversationInfo.h"



@protocol MessageManagerDelegate <NSObject>
@optional

/**
 *  聊天信息有变化时的通知事件。
 *
 *  @param msgList BaseMessageInfo消息的集合
 */
- (void) convMsgListChanged:(NSArray*) msgList;
/**
 *  得到聊天记录的事件通知
 *
 *  @param msg_list  聊天信息ConversationInfo的集合
 *  @param count_all 返回聊天信息的总数
 */
- (void) getConvMsgFinish:(NSArray*) msg_list withCountAll:(NSUInteger) count_all;

- (void) getConvMsgFailure;
/**
 *  有最新消息时的通知事件,最新消息可能会被拆分成多条，但这里不进行拆分
 *
 *  @param msg 最新消息的实体类
 */
- (void) msgItemUpdate:(BaseMessageInfo*) msg;

/**
 *  有最新消息时的通知事件,最新消息可能会被拆分成多条,这里发送拆分后的信息
 *
 *  @param msg 最新消息的实体类
 */
- (void) newMsgUpdate:(NSArray*) msg;

/**
 *  一条消息变更后的通知事件，一般用于之前返回的信息不完整，等完整后通过这个事件更新；或者消息的状态修改等。
 *
 *  @param msg 变化后的消息实类
 */
- (void) oneMsgChanged:(BaseMessageInfo*) msg;

@end

@interface MessageManager : Manager

SINGLETON_DEFINE(MessageManager)

- (void) getConversation:(NSString *)jid withType:(ConversationType) type withBeginIndex:(NSUInteger) bindex withCount:(NSUInteger) count;

- (void) getConversation:(NSString *)jid withType:(ConversationType) type;

- (void) getLightappMsg:(NSString *)jid withType:(ConversationType) type withBeginIndex:(NSInteger) bindex withCount:(NSInteger) count;

- (void) leaveConversation;

- (void) markMessageRead:(NSString*) jid type:(ConversationType) type withCallback:(void(^)(BOOL)) callback;

- (void) markLightMessageRead:(NSString *)jid type:(ConversationType)type withCallback:(void (^)(BOOL))callback;

- (void) deleteAllHistoryMessage:(ConversationType) type withjid:(NSString *)jid withListener:(void(^)(BOOL)) callback;

- (void) sendMessage:(NSString*) msg callback:(void(^)(BOOL)) callback;

- (void) sendMessageToPC:(NSString *)msg callback:(void (^)(BOOL))callback;

- (void) sendMessageToAndroid:(NSString *)msg callback:(void (^)(BOOL))callback;

- (void) sendImageMessage:(NSString*) src callback:(void(^)(BOOL)) callback;

- (void) sendVoiceMessage:(NSString*) src duration:(int) duration callback:(void(^)(BOOL)) callback;

- (void) sendVideoMessage:(NSString*) src duration:(int) duration callback:(void(^)(BOOL)) callback;

- (void) sendLightAppMessage:(NSString*) appid text:(NSString*) txt;

- (void) sendLightAppMessage:(NSString*) appid event:(NSString*) event eventKey:(NSString*) eventKey;

- (void) sendLightAppMessage:(NSString*) appid image:(NSString*) filepath;// callback:(WhistleCommandCallbackType)callback;

- (void) sendHelloMessage:(NSString *)jid withID:(NSString *)uuid;

- (void) sendLightAppMessage:(NSString *)appid voice:(NSString *)filepath lenght:(NSUInteger) length callback:(void (^)(BOOL))callback;

- (void) deleteLightapp:(NSString*) appid rowid:(NSInteger) rowid callback:(void(^)(BOOL)) callback;
- (void) deleteLightapp:(NSString*) appid callback:(void(^)(BOOL)) callback;

- (void) getLightappMenu:(NSString*) appid callback:(void(^)(NSArray*)) callback;

- (void) markVoiceOrVideoMsgRead:(ConversationInfo*) msg callback:(void(^)(BOOL)) callback;

@end
