//
//  SystemMsgManager.m
//  WhistleIm
//
//  Created by liuke on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemMsgManager.h"
#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"
#include "SystemMessageInfo.h"
#import "CrowdManager.h"
#import "RosterManager.h"
#import "LocalRecentListManager.h"
#import "RecentRecord.h"


@interface SystemMsgManager()<LocalRecentListDelegate>
{
    NSMutableArray* list_;
}

@end

@implementation SystemMsgManager

SINGLETON_IMPLEMENT(SystemMsgManager)

- (id) init
{
    self = [super init];
    if (self) {
        list_ = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void) register4Biz
{
    [super register4Biz];
    [[LocalRecentListManager shareInstance] addListener:self];
}



- (void) reset
{
    [super reset];
    [list_ removeAllObjects];
    [[LocalRecentListManager shareInstance] addListener:self];
}

- (void) getSystemMsgList:(int)index withCount:(NSUInteger)count
{
    void(^getSystemListener)(NSDictionary*) = ^(NSDictionary* data){
        LOG_NETWORK_DEBUG(@"得到系统消息的原始数据：%@", data);
        [self onGetSystemMsgListImpl:data];
    };
    if (count > 0 && count <= 1000000) {
        [[BizlayerProxy shareInstance] getSystemMessage:nil withbeginidx:index withcount:count withListener:getSystemListener];
    }
}

- (void) add2SystemList:(SystemMessageInfo*) info
{
    for (SystemMessageInfo* smi in list_) {
        if ([smi.rowId isEqualToString:info.rowId]) {
            return;
        }
    }
    [list_ addObject:info];
}

- (void) onGetSystemMsgListImpl:(NSDictionary*) data
{
    [self runInThread:^{
        ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
        if(resultInfo.succeed) {
            id msgs = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"data" withClass:[SystemMessageInfo class]];
            int count_all = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_COUNT_ALL defaultValue:0];
            if ([self isNull:msgs]) {
                
            }else{
                for (SystemMessageInfo* info in msgs) {
                    [self add2SystemList:info];
                }
            }
            [self sendGetSystemMsgListFinishDelegate: count_all];
            [self getExtraInfo];
        }else{
            [self sendGetSystemMsgListFailureDelegate];
        }
    }];
}

- (void) getExtraInfo:(SystemMessageInfo *)sinfo withCallback:(void (^)())callback
{
    if (sinfo.extraObject) {
        //已经绑定过值则不再重新绑定
        callback();
    }
    if ([sinfo isCrowdSystemMsg]) {
        [self getExtraInfoByCrowdSystemInfo:sinfo withCallback:^{
            callback();
        }];
    }else if([sinfo isFriendSystemMsg]){
        [self getExtraInfoByFriendSystemInfo:sinfo withCallback:^{
            callback();
        }];
    }else{
        callback();
    }
}

- (void) getExtraInfo
{
    __block int count = 0;
    for (SystemMessageInfo* info in list_) {
        if (info.extraObject) {
            //已经绑定过值则不再重新绑定
            continue;
        }
        if ([info isCrowdSystemMsg]) {
            count ++;
            [self getExtraInfoByCrowdSystemInfo:info withCallback:^{
                count --;
                if (count <= 0) {
                    [self sendSystemMsgListChangedDelegate];
                }
            }];
        }else if([info isFriendSystemMsg]){
            count ++;
            [self getExtraInfoByFriendSystemInfo:info withCallback:^{
                count --;
                if (count <= 0) {
                    [self sendSystemMsgListChangedDelegate];
                }
            }];
        }
    }
}

- (void) sortSystemMsg
{
    NSArray* tmp = [list_ sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SystemMessageInfo* s1 = obj1;
        SystemMessageInfo* s2 = obj2;
        return [s1.lastTime compare:s2.lastTime] == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending;
    }];
    [list_ removeAllObjects];
    [list_ addObjectsFromArray:tmp];
    tmp = nil;
}

- (void) ackAddFriendInvite:(NSString*) jid isAgree:(BOOL)isAgree withCallback:(void (^)(BOOL))callback
{
    [[RosterManager shareInstance] ackFriendInvite:jid isAgree:isAgree withCallback:callback];
}

- (void) addFriend:(NSString *)jid withMsg:(NSString *)msg withCallback:(void (^)(BOOL))callback
{
    [[RosterManager shareInstance] addBuddyWithJid:jid withMsg:msg withCallback:callback];
}

- (void) getExtraInfoByCrowdSystemInfo:(SystemMessageInfo*) sinfo withCallback:(void(^)()) callback
{
    [[CrowdManager shareInstance] getCrowdDetailInfoBySessionID:sinfo.jid
                                                   WithCallback:^(CrowdInfo *crowd) {
        if (crowd) {
            sinfo.extraObject = crowd;
        }else{
            CrowdInfo* dismissCrowd = [[CrowdInfo alloc] init];
            dismissCrowd.session_id = sinfo.jid;
            dismissCrowd.name = sinfo.crowd_name;
            dismissCrowd.category = sinfo.category;
            sinfo.crowdHasDismiss = YES;
            sinfo.extraObject = dismissCrowd;
        }
        callback();
    }];
}

- (void) getExtraInfoByFriendSystemInfo:(SystemMessageInfo*) sinfo withCallback:(void(^)()) callback
{
    [[RosterManager shareInstance] getFriendInfoByJid:sinfo.jid checkStrange:YES WithCallback:^(FriendInfo *friend) {
        sinfo.extraObject = friend;
        callback();
    }];
}

- (void) delete1SystemMsgFromList:(NSString*) rowid
{
    for (SystemMessageInfo* info in list_) {
        if ([info.rowId isEqualToString:rowid]) {
            [list_ removeObject:info];
            return;
        }
    }
}

- (void) markSystemRead:(SystemMessageInfo *)info withCallback:(void (^)(BOOL))callback
{
    if (info.isRead) {
        return;
    }
    [[BizlayerProxy shareInstance] markSystemMessageRead: info.rowId  withListener:^(NSDictionary* data){
        ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
        if (resultInfo.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
    info.isRead = YES;
    [self sendSystemMsgListChangedDelegate];
//    [self sendUpdateRecentContactNotify:@"system" from: @"system" to: RecentContactUpdateType_MARKREAD];
}

- (void) deleteSystemMsg:(SystemMessageInfo *)info withCallback:(void(^)(BOOL)) callback
{
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        [self runInThread:^{
            ResultInfo* result = [self parseCommandResusltInfo:data];
            if (result.succeed) {
                LOG_NETWORK_DEBUG(@"删除系统消息成功：%@", [info toString]);
                [self delete1SystemMsgFromList:info.rowId];
                [self sendDeleteSystemMsgDelegate];
                [self sendSystemMsgListChangedDelegate];
                callback(YES);
            }else{
                LOG_NETWORK_DEBUG(@"删除系统消息失败");
                callback(NO);
            }
        }];
    };
    [[BizlayerProxy shareInstance] deleteSystemMessage:info.rowId withListener:listener];
}

- (void) deleteAllSystemMsgWithCallback:(void(^)(BOOL)) callback
{
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        [self runInThread:^{
            ResultInfo* result = [self parseCommandResusltInfo:data];
            if (result.succeed) {
                callback(YES);
            }else{
                LOG_NETWORK_DEBUG(@"删除系统消息失败");
                callback(NO);
            }
        }];
    };
    [[BizlayerProxy shareInstance] deleteSystemMessage:@"" withListener:listener];
}

- (void) updateRecentRecord:(RecentRecord *)rec
{
    if ([rec getType] == RecentRecord_System) {
        [self getSystemMsgList:-1 withCount:20];
    }
}

#pragma 发送delegate函数

- (void) sendSystemMsgListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"系统消息更新信息：%@", [super toArrayString:list_]);
    for (id<SystemMsgDelegate> d in [self getListenerSet:@protocol(SystemMsgDelegate)]) {
        if ([d respondsToSelector:@selector(systemMsgListChanged:)]) {
            [d systemMsgListChanged:list_];
        }
    }
}

- (void) sendGetSystemMsgListFinishDelegate:(int) count_all
{
    [self sortSystemMsg];
    LOG_NETWORK_DEBUG(@"得到系统消息成功：%@", [super toArrayString:list_]);
    for (id<SystemMsgDelegate> d in [self getListenerSet:@protocol(SystemMsgDelegate)]) {
        if ([d respondsToSelector:@selector(getSystemMsgListFinish:countAll:)]) {
            [d getSystemMsgListFinish:list_ countAll:count_all];
        }
    }
}

- (void) sendGetSystemMsgListFailureDelegate
{
    LOG_NETWORK_DEBUG(@"得到系统消息失败");
    for (id<SystemMsgDelegate> d in [self getListenerSet:@protocol(SystemMsgDelegate)]) {
        if ([d respondsToSelector:@selector(getSystemMsgListFailure)]) {
            [d getSystemMsgListFailure];
        }
    }
}

- (void) sendDeleteSystemMsgDelegate
{
    for (id<SystemMsgDelegate> d in [self getListenerSet:@protocol(SystemMsgDelegate)]) {
        if ([d respondsToSelector:@selector(deleteSystemMsgAtSystemMgr)]) {
            [d deleteSystemMsgAtSystemMgr];
        }
    }
}


@end
