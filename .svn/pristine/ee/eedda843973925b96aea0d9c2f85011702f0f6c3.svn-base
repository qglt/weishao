//
//  LocalRecentListManager.m
//  WhistleIm
//
//  Created by wangchao on 13-8-8.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "LocalRecentListManager.h"

#import "JSONObjectHelper.h"
#import "BizBridge.h"
#import "RosterManager.h"
#import "DiscussionManager.h"
#import "CrowdManager.h"
#import "ChatGroupInfo.h"
#import "RosterManager.h"
#import "SystemMsgManager.h"
#import "ImUtils.h"
#import "AppManager.h"
#import "LightAppMessageInfo.h"
#import "LightAppInfo.h"
#import "SystemMsgManager.h"


static BOOL isLoad_ = NO;
@interface LocalRecentListManager() <DiscussionDelegate, CrowdDelegate, RosterDelegate, SystemMsgDelegate>
{
    NSMutableArray* list_;
    
    BOOL isGetSuccuss_;
    //判断数据是否已经准备好
    BOOL isCrowdReady_;
    BOOL isDiscussionReady_;
    
    __weak NSArray* crowdList_;
    __weak NSArray* discussionList_;
}
@end

@implementation LocalRecentListManager

SINGLETON_IMPLEMENT(LocalRecentListManager)

- (id) init
{
    self = [super init];
    if (self) {
        list_ = [[NSMutableArray alloc] initWithCapacity:50];
        isCrowdReady_ = NO;
        isDiscussionReady_ = NO;
        isGetSuccuss_ = NO;
        
        [[CrowdManager shareInstance] addListener:self];
        [[DiscussionManager shareInstance] addListener:self];
        [[RosterManager shareInstance] addListener:self];
        [[SystemMsgManager shareInstance] addListener:self];
    }
    return self;
}

- (void) register4Biz
{
    [super register4Biz];

    __weak LocalRecentListManager* _self = self;

    LOG_NETWORK_DEBUG(@"向biz层注册事件");
    if (!isLoad_) {
        void(^getListListener)(NSDictionary*) = ^(NSDictionary *result){
            LOG_NETWORK_DEBUG(@"得到最近联系人列表的原始数据：%@", result);
            [_self onGetLocalRecentListImpl:result];
        };
        [[BizlayerProxy shareInstance] getLocalRecentList:getListListener];
        isLoad_ = YES;
    }
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        

        
        void(^itemUpdateNewListener)(NSDictionary*)  = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"最近联系人消息更新的原始数据：%@", data);
            [_self onItemUpdateImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:itemUpdateNewListener withType:NOTIFY_update_recent_contact];
    });
    
}

- (void) onGetLocalRecentListImpl:(NSDictionary*) data
{
    [self runInThread:^{
        @autoreleasepool {
            ResultInfo* resultInfo = [self parseCommandResusltInfo:data];
            if (resultInfo.succeed) {
                id returnData = [JSONObjectHelper getObjectArrayFromJsonObject:data
                                                                        forKey:@"RecentList"
                                                                     withClass:[RecentRecord class]];
                [list_ removeAllObjects];
                if ([self isNull:returnData]) {
                    [self sendGetLocalRecentListFinishDelegate];
                }else{

                    [list_ addObjectsFromArray:returnData];
                    __block int count = [returnData count];
                    for (RecentRecord* rr in returnData) {
                        if ([rr getType] == RecentRecord_System) {
                            [self operatorSystem:rr withCallback:^{
                                count --;
                                if (count <= 0) {
                                    [self sendGetLocalRecentListFinishDelegate];
                                }
                            }];
                        }else if ([rr getType] == RecentRecord_Conversation) {
                            [self operatorConvarsion:rr withCallback:^{
                                count --;
                                if (count <= 0) {
                                    [self sendGetLocalRecentListFinishDelegate];
                                }
                            }];
                            
                        }else if ([rr getType] == RecentRecord_Discussion) {
                            [self operatorDiscussion:rr withCallback:^{
                                count --;
                                if (count <= 0) {
                                    [self sendGetLocalRecentListFinishDelegate];
                                }
                            }];
                        }else if ([rr getType] == RecentRecord_Crowd) {
                            [self operatorCrowd:rr withCallback:^{
                                count --;
                                if (count <= 0) {
                                    [self sendGetLocalRecentListFinishDelegate];
                                }
                            }];
                        }else if ([rr getType] == RecentRecord_LightApp){
                            count --;
                            if (count <= 0) {
                                [self sendGetLocalRecentListFinishDelegate];
                            }
                            [self operatorLightapp:rr withCallback:^{
                                [self sendLocalRecentListChangedDelegate];
                            }];
                        }
                    }
                }
            }else{
                [self sendGetLocalRecentListFailureDelegate];
            }
        }
    }];
}

//得到最新系统消息
- (void) getSystemMsgLocalRecentList:(void(^)(RecentRecord*)) callback
{
    [[BizlayerProxy shareInstance] getLocalRecentList:^(NSDictionary *data) {
        [self runInThread:^{
            ResultInfo* resultInfo = [self parseCommandResusltInfo:data];
            if (resultInfo.succeed) {
                id returnData = [JSONObjectHelper getObjectArrayFromJsonObject:data
                                                                        forKey:@"RecentList"
                                                                     withClass:[RecentRecord class]];
                if ([self isNull:returnData]) {
                    callback(nil);
                }else{
                    for (RecentRecord* rr in returnData) {
                        if ([rr getType] == RecentRecord_System) {
                            [self operatorSystem:rr withCallback:^{
                                callback(rr);
                            }];
                            return ;
                        }
                    }
                    callback(nil);
                }
            }else{
                callback(nil);
            }
        }];

    }];
}

- (void) replaceNewSystemMsg:(RecentRecord*) rec
{
    [self deleteSystemMsg];
    if (rec) {
        [list_ insertObject:rec atIndex:0];
        [self sendLocalRecentListChangedDelegate];
    }

}

- (void) operatorSystem:(RecentRecord*) rec withCallback:(void(^)()) callback
{
    [[SystemMsgManager shareInstance] getExtraInfo:rec.extraInfo withCallback:^{
        [self runInThread:^{
            callback();
        }];
    }];
}


- (void) operatorConvarsion:(RecentRecord*) rec withCallback:(void(^)()) callback
{
    if (rec.extraInfo) {
        callback();
    }else{
        if ([rec.jid hasPrefix:[self myself].jid]) {
            //是我的设备
            if ([rec.jid hasSuffix:KEY_PC]) {
                //pc设备
                rec.speaker = @"我的电脑";
            }else if([rec.jid hasSuffix:KEY_ANDROID]){
                rec.speaker = @"我的Android";
            }
            rec.extraInfo = [self myself];
            rec.isMyDevice = YES;
            callback();
        }else{
            [[RosterManager shareInstance] getFriendInfoByJid:rec.jid
                                                 checkStrange:YES
                                                 WithCallback:^(FriendInfo *info) {
                 [self runInThread:^{
                     rec.extraInfo = info;
                     rec.speaker = info.showName;
                     callback();
                 }];
             }];
        }
    }
}


- (void) operatorDiscussion:(RecentRecord*) rec withCallback:(void(^)()) callback
{
    [self runInThread:^{
        ChatGroupInfo* info = [self getDiscussionByjid:rec.jid];
        if ([self isNull:info]) {
            [list_ removeObject:rec];
            [[BizlayerProxy shareInstance] removeRecentContact:rec.jid
                                                  withListener:^(NSDictionary *data) {
                                                      [self runInThread:^{
                                                          callback();
                                                      }];
                                                  }];
        }else{
            rec.extraInfo = info;
            callback();
        }

    }];
}

- (void) operatorCrowd:(RecentRecord*) rec withCallback:(void(^)()) callback
{
    [self runInThread:^{
        CrowdInfo* info = [self getCrowdByjid:rec.jid];
        if ([self isNull:info]) {
            //会话中的群id不在当前用户群列表中
            [list_ removeObject:rec];
            [[BizlayerProxy shareInstance] removeRecentContact:rec.jid
                                                  withListener:^(NSDictionary *data) {
                                                  }];
            callback();
        }else{
            rec.extraInfo = info;
            if ([rec getType] == RecentRecord_Crowd && [@"微哨用户" isEqualToString: rec.speaker]) {
                //可能是默认值，需要通过speakerid重新获取speaker的名字
                [[RosterManager shareInstance] getFriendInfoByJid:rec.speakerID checkStrange:YES WithCallback:^(FriendInfo *f) {
                    LOG_NETWORK_DEBUG(@"通过群speakerid得到的好友信息：%@", [f toString]);
                    rec.speaker = f.showName;
                    callback();
                }];
            }else{
                callback();
            }
        }

    }];
}

- (void) operatorLightapp:(RecentRecord*) rr withCallback:(void(^)()) callback
{
    [self runInThread:^{
        [[AppManager shareInstance] getAppDetailInfoByAppid:rr.jid callback:^(BaseAppInfo *app, BOOL isSucess) {
            if (isSucess) {
                LightAppMessageInfo* info = rr.extraInfo;
                info.lightappDetail = app;
            }
            callback();
        }];

    }];
}

- (void) deleteSystemMsg
{
    RecentRecord* del = nil;
    for (RecentRecord* info in list_) {
        if ([info getType] == RecentRecord_System) {
            del = info;
            break;
        }
    }
    if (del) {
        [list_ removeObject:del];
    }
}

#warning 这个函数中的逻辑要进行优化
- (void) onItemUpdateImpl:(NSDictionary*) data
{
    [self runInThread:^{
        RecentRecord* rr = [JSONObjectHelper getObjectFromJSON:data withClass:[RecentRecord class]];
        if ([rr getType] == RecentRecord_System) {
            RecentRecord* tmp = [self getSystemRecordByJid:rr.jid];
            if ([self isNull:tmp]) {
                [list_ insertObject:rr atIndex:0];
                if (rr.updateType == RecentContactUpdateType_NEW ||
                    rr.updateType == RecentContactUpdateType_UPDATECURRENT) {
                    [self operatorSystem:rr withCallback:^{
                        [self sendLocalRecentListChangedDelegate];
                        [self sendUpdateRecentRecordDelegate:rr];
                    }];
                }else{
                    [self sendLocalRecentListChangedDelegate];
                }
            }else{
                if (rr.updateType == RecentContactUpdateType_NEW ){
                    [self deleteSystemMsg];
                    [list_ insertObject:rr atIndex:0];
                    [self operatorSystem:rr withCallback:^{
                        [self sendLocalRecentListChangedDelegate];
                        [self sendUpdateRecentRecordDelegate:rr];
                    }];
                }else if(rr.updateType == RecentContactUpdateType_EMPTY){
                    [self deleteSystemMsg];
                    [self sendLocalRecentListChangedDelegate];
                }else if (rr.updateType == RecentContactUpdateType_MARKREAD){
                    rr.unreadAccount --;
                    [self sendLocalRecentListChangedDelegate];
                }else if (rr.updateType == RecentContactUpdateType_DELETE){
                    [self deleteSystemMsg];
                    [self sendLocalRecentListChangedDelegate];
                }else if(rr.updateType == RecentContactUpdateType_UPDATECURRENT) {
                    [self deleteSystemMsg];
                    [self operatorSystem:rr withCallback:^{
                        [list_ insertObject:rr atIndex:0];
                        [self sendLocalRecentListChangedDelegate];
                    }];
                }else{
                    [self sendLocalRecentListChangedDelegate];
                }
            }
        }else if([rr getType] == RecentRecord_LightApp){
            RecentRecord* tmp = [self getLightappRecordByAppid:rr.jid];
            if (rr.updateType == RecentContactUpdateType_DELETE){
                if (![self isNull:tmp]) {
                    [list_ removeObject:tmp];
                }
                [self sendLocalRecentListChangedDelegate];
            }else if(rr.updateType == RecentContactUpdateType_EMPTY){
                if (![self isNull:tmp]) {
                    tmp.unreadAccount = 0;
                    tmp.msgContent = nil;
                    tmp.msgContent = [NSMutableDictionary dictionary];
                    LightAppMessageInfo* info = rr.extraInfo;
                    info.content = @"";
                }
                [self sendLocalRecentListChangedDelegate];
            }else
            {
                if ([self isNull:tmp]) {
                    //列表中不存在
                }else{
                    [list_ removeObject:tmp];
                }
                [list_ insertObject:rr atIndex:0];
                [[AppManager shareInstance] getAppDetailInfoByAppid:rr.jid callback:^(BaseAppInfo *app, BOOL isSucess) {
                    if (isSucess) {
                        LightAppMessageInfo* info = rr.extraInfo;
                        info.lightappDetail = app;
                        
                    }else{
                        
                    }
                    [self sendLocalRecentListChangedDelegate];
                }];
            }
        }else{
            RecentRecord* tmp = [self getNotSystemRecentRecordByJid:rr.jid];
            if (rr.updateType == RecentContactUpdateType_NEW) {
                if ([self isNull:tmp]) {
                    [list_ insertObject:rr atIndex:0];
                    if ([rr getType] == RecentRecord_Conversation) {
                        [self operatorConvarsion:rr withCallback:^{
                            [self sendLocalRecentListChangedDelegate];
                            [self sendUpdateRecentRecordDelegate:rr];
                        }];
                    }else if ([rr getType] == RecentRecord_Discussion) {
                        [self operatorDiscussion:rr withCallback:^{
                            [self sendLocalRecentListChangedDelegate];
                            [self sendUpdateRecentRecordDelegate:rr];
                        }];
                    }else if ([rr getType] == RecentRecord_Crowd) {
                        [self operatorCrowd:rr withCallback:^{
                            [self sendLocalRecentListChangedDelegate];
                            [self sendUpdateRecentRecordDelegate:rr];
                        }];
                    }
                }else{
                    rr.extraInfo = tmp.extraInfo;
                    if ([rr getType] == RecentRecord_Crowd && [@"微哨用户" isEqualToString: rr.speaker]) {
                        //可能是默认值，需要通过speakerid重新获取speaker的名字
                        [[RosterManager shareInstance] getFriendInfoByJid:rr.speakerID checkStrange:YES WithCallback:^(FriendInfo *f) {
                            [self runInThread:^{
                                LOG_NETWORK_DEBUG(@"通过群speakerid得到的好友信息：%@", [f toString]);
                                rr.speaker = f.showName;
                                [list_ removeObject:tmp];
                                [list_ insertObject:rr atIndex:0];
                                [self sendLocalRecentListChangedDelegate];
                                [self sendUpdateRecentRecordDelegate:rr];
                            }];
                        }];
                    }else{
                        if (!(rr.speaker) || [@"" isEqualToString:rr.speaker]) {
                            rr.speaker = tmp.speaker;
                        }
                        [list_ removeObject:tmp];
                        [list_ insertObject:rr atIndex:0];
                        [self sendLocalRecentListChangedDelegate];
                        [self sendUpdateRecentRecordDelegate:rr];
                    }
                }
            }else if (rr.updateType == RecentContactUpdateType_UPDATECURRENT){
                if (![self isNull: tmp]) {
                    [tmp reset:rr.toJsonObject];
                }
                [self sendLocalRecentListChangedDelegate];
            }else if(rr.updateType == RecentContactUpdateType_EMPTY){
                if (![self isNull:tmp]) {
                    tmp.unreadAccount = 0;
                    tmp.msgContent = nil;
                    tmp.msgContent = [NSMutableDictionary dictionary];
                }
                [self sendLocalRecentListChangedDelegate];
            }else if (rr.updateType == RecentContactUpdateType_MARKREAD){
                if (![self isNull:tmp]) {
                    tmp.unreadAccount = 0;
                }
                [self sendLocalRecentListChangedDelegate];
            }else if (rr.updateType == RecentContactUpdateType_DELETE){
                if (![self isNull:tmp]) {
                    [list_ removeObject:tmp];
                }
                [self sendLocalRecentListChangedDelegate];
            }else{
                if ([rr getType] == RecentRecord_Crowd && [@"微哨用户" isEqualToString: rr.speaker]) {
                    //可能是默认值，需要通过speakerid重新获取speaker的名字
                    //                        [[CrowdManager shareInstance] getCrowdMember:rr.jid withFriendJid:rr.speakerID withCallback:^(FriendInfo *f) {
                    [[RosterManager shareInstance] getFriendInfoByJid:rr.speakerID checkStrange:YES WithCallback:^(FriendInfo *f) {
                        LOG_NETWORK_DEBUG(@"通过群speakerid得到的好友信息：%@", [f toString]);
                        rr.speaker = f.showName;
                        [list_ removeObject:tmp];
                        [list_ insertObject:rr atIndex:0];
                        [self sendLocalRecentListChangedDelegate];
                        [self sendUpdateRecentRecordDelegate:rr];
                    }];
                }else{
                    if (!(rr.speaker) || [@"" isEqualToString:rr.speaker]) {
                        rr.speaker = tmp.speaker;
                    }
                    [list_ removeObject:tmp];
                    [list_ insertObject:rr atIndex:0];
                    [self sendLocalRecentListChangedDelegate];
                    [self sendUpdateRecentRecordDelegate:rr];
                }
            }
        }
    }];
}

- (void) reset
{
    [super reset];
    [list_ removeAllObjects];
    isLoad_ = NO;

    //向其他基础manager注册delegate
    [[CrowdManager shareInstance] addListener:self];
    [[DiscussionManager shareInstance] addListener:self];
    [[RosterManager shareInstance] addListener:self];
    [[SystemMsgManager shareInstance] addListener:self];
}

- (void) getRecentList
{
    [self runInThread:^{
        if (isGetSuccuss_) {
            [self sendGetLocalRecentListFinishDelegate];
        }
    }];
}

- (void) registerLocalRecentManager
{
    if (isCrowdReady_ && isDiscussionReady_) {
        [self register4Biz];
        isCrowdReady_ = NO;
        isDiscussionReady_ = NO;
    }
}

- (RecentRecord*) getSystemRecordByJid:(NSString*) jid
{
    for (RecentRecord* rr in list_) {
        if ([rr getType] == RecentRecord_System) {
            return rr;
        }
    }
    return nil;
}

- (RecentRecord*) getNotSystemRecentRecordByJid:(NSString*) jid
{
    RecentRecord* frist = nil;
    NSMutableArray* del = [[NSMutableArray alloc] init];
    for (RecentRecord* rr in list_) {
        if ([rr getType] != RecentRecord_System && [rr.jid isEqualToString:jid]) {
            if (frist) {
                [del addObject:rr];
            }else{
                frist = rr;
            }
        }
    }
    [list_ removeObjectsInArray:del];
    return frist;
}

- (RecentRecord*) getLightappRecordByAppid:(NSString*) appid
{
    for (RecentRecord* rr in list_) {
        if ([rr getType] == RecentRecord_LightApp && [rr.jid isEqualToString:appid]) {
            return rr;
        }
    }
    return nil;
}

- (CrowdInfo*) getCrowdByjid:(NSString*) jid
{
    for (CrowdInfo* info in crowdList_) {
        if ([info.session_id isEqualToString:jid]) {
            return info;
        }
    }
    return nil;
}

- (ChatGroupInfo*) getDiscussionByjid:(NSString*) jid
{
    for (ChatGroupInfo* info in discussionList_) {
        if ([info.sessionId isEqualToString:jid]) {
            return info;
        }
    }
    return nil;
}

- (FriendInfo*) myself
{
    return [[RosterManager shareInstance] mySelf];
}


#pragma 其他manager的delegate函数

//讨论组
- (void) discussionListChanged:(NSArray *)discussionList
{
    
}

//- (void) discussionMemberChanged:(NSArray *)discussionList
//{
//    
//}

- (void) discussionBeDistroy:(ChatGroupInfo *)info
{
    for (RecentRecord* rr in list_) {
        if ([rr getType] == RecentRecord_Discussion) {
            if ([rr.jid isEqualToString:info.sessionId]) {
                [list_ removeObject:rr];
                [self sendLocalRecentListChangedDelegate];
                return;
            }
        }
    }
}

- (void) getDiscussionFailure
{
    isDiscussionReady_ = NO;
}

- (void) getDiscussionFinish:(NSArray *)discussionList
{
    isDiscussionReady_ = YES;
    discussionList_ = discussionList;
    [self registerLocalRecentManager];
}


//群
- (void) crowdListChanged:(NSMutableArray *)crowd_list
{
    for (RecentRecord* rr in list_) {
        if ([rr getType] == RecentRecord_Crowd) {
            NSLog(@"rr jid %@", rr.jid);
            BOOL isFind = NO;
            for (CrowdInfo* cinfo in crowd_list) {
                NSLog(@"crowdinfo jid %@", cinfo.session_id);
                if ([rr.jid isEqualToString:cinfo.session_id]) {
                    isFind = YES;
                    continue;
                }
            }
            if (!isFind) {
                [list_ removeObject:rr];
                [self sendLocalRecentListChangedDelegate];
                break;
            }
        }
    }
}

- (void) getCrowdListFailure
{
    isCrowdReady_ = NO;
}

- (void) getCrowdListFinish:(NSMutableArray *)crowdList
{
    isCrowdReady_ = YES;
    crowdList_ = crowdList;
    [self registerLocalRecentManager];
}

- (void) crowdBeFrozen:(CrowdInfo *)info
{
    [self sendLocalRecentListChangedDelegate];
}

- (void) updateFriendInfo:(FriendInfo *)friend
{
    for (RecentRecord* rr in list_) {
        if ([rr getType] == RecentRecord_Conversation && rr.extraInfo == friend) {
            [self sendLocalRecentListChangedDelegate];
            break;
        }
    }
}

- (void) removeRecentContact:(NSString *)jid withCallback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] removeRecentContact:jid withListener:^(NSDictionary *data) {
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            LOG_NETWORK_DEBUG(@"删除会话列表成功");
            callback(YES);
            for (RecentRecord* rr in list_) {
                if ([rr.jid isEqualToString:jid]) {
                    LOG_NETWORK_DEBUG(@"删除会话列表的详细数据：%@", [rr toString]);
                    [self sendUpdateRecentContactNotify:jid from: rr.type  to: RecentContactUpdateType_DELETE];
                    break;
                }
            }

        }else{
            LOG_NETWORK_ERROR(@"删除会话列表失败");
            callback(NO);
        }
    }];
}

- (void) removeRecentSystemContact:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] removeRecentSystemContact:^(NSDictionary *data) {
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            LOG_NETWORK_DEBUG(@"删除系统消息成功");
            callback(YES);
            [self sendUpdateRecentContactNotify:@"system" from: @"system" to: RecentContactUpdateType_DELETE];
        }else{
            LOG_NETWORK_ERROR(@"删除系统消息失败");
            callback(NO);
        }
    }];
}

- (void) deleteSystemMsgAtSystemMgr
{
    [self runInThread:^{
        [self getSystemMsgLocalRecentList:^(RecentRecord *rec) {
            [self replaceNewSystemMsg:rec];
        }];
    }];
}


/**
 *  去掉重复的信息，比如同一个群不能出现多次
 */

- (BOOL) isExist:(NSArray*) list info:(RecentRecord*) rr
{
    for (RecentRecord* r in list) {
        if ([r.jid isEqualToString:rr.jid]) {
            return YES;
        }
    }
    return NO;
}
- (void) removeDuplicateInfo
{
    NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:list_.count];
    for (RecentRecord* rr in list_) {
        if ([self isExist:tmp info:rr]) {
            continue;
        }else{
            [tmp addObject:rr];
        }
    }
    [list_ removeAllObjects];
    [list_ addObjectsFromArray:tmp];
}

#pragma 发送delegate函数


- (void) sendLocalRecentListChangedDelegate
{
//    [self removeDuplicateInfo];//去掉群信息中重复的
    LOG_NETWORK_DEBUG(@"会话列表变更消息：%@", [super toArrayString:list_]);
    for (id<LocalRecentListDelegate> d in [self getListenerSet:@protocol(LocalRecentListDelegate)]) {
        if ([d respondsToSelector:@selector(localRecentListChanged:)]) {
            if (list_) {
                [d localRecentListChanged:list_];
            }
        }
    }
    [self sendUpdateRecentListUnReadCountDelegate];
}

- (void) sendGetLocalRecentListFinishDelegate
{
    isGetSuccuss_ = YES;
    LOG_NETWORK_DEBUG(@"得到会话列表数据成功的消息：%@", [super toArrayString:list_]);
    for (id<LocalRecentListDelegate> d in [self getListenerSet:@protocol(LocalRecentListDelegate)]) {
        if ([d respondsToSelector:@selector(getLocalRecentListFinish:)]) {
            if (![self isNull:list_]) {
                [d getLocalRecentListFinish:list_];
            }

        }
    }
    [self sendUpdateRecentListUnReadCountDelegate];
}

- (void) sendGetLocalRecentListFailureDelegate
{
    isGetSuccuss_ = NO;
    LOG_NETWORK_DEBUG(@"得到会话列表消息失败");
    for (id<LocalRecentListDelegate> d in [self getListenerSet:@protocol(LocalRecentListDelegate)]) {
        if([d respondsToSelector:@selector(getLocalRecentListFailure)]){
            [d getLocalRecentListFailure];
        }
    }
}

- (void) sendUpdateRecentListUnReadCountDelegate
{
    NSUInteger count = 0;
    for (RecentRecord* rr in list_) {
        count += rr.unreadAccount;
    }
    LOG_NETWORK_DEBUG(@"会话消息未读个数:%d", count);
    for (id<LocalRecentListDelegate> d in [self getListenerSet:@protocol(LocalRecentListDelegate)]) {
        if([d respondsToSelector:@selector(updateRecentListUnReadCount:)]){
            [d updateRecentListUnReadCount:count];
        }
    }
}

- (void) sendUpdateRecentRecordDelegate:(RecentRecord*) rr
{
    BOOL isPlay_ = YES;
    if ([rr getType] == RecentRecord_System) {
        SystemMessageInfo* info = rr.extraInfo;
        if ([info isCrowdSystemMsg] && [info isAnswer]) {
            //不发出声音提示
            isPlay_ = NO;
        }
    }
    //如果当前聊天是自己不发提示
    FriendInfo* myself = [self myself];
    if ([myself.jid isEqualToString:rr.speakerID]) {
        isPlay_ = NO;
    }else if([rr getType] == RecentRecord_Conversation && rr.isSend){
        isPlay_ = NO;
    }else if([rr getType] == RecentRecord_Crowd){
        CrowdInfo* ci = rr.extraInfo;
        if ([ci isVoiceAlert]) {
            isPlay_ = YES;
        }else{
            isPlay_ = NO;
        }
    }
    if (isPlay_) {
        LOG_NETWORK_DEBUG(@"有新消息，向提示音和震动发消息");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playPromptNotification" object:nil];
    }
    LOG_NETWORK_DEBUG(@"会话消息更新：%@", [rr toString]);
    for (id<LocalRecentListDelegate> d in [self getListenerSet:@protocol(LocalRecentListDelegate)]) {
        if([d respondsToSelector:@selector(updateRecentRecord:)]){
            [d updateRecentRecord:rr];
        }
    }
}

@end
