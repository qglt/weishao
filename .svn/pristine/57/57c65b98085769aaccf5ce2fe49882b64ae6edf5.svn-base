//
//  RosterManager.m
//  Whistle
//
//  Created by wangchao on 13-3-5.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "RosterManager.h"
#import "JSONObjectHelper.h"
#import "FriendGroup.h"
#import "FriendInfo.h"
#import "Constants.h"
#import "LocalSearchData.h"

@interface RosterManager()
{
    BOOL getRosterSuccess_;
    Roster* currentRoster_;
    BOOL getMyDetailInfoSuccess_;
}

@property (nonatomic, strong) WhistleNotificationListenerType onItemUpdateNotification;

@end

@implementation RosterManager

SINGLETON_IMPLEMENT(RosterManager)

-(id)init
{
    self = [super init];
    if(self)
    {
        currentRoster_ = nil;
        getRosterSuccess_ = NO;
        getMyDetailInfoSuccess_ = NO;
    }
    return self;
}


-(void) reset {
    [super reset];
    [currentRoster_ clear];
    currentRoster_ = nil;
    getRosterSuccess_ = NO;
    getMyDetailInfoSuccess_ = NO;
}

-(void) refreshRoster {
    void(^listener)(NSDictionary*) = ^(NSDictionary *result){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"得到roster的原始数据：%@",result);
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                getRosterSuccess_ = YES;
                Roster *roster = (Roster *)[JSONObjectHelper getObjectFromJSON:result
                                                                     withClass:[Roster class]];
                
                currentRoster_ = roster;
                [self sendGetRosterFinishDelegate];
                [self getMyselfdDetailInfo];
            }else{
                currentRoster_ = nil;
                [self sendGetRosterFailureDelegate];
            }
        }];
    };
    [[BizlayerProxy shareInstance] getRoster:listener];
 }


- (void) register4Biz
{
    [super register4Biz];
    __weak RosterManager* _self = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        self.onItemUpdateNotification = ^(NSDictionary *data){
            LOG_NETWORK_DEBUG(@"好友信息更新的原始数据：%@", data);
            [_self onItemupdateNotificationImpl:data];
        };
        
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:self.onItemUpdateNotification
                                                                         withType:NOTIFY_recv_item_updated];
    });
    
    void(^listener)(NSDictionary*) = ^(NSDictionary *result){
        LOG_NETWORK_DEBUG(@"得到roster的原始数据：%@", result);
        [_self onGetRosterImpl:result];
    };
    [[BizlayerProxy shareInstance] getRoster:listener];
    
}

- (void) onItemupdateNotificationImpl:(NSDictionary*) data
{
    [self runInThread:^{

        NSString *operation = [data objectForKey:@"operation"];
        id changeData = [data objectForKey:@"changes"];
        NSString *jid = [changeData objectForKey:@"jid"];
        if(operation && [operation isEqualToString:@"Update"]
           && [changeData isKindOfClass: [NSDictionary class]])
        {
            if ([changeData objectForKey:KEY_presence]) {
                FriendInfo* friend = [currentRoster_ getFriendInfo:jid];
                friend.presence = [changeData objectForKey:KEY_presence];
                if ([currentRoster_.myInitInfo.jid isEqualToString:jid]) {
                    currentRoster_.myInitInfo = friend;
                    [self sendUpdateMyInfoDelegate];
                }else{
                    [self refrashOnlineCount:friend];
                    [self sendRosterListChangedDelegate];
                    [self sendUpdateFriendInfoDelegate:friend];
                }
            }else{
                [self getRoster:YES];
            }
        }else if (operation && [operation isEqualToString:@"Remove"]){
            LOG_GENERAL_INFO(@"好友信息删除数据:%@",data);
            [currentRoster_ removeFriend:[changeData objectForKey:KEY_JID]];
            [self sendRosterListChangedDelegate];
        }else if(operation && [operation isEqualToString:@"Add"]){
            LOG_GENERAL_INFO(@"好友信息添加数据:%@",data);
//            FriendInfo* f = [JSONObjectHelper getObjectFromJSON:changeData withClass:[FriendInfo class]];
//            [currentRoster_ addFriend:f];
//            [self refrashOnlineCount:f];
//            [self sendRosterListChangedDelegate];
//            [self sendUpdateFriendInfoDelegate:f];
            [self getRoster:YES];
        }
    }];
}

- (void) onGetRosterImpl:(NSDictionary*) data
{
    [self runInThread:^{
        @autoreleasepool {
            ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
            if(resultInfo.succeed){
                Roster *roster = (Roster *)[JSONObjectHelper getObjectFromJSON:data withClass:[Roster class]];
                currentRoster_ = roster;
                [self sendGetRosterFinishDelegate];
                [self getMyselfdDetailInfo];
            }else{
                currentRoster_ = nil;
                [self sendGetRosterFailureDelegate];
            }
        }
    }];
}



- (void) getStrangeByJid:(NSString*) jid WithCallback: (void(^)(FriendInfo*)) callback
{
    if (!jid) {
        callback(nil);
        return;
    }
    WhistleCommandCallbackType callback_ = ^(NSDictionary *result){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                id data = [result valueForKey:@"id_info"];
                FriendInfo *rosterItem = [[FriendInfo alloc] initFromJsonObject:data];
                callback(rosterItem);
            }else{
                callback(nil);
            }

        }];
    };
    
    [[BizlayerProxy shareInstance] getUserDetailInfo:jid callback:callback_];
}



-(void)removeBuddy:(FriendInfo *)rosterItem withCallback:(void (^)(BOOL))callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                [currentRoster_ removeFriend:rosterItem.jid];
                [self sendRosterListChangedDelegate];
                callback(YES);
            }else{
                callback(NO);
            }
        }];
    };
    
    [[BizlayerProxy shareInstance] removeBuddy:rosterItem.jid withRemoveMeFromHisList:YES withListener:listener];

}

- (void) getRelationShip:(NSString *)jid WithCallback:(void (^)(enum FriendRelation))callback
{
    [[BizlayerProxy shareInstance] getRelationship:jid withListener:^(NSDictionary* data){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
            if (resultInfo.succeed) {
                NSString* ret = [JSONObjectHelper getStringFromJSONObject:data forKey:@"relationship"];
                if ([@"Contact" isEqualToString:ret]) {
                    callback(RelationContact);
                }else if ([@"None" isEqualToString:ret]){
                    callback(RelationNone);
                }else if ([@"Stranger" isEqualToString:ret]){
                    callback(RelationStranger);
                }else{
                    callback(RelationError);
                }
                    
            }else{
                callback(RelationError);
            }
        }];
    }];
}

- (void) getFriendInfoByJid:(NSString *)jid checkStrange:(BOOL)flag WithCallback:(void (^)(FriendInfo *))callback
{
    [super runInThread:^{
        FriendInfo* info = [currentRoster_ getFriendInfo:jid];
        if (info) {
            callback(info);
        }else{
            [self getStrangeByJid:jid WithCallback:callback];
        }
    }];
}


- (void) getFriendInfoByJid:(NSString *)jid needRealtime:(BOOL)flag WithCallback:(void (^)(FriendInfo *))callback
{
    [super runInThread:^{
        FriendInfo* info = [currentRoster_ getFriendInfo:jid];
        if (info) {
            callback(info);
        }else{
            [self getStrangeByJid:jid WithCallback:callback];
        }
    }];
}

- (void) getMyself
{
    if (getMyDetailInfoSuccess_) {
        [self sendUpdateMyInfoDelegate];
    }else{
        [self getMyselfdDetailInfo];
    }
}

-(NSString *)getShownameByIdentity:(FriendInfo *)rosterInfo
{
    if(!rosterInfo){
        return NSLocalizedString(@"defaultName", nil);
    }
    if([rosterInfo.remarkName length] > 0){
        return rosterInfo.remarkName;
    }
    if([currentRoster_.myInitInfo isTeacher]){
        return rosterInfo.name;
    }else{
        
        if (!rosterInfo.nickName || [@"" isEqualToString:rosterInfo.nickName]) {
            return rosterInfo.showName;
        }else{
            return rosterInfo.nickName;
        }
    }
}

- (void) refrashOnlineCount:(FriendInfo* ) info
{
    if (info) {
        for (FriendGroup* f in currentRoster_.groupList) {
            if ([f isExist:info]) {
                [f refrashOnlineAndSort];
            }
            
        }
    }else{
        for (FriendGroup* f in currentRoster_.groupList) {
            [f refrashOnlineAndSort];
        }
    }
}

- (void) getRoster:(BOOL)isRefrash
{
    if (isRefrash) {
        [self refreshRoster];
    }else{
        if (getRosterSuccess_) {
            [self runInThread:^{
                [self sendGetRosterFinishDelegate];
            }];
        }else{
            [self refreshRoster];
        }
    }
}

- (void) addBuddy:(FriendInfo *)friend withMsg:(NSString *)msg withCallback:(void (^)(BOOL))callback
{
    [self addBuddyWithJid:friend.jid withMsg:msg withCallback:callback];
}

- (void) addBuddyWithJid:(NSString *)jid withMsg:(NSString *)msg withCallback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] addFriend:jid
                                    withName:@""
                                     withMsg:msg
                               withGroupName:NSLocalizedString(@"groupname_myfriend", nil)
                                withListener:^(NSDictionary* data){
                                    ResultInfo* result = [self parseCommandResusltInfo:data];
                                    if (result.succeed) {
                                        callback(YES);
                                    }else{
                                        callback(NO);
                                    }
                                }];
    //因为biz层没有callback，所有只能自己callback回去
    [self getRoster:YES];
    callback(YES);
}

- (void) ackFriendInvite:(NSString*) jid isAgree:(BOOL)isAgree withCallback:(void (^)(BOOL))callback
{
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    };
    [[BizlayerProxy shareInstance] ackAddFriend:jid withAck:isAgree withListener:listener];
}

- (void) setBuddyRemark:(FriendInfo*) friend withRemark:(NSString *)remark withListener:(void(^)(BOOL)) callback
{
    [[BizlayerProxy shareInstance] setBuddyRemark:friend.jid withRemark:remark withListener:^(NSDictionary *data) {
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

- (void) getMyselfdDetailInfo
{
    WhistleCommandCallbackType getUserDetailInfo = ^(NSDictionary *result) {
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if (resultInfo.succeed) {
                NSDictionary * idInfo = [result objectForKey:@"id_info"];
                FriendInfo * friendInfo = [JSONObjectHelper getObjectFromJSON:idInfo
                                                                    withClass:[FriendInfo class]];
                friendInfo.presence = currentRoster_.myInitInfo.presence;
                friendInfo.device_android = currentRoster_.myInitInfo.device_android;
                friendInfo.device_pc = currentRoster_.myInitInfo.device_pc;
                currentRoster_.myInitInfo = friendInfo;
                getMyDetailInfoSuccess_ = YES;
                [self getGrowthInfo:currentRoster_.myInitInfo.jid callback:^(BOOL isSuceess, NSString *version, NSUInteger level, NSUInteger exp, NSUInteger next_exp) {
                    if (isSuceess) {
                        currentRoster_.myInitInfo.level = level;
                        currentRoster_.myInitInfo.exp = exp;
                        currentRoster_.myInitInfo.next_exp = next_exp;
                    }
                    [self sendUpdateMyInfoDelegate];
                }];

            }else{
                LOG_GENERAL_ERROR(@"得到自己信息时失败");
            }

        }];
    };
    if (currentRoster_) {
        [[BizlayerProxy shareInstance] getUserDetailInfo:currentRoster_.myInitInfo.jid callback:getUserDetailInfo];
    }
}
//回调参数依次为得到数据是否成功、版本号、当前等级、当前等级的经验值、下一等级的经验值
- (void) getGrowthInfo:(NSString*) jid callback:(void(^)(BOOL isSuceess,NSString* version, NSUInteger level, NSUInteger exp, NSUInteger next_exp)) callback
{
    FriendInfo* info = [self mySelf];
    [super getToken:^(NSString *token) {
        NSString* url = [NSString stringWithFormat:@"%@jid=%@&student_number=%@&token=%@&platform=ios",
                         [[BizlayerProxy shareInstance] getGrowthInfoUrl], jid, info.student_number, token];
        [super http_get_raw:url succuess:^(NSData *data) {
            NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* tmp = [JSONObjectHelper decodeJSON:string];
            if (!tmp) {
                callback(NO,@"", 0, 0, 0);
            }else{
                if ([JSONObjectHelper getIntFromJSONObject:tmp forKey:KEY_RETCODE defaultValue:1] == 0) {
                    //数据返回成功
                    NSDictionary* d = [JSONObjectHelper getJSONFromJSON:tmp forKey:KEY_DATA];
                    NSString* version = [JSONObjectHelper getStringFromJSONObject:d forKey:KEY_VER];
                    NSUInteger level = [JSONObjectHelper getIntFromJSONObject:d forKey:KEY_LEVEL defaultValue:0];
                    NSUInteger exp = [JSONObjectHelper getIntFromJSONObject:d forKey:KEY_EXPERIENCE defaultValue:0];
                    NSUInteger next = [JSONObjectHelper getIntFromJSONObject:d forKey:KEY_NEXT_EXPERIENCE defaultValue:0];
                    callback(YES,version, level, exp, next);
                }else{
                    callback(NO,@"", 0, 0, 0);
                }
            }
        } noData:^{
            callback(NO,@"", 0, 0, 0);
        } error:^{
            callback(NO,@"", 0, 0, 0);
        }];
    }];
}

- (void) getUserDetailInfo:(NSString*) jid withCallback:(void(^)(FriendInfo*)) callback
{
    if ([currentRoster_.myInitInfo.jid isEqualToString:jid]) {
        callback(currentRoster_.myInitInfo);
    }else{
        WhistleCommandCallbackType getUserDetailInfo = ^(NSDictionary *result) {
            LOG_NETWORK_DEBUG(@"获取好友详细信息的原始数据：%@", result);
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if (resultInfo.succeed) {
                NSDictionary * idInfo = [result objectForKey:@"id_info"];
                FriendInfo * friendInfo = [JSONObjectHelper getObjectFromJSON:idInfo
                                                                    withClass:[FriendInfo class]];
                LOG_NETWORK_DEBUG(@"获取好友详细信息的数据：%@", [friendInfo toString]);
                if (friendInfo.level != 0 && friendInfo.exp != 0) {
                    callback(friendInfo);
                }else{
                    [self getGrowthInfo:jid callback:^(BOOL isSuceess, NSString *version, NSUInteger level, NSUInteger exp, NSUInteger next_exp) {
                        if (isSuceess) {
                            friendInfo.level = level;
                            friendInfo.exp = exp;
                            friendInfo.next_exp = next_exp;
                        }
                        callback(friendInfo);
                    }];
                }
            }else{
                callback(nil);
            }
        };
        
        [[BizlayerProxy shareInstance] getUserDetailInfo:jid callback:getUserDetailInfo];
    }
}

- (void) storeMyNickName:(NSString *)nick withCallback:(void (^)(BOOL))callback
{
    if (!nick) {
        callback(NO);
        return;
    }
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue: nick forKey:KEY_NICK_NAME];

    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    };
    [[BizlayerProxy shareInstance] storeMyInfo:data withListener:listener];
}

- (void) storeMyMoodWord:(NSString *)mood withCallback:(void (^)(BOOL))callback
{
    if (!mood) {
        callback(NO);
        return;
    }
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue: mood forKey:KEY_MOOD_WORDS];
    
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    };
    [[BizlayerProxy shareInstance] storeMyInfo:data withListener:listener];
}

- (void) storeMyPic:(NSString*) imagePath withCallback:(void(^)(BOOL)) callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *data){
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    };
    
    [[BizlayerProxy shareInstance] updateImage:imagePath withimgWidth:150 withimgHeight:150 withcropTop:0 withcropLeft:0 withcropBotton:150 withcropRight:150 withListener:listener];

}

- (NSString *)getSearchOptionsString:(OnlineSearchOptions) type
{
    switch (type) {
        case SearchByName:
            return @"name";
        case SearchByNickName:
            return @"nick_name";
        case SearchByWhistleId:
            return @"aid";
        default:
            return @"name";
    }
    return @"";
}
- (FriendInfo*) mySelf
{
    return currentRoster_.myInitInfo;
}
- (void) searchFriendsOnline:(OnlineSearchOptions)type searchText:(NSString *)text withIndex:(int)index withMax:(int)max withCallback:(void (^)(NSArray *))callback
{
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"在线搜索的原始数据：%@", data);
            ResultInfo *result =[self parseCommandResusltInfo:data];
            if(result.succeed){
                id temp = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey: KEY_FRIEND_LIST withClass:[FriendInfo class]];
                if([self isNull:temp]){
                    callback([[NSArray alloc] init]);
                }else{
                    LOG_NETWORK_DEBUG(@"在线搜索callback的数据：%@", [super toArrayString:temp]);
                    callback(temp);
                }
                
            }else{
                callback(nil);
            }

        }];
    };
    [[BizlayerProxy shareInstance] findFriendOnLine:[self getSearchOptionsString:type] withSearchStr:text wihtIndex:index withMax:max withListener:listener];
}

// 本地搜索，start--------------------------------------------//
#pragma mark -
#pragma mark - 本地好友搜索 start

- (void) getLocalSearchListWithSearchText:(NSString *)text withCallback:(void(^)(NSArray*)) callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"本地搜索的原始数据：%@", result);
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                id resultData = [result objectForKey:@"data"];
                if ([self isNull:resultData]) {
                    NSArray* tmp = [[NSArray alloc] init];
                    callback(tmp);
                }else{
                    LOG_NETWORK_DEBUG(@"本地搜索callback的数据：%@", [super toArrayString:resultData]);
                    callback(resultData);
                }
            } else{
                callback(nil);
            }
        }];
    };
    
    [[BizlayerProxy shareInstance] findContact:text withListener:listener];
}

// 本地搜索，end--------------------------------------------//


#pragma 发送delegate事件
- (void) sendRosterListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"好友信息变更的信息：%@", [super toArrayString:currentRoster_]);
    for (id<RosterDelegate> d in [self getListenerSet:@protocol(RosterDelegate)]) {
        if ([d respondsToSelector:@selector(rosterListChanged:)]) {
            [d rosterListChanged:currentRoster_.groupList];
        }

    }
}

- (void) sendGetRosterFinishDelegate
{
    LOG_NETWORK_DEBUG(@"得到好友信息成功：%@", [currentRoster_ toString]);
    getRosterSuccess_ = YES;
    for (id<RosterDelegate> d in [self getListenerSet:@protocol(RosterDelegate)]) {
        if ([d respondsToSelector:@selector(getRosterFinish:)]) {
            [d getRosterFinish: currentRoster_.groupList];
        }
    }
}

- (void) sendGetRosterFailureDelegate
{
    LOG_NETWORK_DEBUG(@"得到好友信息失败");
    getRosterSuccess_ = NO;
    for (id<RosterDelegate> d in [self getListenerSet:@protocol(RosterDelegate)]) {
        if ([d respondsToSelector:@selector(getRosterFailure)]) {
            [d getRosterFailure];
        }
    }
}

- (void) sendUpdateFriendInfoDelegate:(FriendInfo*) friend
{
    LOG_NETWORK_DEBUG(@"好友信息变更后的数据:%@",[friend toString]);
    for (id<RosterDelegate> d in [self getListenerSet:@protocol(RosterDelegate)]) {
        if ([d respondsToSelector:@selector(updateFriendInfo:)]) {
            [d updateFriendInfo:friend];
        }
    }
    if ([friend.jid isEqualToString:currentRoster_.myInitInfo.jid]) {
        [self sendUpdateMyInfoDelegate];
    }
}

- (void) sendUpdateMyInfoDelegate
{
    LOG_NETWORK_DEBUG(@"自己信息变更后的数据:%@", [currentRoster_.myInitInfo toString]);
    for (id<RosterDelegate> d in [self getListenerSet:@protocol(RosterDelegate)]) {
        if ([d respondsToSelector:@selector(updateMyInfo:)]) {
            [d updateMyInfo:currentRoster_.myInitInfo];
        }
    }
}

@end
