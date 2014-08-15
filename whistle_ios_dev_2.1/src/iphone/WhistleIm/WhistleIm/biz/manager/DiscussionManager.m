//
//  DisscussionManager.m
//  WhistleIm
//
//  Created by wangchao on 13-8-12.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "DiscussionManager.h"
#import "ChatGroupInfo.h"
#import "FriendInfo.h"
#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"
#import "RosterManager.h"


@interface DiscussionManager()
{
    NSMutableArray* discussionList_;
    BOOL isGetDiscussionSuccess_;
    
    NSString* newCreateDiscussionSession_;//新创建的讨论组id
}

@end


@implementation DiscussionManager

SINGLETON_IMPLEMENT(DiscussionManager)

-(id)init
{
    if(self = [super init])
    {
        discussionList_ = [ [NSMutableArray alloc] init];
    }
    return self;
    
}

- (void) register4Biz
{
    [super register4Biz];
    
    __weak DiscussionManager* _self = self;
    [[BizlayerProxy shareInstance] getChatGroupList:^(NSDictionary *data) {
        [_self onGetGroupListImpl:data];
    }];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void(^group_list_listener)(NSDictionary*) = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"讨论组列表变更的原始数据：%@", data);
            [_self onGroupListChangedImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:group_list_listener
                                                                         withType:NOTIFY_chat_group_list_changed];
        
        void(^group_member_listener)(NSDictionary*) = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"讨论组成员变更的原始数据：%@", data);
            [_self onGroupMemberChangedImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:group_member_listener
                                                                         withType:NOTIFY_chat_group_member_changed];
        
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:^(NSDictionary *data) {
            LOG_NETWORK_DEBUG(@"讨论组成员头像更新原始数据：%@", data);
            [self onRecvUpdateDiscussionHeadImpl:data];
        } withType:NoTIFY_RECV_UPDATE_DISCUSSION_HEAD];
    });
    
}

- (void) onGroupMemberChangedImpl:(NSDictionary*) data
{
    [self runInThread:^{
        NSString *sessionId = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SESSION_ID];
        NSString *type = [JSONObjectHelper getStringFromJSONObject:data forKey: KEY_TYPE];
        NSDictionary* memberinfo = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_MEMBER_INFO];
        
        DiscussionMemberInfo *dmi = [JSONObjectHelper getObjectFromJSON:memberinfo withClass:[DiscussionMemberInfo class]];
        if(![self isNull:dmi])
        {
            ChatGroupInfo* groupinfo = [self getGroupByJid:sessionId];
            if (groupinfo && groupinfo.members) {
                if ([KEY_ADD isEqualToString:type]) {
                    //增加新成员
                    [groupinfo.members addObject:dmi];
                }else if([KEY_REMOVE isEqualToString:type]){
                    [groupinfo removeDiscussionMemberByJID:dmi.jid];
                }else if ([KEY_MODIFY isEqualToString:type]){
                    [groupinfo mergeMemberInfo:dmi];
                }
                [self sendDiscussionMemberChangedDelegate:groupinfo];
            }
        }
    }];
}

- (void) onGroupListChangedImpl:(NSDictionary*) data
{
    [self runInThread:^{
        NSString *type =  [JSONObjectHelper getStringFromJSONObject:data forKey:@"type"];
        if ([type isEqualToString:@"modify"]) {
            NSString *topic = [JSONObjectHelper getStringFromJSONObject:data forKey:@"topic"];
            NSString *jid = [JSONObjectHelper getStringFromJSONObject:data forKey:@"id"];
            ChatGroupInfo *info = [self getGroupByJid:jid];
            if(info != nil )
            {
                info.groupName = topic;
            }
            [self sendDiscussionListChangedDelegate];
        }else if ([type isEqualToString:@"remove"] ){
            NSArray *listinfo =  [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"group_info" withClass:[ChatGroupInfo class]];
            for (ChatGroupInfo *tempInfo in listinfo) {
                [self removeGroupBySessionID:tempInfo.sessionId];
            }
            [self sendDiscussionListChangedDelegate];
        }else if ([type isEqualToString:@"destroy"]){
            NSArray *listinfo =  [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"group_info" withClass:[ChatGroupInfo class]];
            for (ChatGroupInfo *tempInfo in listinfo) {
                [self removeGroupBySessionID:tempInfo.sessionId];
                [self sendDiscussionBeDismissDelegate: tempInfo];
            }
            [self sendDiscussionListChangedDelegate];

        
        }else if([type isEqualToString:@"add"])
        {
            NSArray *listinfo =  [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"group_info" withClass:[ChatGroupInfo class]];

            [discussionList_ addObjectsFromArray:listinfo];
            //获取讨论组中成员信息
            __block int count = [listinfo count];
            for (ChatGroupInfo* info in listinfo) {
                [[BizlayerProxy shareInstance] getChatGroupMemberList:info.sessionId
                                                             callback:^(NSDictionary *flist) {
                    [self runInThread:^{
                        ResultInfo* resultInfo = [self parseCommandResusltInfo:flist];
                        if (resultInfo.succeed) {
                            NSMutableArray* members = [JSONObjectHelper getObjectArrayFromJsonObject:flist forKey:KEY_MEMBER_LIST withClass:[DiscussionMemberInfo class]];
                            info.members = members;
                        }
                        count --;
                        if (count <= 0) {
                            [self sendDiscussionListChangedDelegate];
                        }
                    }];
                }];
            }
        }
    }];
}

- (void) onGetGroupListImpl:(NSDictionary*) data
{
    [self runInThread:^{
        @autoreleasepool {
            ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
            if(resultInfo.succeed)
            {
                [discussionList_ removeAllObjects];
                NSArray *groupList =[JSONObjectHelper getObjectArrayFromJsonObject:data
                                                                            forKey:KEY_GROUP_LIST
                                                                         withClass:[ChatGroupInfo class]];
                if([self isNull:groupList]) {
                    
                } else {
                    [discussionList_ addObjectsFromArray:groupList];
                }
                groupList = nil;
                [self sendGetDiscussionFinishDelegate];
                //获取讨论组中成员信息
                __block int count = [discussionList_ count];
                for (ChatGroupInfo* info in discussionList_) {
                    [[BizlayerProxy shareInstance] getChatGroupMemberList:info.sessionId callback:^(NSDictionary *flist) {
                         [self runInThread:^{
                             NSMutableArray *friends =  [JSONObjectHelper getObjectArrayFromJsonObject: flist
                                                                                                forKey:@"member_list" withClass:[FriendInfo class]];
                             info.members = friends;
                             friends = nil;
                             count --;
                             if (count <= 0) {
                                 [self sendDiscussionListChangedDelegate];
                             }
                         }];
                     }];
                }
            }else
            {
                [self sendGetDiscussionFailureDelegate];
            }
        }
    }];
}

- (void) onRecvUpdateDiscussionHeadImpl:(NSDictionary*) data
{
    [super runInThread:^{
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            DiscussionMemberInfo* m = [JSONObjectHelper getObjectFromJSON:data withClass:[DiscussionMemberInfo class]];
            for (ChatGroupInfo* cgi in discussionList_) {
                if ([cgi mergeMemberInfo:m]) {
                    [self sendDiscussionMemberChangedDelegate:cgi];
                    break;
                }
            }
        }
    }];

}

- (BOOL) checkDisscusionIsDistroy:(NSString *)jid
{
    if (!discussionList_) {
        return YES;
    }
    for (ChatGroupInfo* info in discussionList_) {
        if ([info.sessionId isEqualToString:jid]) {
            return NO;
        }
    }
    return YES;
}

- (ChatGroupInfo*) getDiscussion:(NSString *)jid
{
    for (ChatGroupInfo* info in discussionList_) {
        if ([info.sessionId isEqualToString:jid]) {
            return info;
        }
    }
    return nil;
}

-(void)reset
{
    [super reset];
    [discussionList_ removeAllObjects];
}

- (void) getDiscussionList
{
    [self runInThread:^{
        if (isGetDiscussionSuccess_) {
            [self sendGetDiscussionFinishDelegate];
        }else{
            [[BizlayerProxy shareInstance] getChatGroupList:^(NSDictionary *data) {
                [self onGetGroupListImpl:data];
            }];
        }
    }];
}

- (void) removeGroupBySessionID:(NSString*) jid
{
    for (ChatGroupInfo* info in discussionList_) {
        if ([info.sessionId isEqualToString:jid]) {
            [discussionList_ removeObject:info];
            break;
        }
    }
}

- (ChatGroupInfo*) getGroupByJid:(NSString*) jid
{
    for (ChatGroupInfo* info in discussionList_) {
        if ([info.sessionId isEqualToString:jid]) {
            return info;
        }
    }
    return nil;
}

- (void) createChatGroup:(NSString *)groupName friends:(NSArray *)list callback:(void (^)(BOOL))callback
{
    NSString* name = nil;
    if (groupName && ![@"" isEqualToString:groupName]) {
        name = groupName;
    }else{
        name = @"普通讨论组";
    }
    
    [[BizlayerProxy shareInstance] createChatGroup:name withidList:list callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            newCreateDiscussionSession_ = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SESSION_ID];
            [[BizlayerProxy shareInstance] getChatGroupList:^(NSDictionary *data) {
                [self onGetGroupListImpl:data];
            }];
            callback(YES);
        }else{
            callback(NO);
        }
    }];

}


- (void) getDiscussionMember:(NSString *)session_id callback:(void (^)(ChatGroupInfo *))callback
{
    ChatGroupInfo* cg = [self getGroupByJid:session_id];
    if (cg) {
//        if (cg.members) {
//            callback(cg);
//        }else{
        [[BizlayerProxy shareInstance] getChatGroupMemberList:session_id callback:^(NSDictionary *data) {
            ResultInfo* result = [super parseCommandResusltInfo:data];
            if (result.succeed) {
                NSMutableArray* members = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_MEMBER_LIST withClass:[DiscussionMemberInfo class]];
                cg.members = members;
            }
            callback(cg);
        }];
//        }
    }else{
        callback(nil);
    }
}

- (void) inviteIntoDiscussion:(NSString *)session_id friend:(NSArray *)friendJidList callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] inviteBuddyIntoChatGroup:session_id buddies:friendJidList callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) leaveDiscussion:(NSString *)session_id callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] leaveChatGroup:session_id callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) setDiscussionName:(NSString *)session_id name:(NSString *)name callback:(void (^)(BOOL))callback
{
    FriendInfo* my = [[RosterManager shareInstance] mySelf];
    NSString* chatid = [session_id substringWithRange:NSMakeRange(0, [session_id rangeOfString:@"@"].location)];
    NSString* uid = [my.jid substringWithRange:NSMakeRange(0, [my.jid rangeOfString:@"@"].location)];
    [[BizlayerProxy shareInstance] changeChatGroupName:session_id withchatName:name withchatId:chatid withuid:uid withuName:my.showName withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

#pragma 发送delegate函数

- (void) sendDiscussionListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"讨论组列表变更信息：%@", [super toArrayString:discussionList_]);
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if ([obj respondsToSelector:@selector(discussionListChanged:)]) {
            [obj discussionListChanged:discussionList_];
        }

    }
}

- (void) sendDiscussionMemberChangedDelegate:(ChatGroupInfo*) discussion
{
    LOG_NETWORK_DEBUG(@"讨论组成员变更信息：%@", [discussion toString]);
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if ([obj respondsToSelector:@selector(discussionMemberChanged:)]) {
            [obj discussionMemberChanged:discussion];
        }
    }
}

- (void) sendGetDiscussionFinishDelegate
{
    if (newCreateDiscussionSession_) {
        for (ChatGroupInfo* cgi in discussionList_) {
            if ([newCreateDiscussionSession_ isEqualToString:cgi.sessionId]) {
                [self sendCreateDiscussionFinishDelegate:cgi];
                newCreateDiscussionSession_ = nil;
                break;
            }
        }
    }
    LOG_NETWORK_DEBUG(@"得到讨论组成功信息:%@", [super toArrayString:discussionList_]);
    isGetDiscussionSuccess_ = YES;
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if ([obj respondsToSelector:@selector(getDiscussionFinish:)]) {
            [obj getDiscussionFinish:discussionList_];
        }
    }
}

- (void) sendGetDiscussionFailureDelegate
{
    LOG_NETWORK_DEBUG(@"得到讨论组失败");
    isGetDiscussionSuccess_ = NO;
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if([obj respondsToSelector:@selector(getDiscussionFailure)]){
            [obj getDiscussionFailure];
        }
    }
}

- (void) sendDiscussionBeDismissDelegate:(ChatGroupInfo*) info
{
    LOG_NETWORK_DEBUG(@"讨论组被解散后的信息：%@", [info toString]);
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if([obj respondsToSelector:@selector(discussionBeDistroy:)]){
            [obj discussionBeDistroy:info];
        }
    }
}

- (void) sendCreateDiscussionFinishDelegate:(ChatGroupInfo*) info
{
    for (id<DiscussionDelegate> obj in [self getListenerSet:@protocol(DiscussionDelegate)]) {
        if([obj respondsToSelector:@selector(createDiscussionFinish:)]){
            [obj createDiscussionFinish:info];
        }
    }
}

@end
