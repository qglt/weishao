//
//  BaseMessageInfo.h
//  WhistleIm
//
//  Created by liuke on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"


typedef enum _ConversationType {
    SessionType_Conversation,
    SessionType_Crowd,
    SessionType_Discussion,
    SessionType_AppMsg,
    SessionType_LightApp,
    SessionType_Error
} ConversationType;

typedef enum _MsgStatus{
    MSG_SEND_FAILURE,
    MSG_SEND_SUCCUSS,
    MSG_SENDING,
    MSG_RECV_FAILURE,
    MSG_RECV_SUCCUSS,
    MSG_RECVING
} MsgStatus;

/**
 *  聊天消息的基类，聊天信息包括普通信息、轻应用信息等
 */
@interface BaseMessageInfo : Entity <Jsonable>

@property (nonatomic,strong) NSString* messageType;
@property (nonatomic, strong) NSDictionary* msg;
@property (nonatomic,strong) NSString* jid;
@property (nonatomic, strong) NSString* rowid;
@property (nonatomic) MsgStatus status;
@property (nonatomic) BOOL isRead;
@property (nonatomic) BOOL isSend;


- (ConversationType) msgType;

+(NSString *) getConvType:(ConversationType)type;

@end
