//
//  PushMessageManager.m
//  WhistleIm
//
//  Created by wangchao on 13-8-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "MessageManager.h"
#import "Whistle.h"
#import "RosterManager.h"
#import "JSONObjectHelper.h"
#import "FriendInfo.h"
#import "DiscussionManager.h"
#import "RecentAppMessageInfo.h"
#import "RosterManager.h"
#import "CrowdManager.h"
#import "RecentRecord.h"
#import "BaseMessageInfo.h"
#import "LightAppMessageInfo.h"
#import "AppManager.h"
#import "SmileyParser.h"

@interface MessageManager()
{
    NSMutableArray* msgList_;
    NSString* cjid;//当前聊天窗口的jid或者是lightapp的appid
    ConversationType type_;//当前聊天的类型
}

@end

@implementation MessageManager

SINGLETON_IMPLEMENT(MessageManager)

- (id) init
{
    self = [super init];
    if (self) {
        msgList_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) register4Biz
{
    [super register4Biz];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void(^recvMsgListener)(NSDictionary*) = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"接收到聊天信息后的原始数据：%@",data);
            [self onRecvMsgListenerImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:recvMsgListener withType:RECV_MSG];
        
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:^(NSDictionary *data) {
            LOG_NETWORK_WARNING(@"发送消息失败的原始数据：%@", data);
            [self onSendMsgFailImpl:data];
        } withType:SEND_MSG_FAIL_NOTIFY];
    });
    
    
    
}

- (void) reset
{
    [super reset];
    [msgList_ removeAllObjects];
}

- (void) onSendMsgFailImpl:(NSDictionary*) data
{
    [self runInThread:^{
        NSString* jid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_APPID];
        NSString* rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROWID];
        NSString* type = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_TYPE];
        if ([@"lightapp" isEqualToString:type]) {
            for (LightAppMessageInfo* info in msgList_) {
                if ([info.jid isEqualToString:jid] && [info.rowid isEqualToString:rowid]) {
                    info.status = MSG_SEND_FAILURE;
                    [self sendOneMsgChanged:info];
                    break;
                }
            }
        }
    }];
}

- (void) sendRecvMsgDelegate:(BaseMessageInfo*) msg
{
    if (cjid && ([msg.jid isEqualToString:cjid] || [cjid hasPrefix:msg.jid] || [msg.jid hasPrefix:cjid])) {
        [msgList_ addObject:msg];
        [self sendConvMsgListChanged];
    }
    if ([msg msgType] != SessionType_LightApp) {
        NSArray* msgs = [ConversationInfo split:(ConversationInfo*)msg];
        [self sendNewMsgUpdateDelegate:msgs];
    }else{
        NSArray* msgs = [[NSArray alloc] initWithObjects:msg, nil];
        [self sendNewMsgUpdateDelegate:msgs];
    }
    msg = nil;
}

- (void) onRecvMsgListenerImpl:(NSDictionary*) data
{
    [self runInThread:^{
        BaseMessageInfo* bmsg = [self msgFactory:data];
//        [msgList_ addObject: bmsg];
        if ([bmsg msgType] == SessionType_LightApp) {
            LightAppMessageInfo* msg = (LightAppMessageInfo*) bmsg;
            //下载lightapp中的图片
            [msgList_ addObject:msg];
            [self sendRecvMsgDelegate:msg];
            [self getExtraInfoByLightapp:msg callback:^{
                [self sendOneMsgChanged:msg];
            }];
        }else{
            ConversationInfo* msg = (ConversationInfo*)bmsg;
            for (ConversationInfo *info in [ConversationInfo split:msg]) {
                if ([info msgType] == SessionType_Conversation) {
                    if ([info.jid hasPrefix:[[RosterManager shareInstance] mySelf].jid]) {
                        //我的设备
                        info.extraInfo = [[RosterManager shareInstance] mySelf];
                        info.showName = [[RosterManager shareInstance] mySelf].showName;
                        [self sendRecvMsgDelegate:info];
                    }else{
                        [[RosterManager shareInstance] getFriendInfoByJid: info.jid needRealtime:NO WithCallback:^(FriendInfo *f) {
                            info.extraInfo = f;
                            info.showName = f.showName;
                            [self sendRecvMsgDelegate:info];
                        }];
                    }
                }else if ([info msgType] == SessionType_Crowd){
                    [[RosterManager shareInstance] getFriendInfoByJid:info.send_jid needRealtime:NO WithCallback:^(FriendInfo *f) {
                        info.extraInfo = f;
                        info.crowdOrDiscussion = [[CrowdManager shareInstance] getCrowdInfo:info.jid];
                        [self sendRecvMsgDelegate:info];
                    }];
                }else if ([info msgType] == SessionType_Discussion){
                    //从讨论组中获取
                    [[RosterManager shareInstance] getFriendInfoByJid:info.send_jid checkStrange:NO WithCallback:^(FriendInfo *f) {
                        info.extraInfo = f;
                        info.crowdOrDiscussion = [[DiscussionManager shareInstance] getDiscussion:info.jid];
                        [self sendRecvMsgDelegate:info];
                    }];
                }
                [self getOneConversationImageOrVoice:info];
            }
            
        }
    }];
}

- (void) leaveConversation
{
    cjid = nil;
    [msgList_ removeAllObjects];
}

- (void) getExtraInfoByLightapp:(BaseMessageInfo*) msg callback:(void(^)()) callback
{
    [[AppManager shareInstance] getAppDetailInfoByAppid:msg.jid callback:^(BaseAppInfo *app, BOOL isSuccess) {
        if (isSuccess) {
            LightAppMessageInfo* lmsg = (LightAppMessageInfo*)msg;
            if (lmsg.isSend) {
                lmsg.lightappDetail = [[RosterManager shareInstance] mySelf];
            }else{
                lmsg.lightappDetail = app;
            }
        }
        callback();
    }];
}

- (void) getExtraInfo:(ConversationInfo*) msg withCallback:(void(^)()) callback
{
    if (msg.isSend) {
        msg.extraInfo = [[RosterManager shareInstance] mySelf];
        callback();
    }else if(type_ == SessionType_Crowd || type_ == SessionType_Discussion){
        [[RosterManager shareInstance] getFriendInfoByJid: msg.speaker needRealtime:NO WithCallback:^(FriendInfo *f) {
            [self runInThread:^{
                msg.extraInfo = f;
                callback();
            }];
        }];
    }else if (type_ == SessionType_Conversation){
        if ([msg.jid hasPrefix:[RosterManager shareInstance].mySelf.jid]) {
            //我的设备处理
            msg.extraInfo = [[RosterManager shareInstance] mySelf];
            callback();
        }else{
            [[RosterManager shareInstance] getFriendInfoByJid: msg.jid needRealtime:NO WithCallback:^(FriendInfo *f) {
                [self runInThread:^{
                    msg.extraInfo = f;
                    callback();
                }];
            }];
        }
    }else{
        callback();
    }
}

- (void) getConversation:(NSString *)jid withType:(ConversationType) type withBeginIndex:(NSUInteger) bindex withCount:(NSUInteger) count
{
    cjid = jid;
    [[BizlayerProxy shareInstance] getConversationHistoryWithTargetDetail:jid
                                                             withConvType: [ConversationInfo getConvType:type]
                                                           withBeginIndex:bindex
                                                                withCount:count
                                                             withListener:^(NSDictionary *data) {
         LOG_NETWORK_DEBUG(@"得到历史聊天的原始数据：%@", data);
         ResultInfo* result = [self parseCommandResusltInfo:data];
         if (result.succeed) {
             id msgs = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_DATA withClass:[ConversationInfo class]];
             LOG_NETWORK_DEBUG(@"得到历史聊天的数据：%@", [super toArrayString:msgs]);
             int count_all = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_COUNT_ALL defaultValue:0];
             if ([self isNull:msgs]) {
                 [msgList_ removeAllObjects];
                 [self sendGetConvMsgFinishDelegate:count_all];
             }else{
                 [msgList_ removeAllObjects];
                 [msgList_ addObjectsFromArray:msgs];
                 type_ = type;
                 NSMutableArray* tmp = [self splitConversationMsg:msgList_];
                 [msgList_ removeAllObjects];
                 [msgList_ addObjectsFromArray:tmp];
                 
                 [self sendGetConvMsgFinishDelegate:count_all];

                 __block int count = msgList_.count;
                 for (ConversationInfo* msg in msgList_) {
                     [self getExtraInfo:msg withCallback:^{
                         count --;
                         if (count <= 0) {
                              [self sendConvMsgListChanged];
                         }
                     }];
                 }
                 [self getConversationImageOrVoice:msgList_];
             }

         }else{
             [self sendGetConvMsgFailureDelegate];
         }
                                                                 
     }];
}

- (NSMutableArray*) splitConversationMsg:(NSArray*) ori_msgs
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    for (BaseMessageInfo* msg in ori_msgs) {
        if ([msg msgType] != SessionType_LightApp) {
            ConversationInfo* tmp = (ConversationInfo*) msg;
            tmp.messageType = [ConversationInfo getConvType:type_];
            NSArray* tmp_arr = [ConversationInfo split:tmp];
            [ret addObjectsFromArray:tmp_arr];
        }else{
            [ret addObject:msg];
        }
    }
    return ret;
}

- (void) getOneConversationImageOrVoice:(ConversationInfo*) cinfo
{
    if ([cinfo.msgInfo isImgMsg] && cinfo.status == MSG_RECVING) {//cinfo.msgInfo.txt == nil
        //下载图片
        [[BizlayerProxy shareInstance] getImage:cinfo.msgInfo.src_id withName:cinfo.msgInfo.src withListener:^(NSDictionary *data) {
            [self runInThread:^{
#warning 这个部分得需要测试数据
                ResultInfo* result = [super parseCommandResusltInfo:data];
                if (result.succeed) {
                    NSString *temp = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SRC];
                    
                    cinfo.msgInfo.src = [temp substringFromIndex:[temp rangeOfString:@"/" options:NSBackwardsSearch].location+1];
                    cinfo.status = MSG_RECV_SUCCUSS;
                }else{
                    cinfo.status = MSG_RECV_FAILURE;
                }
                [self sendOneMsgChanged:cinfo];
#warning 这个部分得需要测试数据
            }];
        }];
        
    }else if([cinfo.msgInfo isVoiceMsg] && (cinfo.msgInfo.txt == nil || [@"" isEqualToString:cinfo.msgInfo.txt])){
        //下载语音
        [[BizlayerProxy shareInstance] getVoice:cinfo.msgInfo.src_id withName:cinfo.msgInfo.src withListener:^(NSDictionary *data) {
            [self runInThread:^{
                ResultInfo* result = [super parseCommandResusltInfo:data];
                if (result.succeed) {
                    cinfo.msgInfo.src = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SRC];
                    cinfo.status = MSG_RECV_SUCCUSS;
                }else{
                    cinfo.status = MSG_RECV_FAILURE;
                }
                [self sendOneMsgChanged:cinfo];
            }];
        }];
    }

}

- (void) getConversationImageOrVoice:(NSArray*) msgs
{
    for (BaseMessageInfo* info in msgs) {
        if ([info msgType] != SessionType_LightApp) {
            ConversationInfo* cinfo = (ConversationInfo*) info;
            [self getOneConversationImageOrVoice:cinfo];
        }
    }
}

- (void) getLightappMsg:(NSString *)appid withType:(ConversationType)type withBeginIndex:(NSInteger)bindex withCount:(NSInteger) count
{
    cjid = appid;
    [msgList_ removeAllObjects];
    [[BizlayerProxy shareInstance] getLightappMsgHistory:appid index:bindex count:count callback:^(NSDictionary *data) {
        NSInteger total = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_COUNT_ALL defaultValue:0];
        if (total == 0) {
            [self sendConvMsgListChanged];
            return ;
        }
        if ([data valueForKey:KEY_MSGS] &&  ![super isNull: [data valueForKey:KEY_MSGS]] && [[data valueForKey:KEY_MSGS] isKindOfClass:[NSArray class]]) {
            NSArray* msgs = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_MSGS withClass:[LightAppMessageInfo class]];
            [msgList_ addObjectsFromArray:msgs];
            [self sendGetConvMsgFinishDelegate:total];
            //得到lightapp的其他信息
            __block int cc = msgList_.count;
            for (LightAppMessageInfo* info in msgList_) {
                [self getExtraInfoByLightapp:info callback:^{
                    cc --;
                    if (cc <= 0) {
                        [self sendConvMsgListChanged];
                    }
                }];
            }
            
        }else{
            
        }
    }];
}

- (void) deleteLightapp:(NSString *)appid callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteLightappMessage:appid callback:^(NSDictionary *data) {
        callback(YES);
        [self sendUpdateRecentContactNotify:appid from:[ConversationInfo getConvType:SessionType_LightApp] to:RecentContactUpdateType_EMPTY];
    }];
}

- (void) deleteLightapp:(NSString *)appid rowid:(NSInteger)rowid callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteLightappMessage:appid rowid:[NSString stringWithFormat:@"%d", rowid] callback:^(NSDictionary *data) {
        callback(YES);
    }];
}

- (void) markMessageRead:(NSString *)jid type:(ConversationType)type withCallback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] markMessageRead:jid withType:[ConversationInfo getConvType:type] withListener:^(NSDictionary *data) {
        //没有回调
    }];
    [self sendUpdateRecentContactNotify:jid from:[ConversationInfo getConvType:type] to:RecentContactUpdateType_MARKREAD];
    callback(YES);

}

- (void) markLightMessageRead:(NSString *)jid type:(ConversationType)type withCallback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] setLightAppReaded:jid withListener:^(NSDictionary *data) {
        
    }];
    [self sendUpdateRecentContactNotify:jid from:[ConversationInfo getConvType:type] to:RecentContactUpdateType_MARKREAD];
    callback(YES);
    
}

-(void) deleteAllHistoryMessage:(ConversationType) type withjid:(NSString *)jid withListener:(void(^)(BOOL)) callback
{
    [[BizlayerProxy shareInstance] deleteAllHistoryMessage:[ConversationInfo getConvType:type] withjid:jid withListener:^(NSDictionary *data) {
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
            [self sendUpdateRecentContactNotify:jid from:[ConversationInfo getConvType:type] to:RecentContactUpdateType_EMPTY];
        }else{
            callback(NO);
        }
    }];
    
}
- (void) getConversation:(NSString *)jid withType:(ConversationType) type
{
    [self getConversation:jid withType:type withBeginIndex:0 withCount:20];
}

- (ConversationInfo*) createMsg:(MsgInfo*) msg
{
    ConversationInfo* cmsg = [[ConversationInfo alloc] init];
    cmsg.time = [NSString stringWithFormat:@"%@", [NSDate date]];
    cmsg.isSend = YES;
    cmsg.msgInfo = msg;
    cmsg.speaker = [[RosterManager shareInstance] mySelf].showName;
    cmsg.extraInfo = [[RosterManager shareInstance] mySelf];
    cmsg.status = MSG_SENDING;
    cmsg.jid = cjid;
    return cmsg;
}



- (void) sendMessage:(NSString *)msg callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] sendMessage:cjid withMsg:[[SmileyParser parser] pasreSmilyToPushMessage:msg] withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
    MsgInfo* info = [[MsgInfo alloc] initWithTxt:msg];
    ConversationInfo *ci = [self createMsg:info];
    [msgList_ addObject:ci];
    
    NSArray* array = [[NSArray alloc] initWithObjects:ci, nil];
    [self sendNewMsgUpdateDelegate:array];
}

- (void) sendMessageToPC:(NSString *)msg callback:(void (^)(BOOL))callback
{
    if ([cjid isEqualToString:[RosterManager shareInstance].mySelf.jid]) {
        NSString* jid = [NSString stringWithFormat:@"%@/pc", [RosterManager shareInstance].mySelf.jid];
        [self sendMessage:jid callback:callback];
    }
}

- (void) sendMessageToAndroid:(NSString *)msg callback:(void (^)(BOOL))callback
{
    if ([cjid isEqualToString:[RosterManager shareInstance].mySelf.jid]) {
        NSString* jid = [NSString stringWithFormat:@"%@/android", [RosterManager shareInstance].mySelf.jid];
        [self sendMessage:jid callback:callback];
    }
}

- (NSString*) uuid
{
    return [[NSUUID UUID] UUIDString];
}

- (void) sendImageMessage:(NSString *)src callback:(void (^)(BOOL))callback
{
    if (!cjid) {
        return;
    }
    NSString* uuid = [self uuid];
    
    MsgInfo* info = [[MsgInfo alloc] initWithImg:uuid src:[src substringFromIndex:[src rangeOfString:@"/" options:NSBackwardsSearch].location+1]];
    ConversationInfo *ci = [self createMsg:info];
    ci.status = MSG_SENDING;
    ci.size_ = CGSizeZero;
    [msgList_ addObject:ci];
    
    [[BizlayerProxy shareInstance] sendImageMessage:cjid withID:uuid withSRC:src withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        callback(result.succeed);
        ci.status = result.succeed?MSG_SEND_SUCCUSS:MSG_SEND_FAILURE;
        [self sendConvMsgListChanged];
    }];
    
    NSArray* array = [[NSArray alloc] initWithObjects:ci, nil];
    [self sendNewMsgUpdateDelegate:array];
//    [self sendConvMsgListChanged];
}

- (void) sendVideoMessage:(NSString *)src duration:(int)duration callback:(void (^)(BOOL))callback
{
    NSString* uuid = [self uuid];
    [[BizlayerProxy shareInstance] sendVideoMessage:cjid withID:uuid withSRC:src duration:duration withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
    MsgInfo* info = [[MsgInfo alloc] initWithVideo:uuid src:src];
    info.duration = duration;
    ConversationInfo *ci = [self createMsg:info];
    [msgList_ addObject:ci];
    
    NSArray* array = [[NSArray alloc] initWithObjects:ci, nil];
    [self sendNewMsgUpdateDelegate:array];
//    [self sendConvMsgListChanged];
}

- (void) sendVoiceMessage:(NSString *)src duration:(int)duration callback:(void (^)(BOOL))callback
{
    NSString* uuid = [self uuid];
    MsgInfo* info = [[MsgInfo alloc] initWithVoice:uuid src:src];
    info.duration = duration;
    ConversationInfo* con = [self createMsg:info];
    [msgList_ addObject: con];
    
    NSArray* array = [[NSArray alloc] initWithObjects:con, nil];
    
    [[BizlayerProxy shareInstance] sendVoiceMessage:cjid withID:uuid withSRC:src duration:duration withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            NSDictionary* tmp = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_ARGS];
            NSDictionary* msg__ = [JSONObjectHelper getJSONFromJSON:tmp forKey:KEY_MSG];
            MsgInfo* mm = [JSONObjectHelper getObjectFromJSON:msg__ withClass:[MsgInfo class]];
            con.msgInfo = mm;
            con.status = MSG_SEND_SUCCUSS;
            callback(YES);
            [self getOneConversationImageOrVoice:con];
        }else{
            con.status = MSG_SEND_FAILURE;
            callback(NO);
        }
    }];
    
    [self sendNewMsgUpdateDelegate:array];
//    [self sendConvMsgListChanged];
}

- (void) sendLightAppMessage:(NSString *)appid text:(NSString *)txt
{
    LightAppMessageInfo* info = [[LightAppMessageInfo alloc] init4Text:appid txt:txt];
    [[BizlayerProxy shareInstance] sendLightAppMessage:appid text:txt callback:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"发送text轻应用返回的原始数据：%@", data);
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            NSString* rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROWID];
            info.rowid = rowid;
            [self sendConvMsgListChanged];
        }
    }];
    info.lightappDetail = [[RosterManager shareInstance] mySelf];
    [msgList_ addObject:info];
    
    NSArray* array = [[NSArray alloc] initWithObjects:info, nil];
    [self sendNewMsgUpdateDelegate:array];
//    [self sendConvMsgListChanged];
}

- (void) sendLightAppMessage:(NSString *)appid event:(NSString *)event eventKey:(NSString *)eventKey
{
    [[BizlayerProxy shareInstance] sendLightAppMessage:appid event:event eventKey:eventKey callback:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"发送text轻应用返回的原始数据：%@", data);
//        ResultInfo* result = [super parseCommandResusltInfo:data];
//        if (result.succeed) {
//            NSString* rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROWID];
//            info.rowid = rowid;
//            [self sendConvMsgListChanged];
//        }
    }];
}

-(void)sendHelloMessage:(NSString *)jid withID:(NSString *)uuid
{
    [[BizlayerProxy shareInstance] sendHelloMessage:jid withID:uuid withListener:^(NSDictionary *data) {
        
    }];
}

- (void) sendLightAppMessage:(NSString *)appid image:(NSString *)filepath
{
    LightAppMessageInfo* info = [[LightAppMessageInfo alloc] init4Image:appid image:[filepath componentsSeparatedByString:@"/"].lastObject];
    info.status = MSG_SENDING;
    [[BizlayerProxy shareInstance] sendLightAppMessage:appid image:filepath callback:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"发送image轻应用返回的原始数据：%@", data);
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            NSString* rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROWID];
            info.rowid = rowid;
        }
        info.status = result.succeed?MSG_SEND_SUCCUSS:MSG_SEND_FAILURE;
        [self sendConvMsgListChanged];
    }];
    info.lightappDetail = [[RosterManager shareInstance] mySelf];
    [msgList_ addObject:info];
    NSArray* array = [[NSArray alloc] initWithObjects:info, nil];
    [self sendNewMsgUpdateDelegate:array];
//    [self sendConvMsgListChanged];
}

- (void) sendLightAppMessage:(NSString *)appid voice:(NSString *)filepath lenght:(NSUInteger) length callback:(void (^)(BOOL))callback
{
    LightAppMessageInfo* info = [[LightAppMessageInfo alloc] init4Voice:appid voice:filepath length:length];
    [[BizlayerProxy shareInstance] sendLightAppMessage:appid voice:filepath length:length callback:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"发送声音轻应用返回的原始数据：%@", data);
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            NSString* rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROWID];
            info.rowid = rowid;
            [self sendConvMsgListChanged];
        }
        callback(result.succeed);
    }];
    info.lightappDetail = [[RosterManager shareInstance] mySelf];
    [msgList_ addObject:info];
    NSArray* array = [[NSArray alloc] initWithObjects:info, nil];
    [self sendNewMsgUpdateDelegate:array];
}

- (void) markVoiceOrVideoMsgRead:(ConversationInfo *)msg callback:(void (^)(BOOL))callback
{
    [msg markVoiceOrVideoRead];
    callback(YES);
}

- (BaseMessageInfo*) msgFactory:(NSDictionary *)data
{
    BaseMessageInfo* info = [JSONObjectHelper getObjectFromJSON:data withClass:[BaseMessageInfo class]];
    if ([info msgType] == SessionType_LightApp) {
        LightAppMessageInfo* lapp = [JSONObjectHelper getObjectFromJSON:data withClass:[LightAppMessageInfo class]];
        return lapp;
    }else{
        ConversationInfo* cinfo = [JSONObjectHelper getObjectFromJSON:data withClass:[ConversationInfo class]];
        return cinfo;
    }
}

- (void) getLightappMenu:(NSString *)appid callback:(void (^)(NSArray *))callback
{
    [[AppManager shareInstance] getMenu:appid callback:callback];
}


#pragma 发送delegate函数

- (void) sendConvMsgListChanged
{
    LOG_NETWORK_INFO(@"聊天信息列表变更后的数据：%@", [self toArrayString:msgList_]);
    for (id<MessageManagerDelegate> d in [self getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(convMsgListChanged:)]) {
            [d convMsgListChanged:msgList_];
        }
    }
}

- (void) sendMsgItemUpdateDelegate:(BaseMessageInfo*) info
{
    LOG_NETWORK_INFO(@"接收到最新聊天信息的数据：%@", [info toString]);
    for (id<MessageManagerDelegate> d in [self getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(msgItemUpdate:)]) {
            [d msgItemUpdate:info];
        }
    }
}

- (void) sendGetConvMsgFinishDelegate:(NSUInteger) count_all
{
    LOG_NETWORK_INFO(@"得到历史聊天信息成功后得到的数据：%@; 总信息条数：%d", [self toArrayString:msgList_], count_all);
    for (id<MessageManagerDelegate> d in [self getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(getConvMsgFinish:withCountAll:)]) {
            [d getConvMsgFinish:msgList_ withCountAll:count_all];
        }
    }
}

- (void) sendGetConvMsgFailureDelegate
{
    LOG_NETWORK_ERROR(@"得到历史聊天信息失败");
    for (id<MessageManagerDelegate> d in [self getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(getConvMsgFailure)]) {
            [d getConvMsgFailure];
        }
    }
}

- (void) sendOneMsgChanged:(BaseMessageInfo*) msg
{
    LOG_NETWORK_ERROR(@"一条聊天信息的内容发生变化：%@", [msg toString]);
    for (id<MessageManagerDelegate> d in [self getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(oneMsgChanged:)]) {
            [d oneMsgChanged:msg];
        }
    }
    [self sendConvMsgListChanged];
}

- (void) sendNewMsgUpdateDelegate:(NSArray*) msgs_splited
{
    LOG_NETWORK_DEBUG(@"接收到最新聊天消息，可能会被拆分：%@", [super toArrayString:msgs_splited]);
    for (id<MessageManagerDelegate> d in [super getListenerSet:@protocol(MessageManagerDelegate)]) {
        if ([d respondsToSelector:@selector(newMsgUpdate:)]) {
            [d newMsgUpdate:msgs_splited];
        }
    }
}


@end
