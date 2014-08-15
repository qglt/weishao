//
//  CrowdManager.m
//  WhistleIm
//
//  Created by liuke on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CrowdManager.h"
#import "BizBridge.h"
#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"
#import "CrowdInfo.h"
#import "BizBridge.h"
#import "Constants.h"
#import "FriendInfo.h"
#import "CrowdVoteInfo.h"
#import "CrowdVoteItmes.h"
#import "RosterManager.h"
#import "OtherManager.h"
#import "CrowdMember.h"

#define CROWD_VOTE_DOMAIN          @"http://whistle.ruijie.com.cn:1093/"
#define CROWD_VOTE_KEY             @"vote"
@interface CrowdManager()
{
    WhistleNotificationListenerType onCrowd_info_changed;
    WhistleNotificationListenerType onCrowd_list_changed;
    WhistleNotificationListenerType onCrowd_member_changed;
    WhistleNotificationListenerType onCrowd_alert_changed;
    WhistleNotificationListenerType onCrowd_system_message;
    
    WhistleNotificationListenerType onRecv_quit_crowd_ack;
    WhistleNotificationListenerType onFile_transfer_status;
    WhistleNotificationListenerType onCrowd_superadmin_applyed_response;
    WhistleNotificationListenerType onCrowd_superadmin_applyed;
    WhistleNotificationListenerType onUpdate_member_head;
    WhistleNotificationListenerType onCrowd_file_changed;
    
    BOOL isGetCrowdSuccess_;
    
    NSMutableArray* crowdList_;
    
    NSMutableDictionary* headDic_;
}

@end

@implementation CrowdManager

SINGLETON_IMPLEMENT(CrowdManager)

- (id) init
{
    return self;
}


- (void) register4Biz
{
    [super register4Biz];


    __block __weak id cself = self;
    
    [self getCrowdListFromListener];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        onCrowd_info_changed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群信息变更的原始数据:%@",data);
            [cself onCrowd_info_changed_impl:data];
        };
        
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_info_changed
                                                                         withType: NOTIRY_crowd_info_changed];
        
        onCrowd_list_changed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群列表信息变更的原始数据:%@",data);
            [cself onCrowd_list_changed_impl:data];
        };
        
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_list_changed
                                                                         withType: NOTIRY_crowd_list_changed];
        
        onCrowd_member_changed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群成员信息变更的原始数据:%@",data);
            [cself onCrowd_member_changed_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_member_changed
                                                                         withType: NOTIRY_crowd_member_changed];
        
        onCrowd_alert_changed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群alert信息变更的原始数据:%@",data);
            [cself onCrowd_alert_changed_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_alert_changed
                                                                         withType: NOTIRY_crowd_alert_changed];
        
        onCrowd_system_message = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群系统信息变更的原始数据:%@",data);
            [cself onCrowd_system_message_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_system_message
                                                                         withType: NOTIRY_crowd_system_message];
        
        
        onRecv_quit_crowd_ack = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"接收到退出群信息变更的原始数据:%@",data);
            [cself onRecv_quit_crowd_ack_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onRecv_quit_crowd_ack
                                                                         withType: NOTIRY_recv_quit_crowd_ack];
        
        onFile_transfer_status = ^(NSDictionary* data){
            [cself onFile_transfer_status_impl:data];
            LOG_NETWORK_DEBUG(@"群文件传输信息变更的原始数据:%@",data);
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onFile_transfer_status
                                                                         withType: NOTIRY_file_transfer_status];
        
        onCrowd_superadmin_applyed_response = ^(NSDictionary* data){
            [cself onCrowd_superadmin_applyed_response_impl:data];
            LOG_NETWORK_DEBUG(@"群crowd_superadmin_applyed_response信息变更的原始数据:%@",data);
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_superadmin_applyed_response
                                                                         withType: NOTIRY_crowd_superadmin_applyed_response];
        
        onCrowd_superadmin_applyed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群crowd_superadmin_applyed信息变更的原始数据:%@",data);
            [cself onCrowd_superadmin_applyed_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_superadmin_applyed
                                                                         withType: NOTIRY_crowd_superadmin_applyed];
        
        onUpdate_member_head = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群update_member_head信息变更的原始数据:%@",data);
            [cself onUpdate_member_head_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onUpdate_member_head
                                                                         withType: NOTIRY_update_member_head];
        
        onCrowd_file_changed = ^(NSDictionary* data){
            LOG_NETWORK_DEBUG(@"群crowd_file_changed信息变更的原始数据:%@",data);
            [cself onCrowd_file_changed_impl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onCrowd_file_changed
                                                                         withType: NOTIRY_crowd_file_changed];
    });
    
}

- (void) getCrowdListFromListener
{
    WhistleCommandCallbackType callback = ^(NSDictionary* data){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"获取群列表的原始数据: %@", data);
            @autoreleasepool {
                ResultInfo *resultInfo = [self parseCommandResusltInfo:data];
                if (resultInfo.succeed) {
                    NSDictionary* dic = [JSONObjectHelper getJSONFromJSON:data forKey:@"crowd_list"];
                    crowdList_= [JSONObjectHelper getObjectArrayFromJsonObject:dic forKey:@"crowd_list" withClass:[CrowdInfo class]];
                    if ([self isNull:crowdList_]){
                        crowdList_ = [[NSMutableArray alloc] init];
                    }
                    LOG_NETWORK_DEBUG(@"得到群列表成功，群列表信息：%@", [super toArrayString:crowdList_]);
                    [self sortCrowdList];
                    [self sendCrowdListFinishDelegate];

                    for (CrowdInfo* ci in crowdList_) {
                        [self getCrowdMembers:ci.session_id callback:^(NSArray *arr) {
                        }];
                    }
                    
                } else {
                    crowdList_ = nil;
                    [self sendCrowdListFailureDelegate];
                    LOG_NETWORK_ERROR(@"得到群列表失败, 失败信息：%@", data);
                }
            }
        }];
    };
    [[BizlayerProxy shareInstance] getCrowdList:callback];
}

- (void) getCrowdList
{
    if (isGetCrowdSuccess_) {
        [self sendCrowdListFinishDelegate];
    }else{
        [self getCrowdListFromListener];        
    }

}

- (void) createCrowd:(NSString *)name icon:(NSString *)icon category:(NSInteger)category authType:(int) auth_type callback:(void (^)(BOOL, NSString*, NSString*))callback
{
    if (!icon || [@"" isEqualToString:icon]) {
        NSUInteger auth = 0;
        if (auth_type >=0 && auth_type <= 2) {
            auth = auth_type;
        }else{
            auth = 0;
        }
        [[BizlayerProxy shareInstance] createCrowd:name icon:icon category:category auth:auth callback:^(NSDictionary *data) {
            ResultInfo* result = [super parseCommandResusltInfo:data];
            if (result.succeed) {
                NSString* reason = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_REASON];
                NSDictionary* crowd = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_CROWD_INFO];
                NSString* session_id = [JSONObjectHelper getStringFromJSONObject:crowd forKey:KEY_SESSION_ID];
                callback(YES, session_id, reason);
            }else{
                callback(NO, @"", @"");
            }
        }];
    }else if(icon){
        [[OtherManager shareInstance] doUploadImage:icon crop_left:0 crop_right:0 crop_top:0 crop_bottom:0 callback:^(BOOL isSuccess, NSString *uri, NSString *reason, NSString *localImg) {
            if (isSuccess) {
                [[BizlayerProxy shareInstance] createCrowd:name icon:uri category:category auth:auth_type callback:^(NSDictionary *data) {
                    ResultInfo* result = [super parseCommandResusltInfo:data];
                    if (result.succeed) {
                        NSString* reason = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_REASON];
                        NSDictionary* crowd = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_CROWD_INFO];
                        NSString* session_id = [JSONObjectHelper getStringFromJSONObject:crowd forKey:KEY_SESSION_ID];
                        callback(YES, session_id, reason);
                    }else{
                        callback(NO, @"", @"");
                    }
                }];
            }
        }];
    }
}

- (void) dismissCrowd:(NSString *)sessionID callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] dismissCrowd:sessionID callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) inviteIntoCrowd:(NSString *)sessionID friend:(NSString *)jid callback:(void (^)(BOOL isSuccess))callback
{
    [[BizlayerProxy shareInstance] inviteIntoCrowd:sessionID friend:jid callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) applyJoinCrowd:(NSString *)sessionID reason:(NSString *)reason callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] applyJoinCrowd:sessionID reason:reason callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) crowdApplySuperadmin:(NSString *)sessionID reason:(NSString *)reason callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] crowdApplySuperadmin:sessionID reason:reason callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) crowdMemberKickout:(NSString *)session_id friend:(NSString *)kickJid reson:(NSString *)reason callback:(void(^)(BOOL isSuceess)) callback;
{
    [[BizlayerProxy shareInstance] crowdMemberKickout:session_id withJID:kickJid wihtReson:reason ? reason : @"" withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) crowdRoleDemise:(NSString *)sessionID friend:(NSString *)jid callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] crowdRoleDemise:sessionID friend:jid callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) crowdRoleChangeAdmin:(NSString *)sessionID friend:(NSString *)jid callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] crowdRoleChange:sessionID friend:jid role:KEY_ADMIN callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) crowdRoleChangeNone:(NSString *)sessionID friend:(NSString *)jid callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] crowdRoleChange:sessionID friend:jid role:KEY_NONE callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (BOOL) isCrowdBeDismissOrFrozen:(NSString *)crowd_jid
{
    if (!crowdList_) {
        return YES;
    }
    for (CrowdInfo* info in crowdList_) {
        if ([info.session_id isEqualToString:crowd_jid]) {
            return [info isFrozen];
        }
    }
    return YES;
}

- (void) reset
{
    [super reset];
    [self runInThread:^{
        [crowdList_ removeAllObjects];
        isGetCrowdSuccess_ = NO;
    }];
}



- (void) getCrowdListWithCallback:(void(^)(NSMutableArray*)) callback
{
    if (crowdList_) {
        callback(crowdList_);
        return;
    }
    
    WhistleCommandCallbackType callback_ = ^(NSDictionary* data){
        [self runInThread:^{
            LOG_NETWORK_INFO(@"crowd list info: %@", data);
            ResultInfo *resultInfo = [self parseCommandResusltInfo:data];
            if (resultInfo.succeed) {
                NSDictionary* dic = [JSONObjectHelper getJSONFromJSON:data forKey:@"crowd_list"];
                LOG_NETWORK_INFO(@"得到群列表成功，群列表信息：%@", dic);
                crowdList_= [JSONObjectHelper getObjectArrayFromJsonObject:dic forKey:@"crowd_list" withClass:[CrowdInfo class]];
                if ([self isNull:crowdList_]) {
                    crowdList_ = [[NSMutableArray alloc] init];
                }
                callback(crowdList_);
            } else {
                crowdList_ = nil;
                callback(nil);
                LOG_NETWORK_ERROR(@"得到群列表失败, 失败信息：%@", data);
            }
        }];
    };
    [[BizlayerProxy shareInstance] getCrowdList:callback_];
}

- (CrowdInfo*) getCrowdInfoBySessionID: (NSString* ) session_id
{
    CrowdInfo* ret = nil;
    for (CrowdInfo* c in crowdList_) {
        if ([session_id isEqualToString: c.session_id]) {
            ret = c;
            return ret;
        }
    }
    return ret;
}

- (void) getCrowdDetailInfoBySessionID: (NSString*) session_id WithCallback: (void(^)(CrowdInfo*)) callback
{
    [self runInThread:^{
        [[BizlayerProxy shareInstance] getCrowdInfo: session_id withListener:^(NSDictionary* data){
            [self runInThread:^{
                LOG_NETWORK_INFO(@"通过session_id:%@得到群信息:%@", session_id, data);
                NSDictionary* info = [JSONObjectHelper getJSONFromJSON:data forKey:@"info"];
                CrowdInfo* ci = [JSONObjectHelper getObjectFromJSON:info withClass:[CrowdInfo class]];
                callback(ci);
            }];
        }];
    }];
}
//对群列表数据进行排序，将冻结的群放在后面，非冻结群放前面
- (void) sortCrowdList
{
    if ([self isNull:crowdList_]) {
        return;
    }
    NSArray* tmp = [crowdList_ sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CrowdInfo* c1 = obj1;
        CrowdInfo* c2 = obj2;
        if (!c1 || !c2) {
            return NSOrderedSame;
        }
        if ([c1 isFrozen] == [c2 isFrozen]) {
            return NSOrderedSame;
        }
        return [c1 isFrozen] ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    [crowdList_ removeAllObjects];
    [crowdList_ addObjectsFromArray:tmp];
    tmp = nil;
}


- (void) onCrowd_info_changed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群资料更新事件：%@", data);
        CrowdInfo* ci = [JSONObjectHelper getObjectFromJSON:data withClass:[CrowdInfo class]];
        CrowdInfo* current = nil;
        for (CrowdInfo* c in crowdList_) {
            if ([c.session_id isEqualToString:ci.session_id]) {
                current = c;
                break;
            }
        }
        if (current) {
            [current getUnionSetByCrowdInfo:ci];
            if ([current isFrozen]) {
                [self sendCrowdBeFrozenDelegate:ci];
            }
        }
        
        [self sortCrowdList];
        [self sendCrowdChangeDelegate];

    }];
}

- (void) onCrowd_list_changed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群列表更新事件:%@", data);
        NSString* type = [JSONObjectHelper getStringFromJSONObject:data forKey:@"type"];
        if ([CROWD_LIST_CHANGED_ADD isEqualToString:type]) {
            //add
            NSString* sessionID =  [JSONObjectHelper getStringFromJSONObject: [JSONObjectHelper getJSONFromJSON:data forKey:@"crowd_info"] forKey:@"session_id"];
            [self getCrowdDetailInfoBySessionID:sessionID WithCallback:^(CrowdInfo* ci){
                [crowdList_ addObject:ci];
                [self sortCrowdList];
                [self sendCrowdChangeDelegate];
            }];
            
        } else if([CROWD_LIST_CHANGED_REMOVE isEqualToString:type]) {
            //remove
            NSString* session_id = [[JSONObjectHelper getJSONFromJSON:data forKey:@"crowd_info"] objectForKey:@"session_id"];
            if (session_id) {
                CrowdInfo* info = nil;
                for (CrowdInfo *c in crowdList_) {
                    if ([c.session_id isEqualToString:session_id]) {
                        info = c;
                        break;
                    }
                }
                if (info) {
                    [crowdList_ removeObject:info];
                    [self sendCrowdBeDismissDelegate:info];
                }
            }
            [self sendCrowdChangeDelegate];
        }

    }];
}

- (BOOL) isExistInCrowdList:(NSString *)jid
{
    for (CrowdInfo* info in crowdList_) {
        if ([info.session_id isEqualToString:jid]) {
            return YES;
        }
    }
    return NO;
}

- (CrowdInfo*) getCrowdInfo:(NSString *)jid
{
    for (CrowdInfo* cinfo in crowdList_) {
        if ([cinfo.session_id isEqualToString:jid]) {
            return cinfo;
        }
    }
    return nil;
}

- (void) onCrowd_member_changed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群成员列表更新事件:%@", data);
        NSDictionary* memberInfo = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_MEMBER_INFO];
        NSString* sessionID = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SESSION_ID];
        NSString* type = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_TYPE];
        if ([KEY_ADD isEqualToString:type]) {
            //添加新成员
            CrowdMember* member = [JSONObjectHelper getObjectFromJSON:memberInfo withClass:[CrowdMember class]];
            CrowdInfo* cinfo = [self getCrowdInfo:sessionID];
            if (cinfo) {
                [cinfo.members addObject:member];
            }
        }else if ([KEY_REMOVE isEqualToString:type]){
            //删除成员
            CrowdMember* member = [JSONObjectHelper getObjectFromJSON:memberInfo withClass:[CrowdMember class]];
            CrowdInfo* cinfo = [self getCrowdInfo:sessionID];
            if (cinfo) {
                [cinfo removeCrowdMemberByJID:member.jid];
            }
        }else if ([KEY_MODIFY isEqualToString:type]){
            //只更新角色
            CrowdMember* member = [JSONObjectHelper getObjectFromJSON:memberInfo withClass:[CrowdMember class]];
            CrowdInfo* cinfo = [self getCrowdInfo:sessionID];
            CrowdMember* preMember = [cinfo getCrowdMember:member.jid];
            preMember.status = member.status;
        }else if ([KEY_REFRESH isEqualToString:type]){
            //重新获取成员列表，暂时不处理
        }
        
    }];
}

- (void) onCrowd_alert_changed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群提醒更新事件：%@", data);
        NSString* session_id = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SESSION_ID];
        NSUInteger alert = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_ALERT defaultValue:0];
        CrowdInfo* info = [self getCrowdInfoBySessionID: session_id];
        if (info) {
            info.alert = alert;
            [self sendCrowdChangeDelegate];
        }
    }];
}

- (void) onCrowd_system_message_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群系统消息事件:%@", data);
        NSString* session_id = [JSONObjectHelper getStringFromJSONObject:data forKey:@"session_id"];
        NSString* type = [JSONObjectHelper getStringFromJSONObject:data forKey:@"msg_type"];
        CrowdInfo* ci = [self getCrowdInfoBySessionID:session_id];
        if (ci && ([@"crowd_dismiss_success" isEqualToString:type] || [@"crowd_quit_self" isEqualToString:type])) {
            [crowdList_ removeObject:ci];
        //通知界面
            [self sendCrowdChangeDelegate];
            [self sendCrowdBeDismissDelegate:ci];
        }
    }];
}

- (UIImage*) getCrowdIcon:(NSString *)jid
{
    for (CrowdInfo* info in crowdList_) {
        if ([info.session_id isEqualToString:jid]) {
            return [info getCrowdIcon];
        }
    }
    return nil;
}

/**
 *  修改群资料，不需要修改的字段设置为nil，category设置为-1
 *
 *  @param session_id  群sessionid，必填
 *  @param name        群名
 *  @param annouce
 *  @param description
 *  @param icon
 *  @param category    不需要修改时，传-1
 */
- (void) setCrowdInfo:(NSString *)session_id name:(NSString *)name annouce:(NSString *)annouce description:(NSString *)description icon:(NSString *)icon category:(NSInteger)category callback:(void (^)(BOOL))callback
{
    NSMutableDictionary* dic_ = [[NSMutableDictionary alloc] init];
    if (name) {
        [dic_ setValue:name forKey:KEY_NAME];
    }
    if (annouce) {
        [dic_ setValue:annouce forKey:KEY_ANNOUNCE];
    }
    if (description) {
        [dic_ setValue:description forKey:KEY_DESCRIPTION];
    }
    if (icon) {
        [dic_ setValue:icon forKey:KEY_ICON];
    }
    if (category > 0) {
        [dic_ setValue:[NSNumber numberWithInt:category] forKey:KEY_CATEGORY];
    }
    [[BizlayerProxy shareInstance] setCrowdInfo:session_id wihtParams:dic_ withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) setCrowdName:(NSString *)session_id name:(NSString *)name callback:(void (^)(BOOL))callback
{
    [self setCrowdInfo:session_id name:name annouce:nil description:nil icon:nil category:-1 callback:callback];
}

- (void) setCrowdAnnounce:(NSString *)session_id announce:(NSString *)announce callback:(void (^)(BOOL))callback
{
    [self setCrowdInfo:session_id name:nil annouce:announce description:nil icon:nil category:-1 callback:^(BOOL isSucess) {
        if (isSucess) {
            [[BizlayerProxy shareInstance] sendMessage:session_id withMsg:[NSString stringWithFormat:@"更新了群公告：\n%@",announce] withListener:^(NSDictionary *data){
            }];
        }
        callback(isSucess);
    }];
}

- (void) setCrowdDescription:(NSString *)session_id description:(NSString *)description callback:(void (^)(BOOL))callback
{
    [self setCrowdInfo:session_id name:nil annouce:nil description:description icon:nil category:-1 callback:callback];
}

- (void) setCrowdIcon:(NSString *)session_id icon:(NSString *)icon callback:(void (^)(BOOL))callback
{
    if (icon) {
        [[OtherManager shareInstance] doUploadImage:icon crop_left:0 crop_right:0 crop_top:0 crop_bottom:0 callback:^(BOOL isSuccess, NSString *uri, NSString *reason, NSString *localImg) {
            if (isSuccess) {
                [self setCrowdInfo:session_id name:nil annouce:nil description:nil icon:uri category:-1 callback:callback];
            }else{
                callback(YES);
            }
        }];
    }else{
        callback(NO);
    }
}

- (void) setCrowdCatagory:(NSString *)session_id category:(NSUInteger)category callback:(void (^)(BOOL))callback
{
    [self setCrowdInfo:session_id name:nil annouce:nil description:nil icon:nil category:category callback:callback];
}

- (void) setCrowdAnthType:(NSString *)session_id auth:(NSUInteger)auth_type callback:(void (^)(BOOL))callback
{
    callback(NO);
}

- (void) setCrowdRemark:(NSString *)session_id remark:(NSString *)remark callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] setCrowdMemberInfo:session_id friend:nil name:nil remark:remark callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) onRecv_quit_crowd_ack_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"退出群系统消息事件:%@", data);
    }];
}

- (void) onCrowd_superadmin_applyed_response_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"已审批群超级管理员申请的通知消息事件:%@", data);
    }];
}

- (void) onCrowd_superadmin_applyed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群超级管理员被申请的通知消息事件:%@", data);
    }];
}

- (void) onUpdate_member_head_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群成员头像通知消息事件:%@", data);
        NSString* jid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_JID];
        NSString* head = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_HEAD];
        [headDic_ setObject:head forKey:jid];
        CrowdInfo* ch = nil;
        for (CrowdInfo* info in crowdList_) {
            if ([info changeHead:jid head:head]) {
                ch = info;
                break;
            }
        }
        if (ch) {
            [self sendCrowdMemberChangedDelegate:ch];
        }

    }];
}

- (void) onCrowd_file_changed_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群共享文件更新消息事件:%@", data);
    }];
}

- (void) onFile_transfer_status_impl: (NSDictionary* ) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"群文件传输进度通知事件:%@", data);
    }];
}

- (void) updateHead:(NSArray*) members
{
    for (CrowdMember* m in members) {
        NSString* head = [headDic_ objectForKey:m.jid];
        if (head) {
            m.head = head;
        }
    }
}

- (void) getCrowdMembers:(NSString *)sessionID callback:(void (^)(NSArray *))callback
{
    CrowdInfo* crowd = [self getCrowdInfo:sessionID];
    if (crowd) {
        if (crowd.members && [crowd.members count] > 0) {
            [self updateHead:crowd.members];
            callback(crowd.members);
        }else{
            [[BizlayerProxy shareInstance] getCrowdMemberList:sessionID withListener:^(NSDictionary *data) {
                ResultInfo* result = [super parseCommandResusltInfo:data];
                if (result.succeed) {
                    NSMutableArray* members = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_MEMBER_LIST withClass:[CrowdMember class]];
                    [self updateHead:crowd.members];
                    crowd.members = members;
                    callback(members);
                }else{
                    crowd.members = nil;
                    callback(nil);
                }
            }];
        }
    }else{
        callback(nil);
    }
}

- (void) getCreateCrowdSetting:(void (^)(BOOL, BOOL, NSUInteger, NSString *))callback
{
    [[BizlayerProxy shareInstance] getCreateCrowdSetting:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            //createEnable备用
//            NSString* createEnable = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_CREATE_ENABLE];
            NSString* canCreate = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_CAN_CREATE];
            NSString* reason = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_REASON];
            NSUInteger number = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_MAX_MEMBER defaultValue:0];
            callback(YES, [KEY_TRUE isEqualToString:canCreate], number, reason);
        }else{
            callback(NO, NO, 0, @"");
        }
    }];
}

- (void) setCrowdMemberName:(NSString *)session_id member:(NSString *)jid name:(NSString *)name callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] setCrowdMemberInfo:session_id friend:jid name:name remark:@"" callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) leaveCrowd:(NSString *)session_id callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] leaveCrowd:session_id withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) setCrowdAlert_Recv:(NSString *)session callback:(void (^)(BOOL))callback
{
    if (!session) {
        callback(NO);
        return;
    }
    [[BizlayerProxy shareInstance] setCrowdAlert:session alert:0 callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) setCrowdAlert_Recv_NO_Tint:(NSString *)session callback:(void (^)(BOOL))callback
{
    if (!session) {
        callback(NO);
        return;
    }
    [[BizlayerProxy shareInstance] setCrowdAlert:session alert:1 callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) setCrowdAlert_Reject:(NSString *)session callback:(void (^)(BOOL))callback
{
    if (!session) {
        callback(NO);
        return;
    }
    [[BizlayerProxy shareInstance] setCrowdAlert:session alert:2 callback:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) findCrowd:(NSString *)type text:(NSString *)text index:(int)index count:(int)count callback:(void (^)(NSArray *))callback
{
    [[BizlayerProxy shareInstance] findCrowd:type withSearchStr:text wihtIndex:index withMax:count withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            NSArray* list = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_CROWD_LIST withClass:[CrowdInfo class]];
            if ([super isNull:list]) {
                callback([NSArray array]);
            }else{
                callback(list);
            }
        }else{
            callback(nil);
        }
    }];
}

- (void) getCrowdPolicy:(void (^)(NSString *))callback
{
    static NSString* content = nil;
    if (content) {
        callback(content);
        return;
    }
    NSString* url = [[BizlayerProxy shareInstance] getCrowdPolicy];
    [super http_get_raw:url succuess:^(NSData *data) {
        NSString* ret_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary* json = [JSONObjectHelper decodeJSON:ret_str];
        content = [JSONObjectHelper getStringFromJSONObject:json forKey:KEY_CONTENT];
        callback(content);
    } noData:^{
        callback(nil);
    } error:^{
        callback(nil);
    }];
}

- (void) sendCrowdChangeDelegate
{
    LOG_NETWORK_DEBUG(@"群列表变更信息：%@", [super toArrayString:crowdList_]);
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(crowdListChanged:)]) {
            [d crowdListChanged:crowdList_];
        }

    }
}

- (void) sendCrowdListFinishDelegate
{
    LOG_NETWORK_DEBUG(@"得到群列表成功的信息：%@", [super toArrayString:crowdList_]);
    isGetCrowdSuccess_ = YES;
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(getCrowdListFinish:)]) {
            [d getCrowdListFinish: crowdList_];
        }

    }
}
- (void) sendCrowdListFailureDelegate
{
    LOG_NETWORK_ERROR(@"得到群列表信息失败");
    isGetCrowdSuccess_ = NO;
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(getCrowdListFailure)]) {
            [d getCrowdListFailure];
        }

    }
}

- (void) sendCrowdMemberListFinishDelegate
{
    LOG_NETWORK_DEBUG(@"得到群成员信息成功：%@", [super toArrayString:crowdList_]);
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(getCrowdMemberFinish:)]) {
            [d getCrowdMemberFinish:crowdList_];
        }
    }
}

- (void) sendCrowdMemberListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"得到群成员信息成功：%@", [super toArrayString:crowdList_]);
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(getCrowdMemberChanged:)]) {
            [d getCrowdMemberChanged:crowdList_];
        }
    }
}

- (void) sendCrowdMemberListFailureDelegate
{
    LOG_NETWORK_ERROR(@"得到群成员信息失败");
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(getCrowdMemberFailure)]) {
            [d getCrowdMemberFailure];
        }
    }
}

- (void) sendCrowdBeFrozenDelegate:(CrowdInfo*) info
{
    LOG_NETWORK_DEBUG(@"群被冻结的信息：%@", [info toString]);
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(crowdBeFrozen:)]) {
            [d crowdBeFrozen:info];
        }
    }
}
- (void) sendCrowdBeDismissDelegate:(CrowdInfo*) info
{
    LOG_NETWORK_DEBUG(@"群被解散或者被踢出该群的信息：%@", [info toString]);
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(crowdBeDismiss:)]) {
            [d crowdBeDismiss:info];
        }
    }
}

- (void) sendCrowdMemberChangedDelegate:(CrowdInfo*) info
{
    for (id<CrowdDelegate> d in [self getListenerSet:@protocol(CrowdDelegate)]) {
        if ([d respondsToSelector:@selector(crowdMemberChanged:)]) {
            [d crowdMemberChanged:info];
        }
    }
}

#pragma  mark getGrowdVote
//给选择的项投票
- (void) startVote:(NSString *)jid voteId:(int)vid iids:(NSString *)iids name:(NSString *)name callback:(void(^)(CrowdVoteInfo *))callback
{
    NSString *url = [NSString stringWithFormat:@"%@index.php?module=vote&action=poll",[[BizlayerProxy shareInstance] getCrowdVoteURL]];
    NSString *body = [NSString stringWithFormat:@"jid=%@&vid=%d&%@&name=%@",[[RosterManager shareInstance] mySelf].jid,vid,iids,[[RosterManager shareInstance] mySelf].name];
    
    [self http_post_raw:url body:body succuess:^(NSData *data) {
        NSString *ret_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *ret = [JSONObjectHelper decodeJSON:ret_str];
        NSDictionary *dic = [ret objectForKey:CROWD_VOTE_KEY];
        CrowdVoteInfo *info = [JSONObjectHelper getObjectFromJSON:dic withClass:[CrowdVoteInfo class]];
        callback(info);
    } noData:^{
        callback(nil);
    } error:^{
        callback(nil);
    }];

}
//群投票列表
- (void) voteList:(NSString *)gid callback:(void(^)(NSArray *))callback
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
//    [params setObject:gid forKey:@"gid"];
    NSString *url = [NSString stringWithFormat:@"%@index.php?module=vote&action=list",[[BizlayerProxy shareInstance] getCrowdVoteURL]];
    NSString *body = [NSString stringWithFormat:@"gid=%@",gid];
//    NSString *urlStr = [NSString stringWithFormat:@"http://whistle.ruijie.com.cn:1093/vote/index.php?module=vote&action=list"];
//    NSString *bodyStr = [JSONObjectHelper encodeStringFromJSON:params];
    [self http_post_raw:url body:body succuess:^(NSData *data) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *ret = [JSONObjectHelper decodeJSON:dataStr];
        
        NSArray *array = [JSONObjectHelper getObjectArrayFromJsonObject:ret forKey:CROWD_VOTE_KEY withClass:[CrowdVoteInfo class]];
        if ([super isNull:array]) {
            callback(nil);
        }else{
            callback(array);
        }
    } noData:^{
        callback(nil);
    } error:^{
        callback(nil);
    }];
    
}
//群投票详细信息
- (void)voteDetail:(NSString *)gid voteId:(int)vid jid:(NSString *)jid callback:(void(^)(CrowdVoteInfo *))callback
{
    NSString *urlStr = [NSString stringWithFormat:@"%@index.php?module=vote&action=detail",[[BizlayerProxy shareInstance] getCrowdVoteURL]];
    NSString *bodyStr = [NSString stringWithFormat:@"gid=%@&vid=%i&jid=%@",gid,vid,[[RosterManager shareInstance] mySelf].jid];//[JSONObjectHelper encodeStringFromJSON:params];
    [self http_post_raw:urlStr body:bodyStr succuess:^(NSData *data) {
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *ret = [JSONObjectHelper decodeJSON:dataStr];
        NSDictionary *dic = [ret objectForKey:CROWD_VOTE_KEY];
        //传完整信息
        CrowdVoteInfo *info = [JSONObjectHelper getObjectFromJSON:dic withClass:[CrowdVoteInfo class]];
        [[RosterManager shareInstance] getFriendInfoByJid:info.jid checkStrange:YES WithCallback:^(FriendInfo *f) {
            info.extraInfo = f;
            callback(info);
        }];

    } noData:^{
        callback(nil);
    } error:^{
        callback(nil);
    }];
    
}
//删除投票
- (void)deleteVote:(NSString *)gid vid:(int)vid jid:(NSString *)jid
{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
//    [params setObject:gid forKey:@"gid"];
//    [params setObject:[NSString stringWithFormat:@"%d",vid] forKey:@"vid"];
//    [params setObject:jid forKey:@"jid"];
    NSString *url = [NSString stringWithFormat:@"%@index.php?module=vote&action=delete",[[BizlayerProxy shareInstance] getCrowdVoteURL]];
    NSString *body = [NSString stringWithFormat:@"gid=%@&vid=%d&jid%@",gid,vid,jid];
    [self http_post_raw:url body:body succuess:^(NSData *data) {
        return;
    } noData:^{
        ;
    } error:^{
        ;
    }];
}
@end










