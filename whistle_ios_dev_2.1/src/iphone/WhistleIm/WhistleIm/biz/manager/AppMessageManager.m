//
//  AppMessageManager.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AppMessageManager.h"
#import "ResultInfo.h"
#import "JSONObjectHelper.h"
#import "RecentAppMessageInfo.h"
#import "ServiceInfo.h"
#import "BizBridge.h"
#import "BizlayerProxy.h"


@interface AppMessageManager()
{
    NSMutableArray *appMessageList_;
    BOOL getListSuccess_;
}


@property (nonatomic, strong) WhistleNotificationListenerType onRecvAppNotification;

@end

@implementation AppMessageManager

SINGLETON_IMPLEMENT(AppMessageManager)

-(id)init
{
    self = [super init];
    if(self){
        self.onRecvAppNotification = nil;
        appMessageList_ = [[NSMutableArray alloc] init];
        getListSuccess_ = NO;
    }
    
    return self;
}

- (void) register4Biz
{
    [super register4Biz];
    __weak AppMessageManager* _self = self;
    
    LOG_NETWORK_DEBUG(@"向biz层注册listener");
    
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        LOG_NETWORK_DEBUG(@"得到应用提醒的原始数据：%@", result);
        [_self onGetRecentAppMsgImpl:result];
    };
    [[BizlayerProxy shareInstance] getAppMsgList:-1 count:10 callback:listener];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.onRecvAppNotification = ^(NSDictionary *data){
            LOG_NETWORK_DEBUG(@"得到应用提醒的更新原始数据：%@", data);
            [_self onRecvAppNotificationImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:self.onRecvAppNotification withType:NOTIFY_recv_app_message];
        
        
        WhistleNotificationListenerType onUpdateAppIconNotification = ^(NSDictionary *data){
            LOG_NETWORK_DEBUG(@"得到应用提醒图标的原始数据：%@", data);
            [_self onUpdateAppIconNotificationImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onUpdateAppIconNotification withType:NOTIFY_update_app_icon];

    });
    
}

- (BOOL) isExistAppMsg:(RecentAppMessageInfo*) app
{
    for (RecentAppMessageInfo* tmp in appMessageList_) {
        if ([tmp.msgid isEqualToString:app.msgid]) {
            return YES;
        }
    }
    return NO;
}
- (void) onGetRecentAppMsgImpl:(NSDictionary*) data
{
    [self runInThread:^{
        @autoreleasepool {
            ResultInfo *resultInfo =[self parseCommandResusltInfo: data];
            if(resultInfo.succeed){
                getListSuccess_ = YES;
                id msgs = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"msgs" withClass:[RecentAppMessageInfo class]];
                if(![self isNull:msgs] && [msgs isKindOfClass:[NSArray class]]){
                    //过滤重复
                    for (RecentAppMessageInfo* tmp in msgs) {
                        if ([self isExistAppMsg:tmp]) {
                            
                        }else{
                            [appMessageList_ addObject:tmp];
                        }
                    }
                }
                [self sendGetAppMsgFinishDelegate];
                [self sendUpdateUnReadCountDelegate];
            }else{
                getListSuccess_ = NO;
                [self sendGetAppMsgFailureDelegate];
            }
        }
    }];
}

- (void) onRecvAppNotificationImpl:(NSDictionary*) data
{
    [self runInThread:^{
        RecentAppMessageInfo *notice = [JSONObjectHelper getObjectFromJSON:data
                                                                 withClass:[RecentAppMessageInfo class]];
        [appMessageList_ insertObject:notice atIndex:0];
        [self sendAppMsgListChangedDelegate];
        [self sendRecvAppMsgUpdateDelegate:notice];
        [self sendUpdateUnReadCountDelegate];
    }];
}

- (void) onUpdateAppIconNotificationImpl:(NSDictionary*) data
{
    [self runInThread:^{
        NSString* app_id = [data objectForKey:@"id"];
        NSString* icon = [data objectForKey:@"icon"];
        RecentAppMessageInfo* notice = nil;
        for (RecentAppMessageInfo* rami in appMessageList_) {
            if ([rami.serviceInfo.id isEqualToString:app_id]) {
                rami.serviceInfo.icon = icon;
                notice = rami;
                break;
            }
        }
        [self sendAppMsgListChangedDelegate];
    }];
}


-(RecentAppMessageInfo *)getRecentAppMessageInfo:(NSString *)serviceId
{
    for (RecentAppMessageInfo *appMsg in appMessageList_) {
        if ([appMsg.serviceInfo.id isEqualToString:serviceId]) {
            return appMsg;
        }
    }
    
    return nil;
}

- (void) getAppMsgHistory:(RecentAppMessageInfo *)appmsg withCallback:(void(^)(NSArray*))callback
{
    [self getAppMsgHistoryBySID:appmsg.serviceInfo.id withCallback:callback];
}

- (void) getAppMsgHistory:(RecentAppMessageInfo *)appmsg withIndex:(NSInteger)index withCount:(NSUInteger)count withCallback:(void (^)(NSArray *))callback
{
    [self getAppMsgHistoryBySID:appmsg.serviceInfo.id withIndex:index withCount:count withCallback:callback];
}

- (void) getAppList
{
    if (getListSuccess_) {
        [self sendGetAppMsgFinishDelegate];
        return;
    }
    __weak AppMessageManager* _self = self;
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [_self onGetRecentAppMsgImpl:result];
    };
    [[BizlayerProxy shareInstance] getAppMsgList:-1 count:10 callback:listener];
}

- (void) getAppList:(NSInteger)index count:(NSInteger)count
{
    [[BizlayerProxy shareInstance] getAppMsgList:index count:count callback:^(NSDictionary *data) {
        [self runInThread:^{
            [self onGetRecentAppMsgImpl:data];
        }];
    }];
}

- (void) getAppMsgHistoryBySID:(NSString *)serviceID withCallback:(void(^)(NSArray*))callback
{
    [self getAppMsgHistoryBySID:serviceID withIndex:-1 withCount:20 withCallback:callback];
}

- (void) getAppMsgHistoryBySID:(NSString *)serviceID withIndex:(NSInteger)index withCount:(NSUInteger)count withCallback:(void (^)(NSArray *))callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"得到应用提醒的原始数据：%@", result);
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                id msgs = [JSONObjectHelper getObjectArrayFromJsonObject:result
                                                                  forKey:@"msgs"
                                                               withClass:[AppMsgInfo class]];
                LOG_NETWORK_DEBUG(@"得到应用提醒的数据成功：%@", [super toArrayString:msgs]);
                if ([self isNull:msgs]) {
                    callback(nil);
                }else{
                    callback(msgs);
                }
                
            }else{
                LOG_NETWORK_DEBUG(@"得到应用提醒的数据失败");
                callback(nil);
            }
        }];
    };
    [[BizlayerProxy shareInstance] getAppMsgHistory:serviceID from:index withCount:count withListener:listener];
}
- (void) deleteRecentAppMessage:(RecentAppMessageInfo *)msg withCallback:(void(^)(BOOL)) callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                LOG_NETWORK_DEBUG(@"删除应用提醒成功：%@", [msg toString]);
                [appMessageList_ removeObject:msg];
                [self sendAppMsgListChangedDelegate];
                [self sendUpdateUnReadCountDelegate];
                callback(YES);
            }else{
                LOG_NETWORK_ERROR(@"删除应用提醒失败：%@", [msg toString]);
                callback(NO);
            }
        }];
    };
    
    [[BizlayerProxy shareInstance] deleteAppMessage:msg.serviceInfo.id withListener:listener];
}

- (void) deleteAllAppMessage:(void (^)(BOOL))callback
{
   [[BizlayerProxy shareInstance] deleteAllAppMsg:^(NSDictionary *data) {
       ResultInfo* result = [super parseCommandResusltInfo:data];
       if (result.succeed) {
           callback(YES);
       }else{
          callback(NO);
       }
   }];
}

- (void) deleteAllReadAppMessage:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteAllReadAppMsg:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

-(void)markRead:(RecentAppMessageInfo*) app WithCallback:(void(^)(BOOL)) callback
{
    [self runInThread:^{
        [app markReadWithCallback:^(BOOL is){
            LOG_NETWORK_DEBUG(@"设置应用提醒已读成功：%d 数据：%@", is, [app toString]);
            if (is) {
                [self sendAppMsgListChangedDelegate];
            }
            callback(is);
        }];
    }];

}

- (void) reset
{
    [super reset];
    LOG_NETWORK_DEBUG(@"通知通知manager类reset");
    [appMessageList_ removeAllObjects];
    getListSuccess_ = NO;
}


- (void) sendAppMsgListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"应用提醒消息变更：%@", [super toArrayString:appMessageList_]);
    for (id<AppMsgDelegate> d in [self getListenerSet:@protocol(AppMsgDelegate)]) {
        if ([d respondsToSelector:@selector(appMsgListChanged:)]) {
            [d appMsgListChanged:appMessageList_];
        }

    }
}

- (void) sendGetAppMsgFinishDelegate
{
    LOG_NETWORK_DEBUG(@"得到应用提醒成功：%@", [super toArrayString:appMessageList_]);
    for (id<AppMsgDelegate> d in [self getListenerSet:@protocol(AppMsgDelegate)]) {
        if ([d respondsToSelector:@selector(getAppMsgFinish:)]) {
            [d getAppMsgFinish:appMessageList_];
        }
    }
}

- (void) sendGetAppMsgFailureDelegate
{
    LOG_NETWORK_ERROR(@"得到应用提醒失败");
    for (id<AppMsgDelegate> d in [self getListenerSet:@protocol(AppMsgDelegate)]) {
        if ([d respondsToSelector:@selector(getAppMsgFailure)]) {
            [d getAppMsgFailure];
        }
    }
}

- (void) sendRecvAppMsgUpdateDelegate:(RecentAppMessageInfo*) msg
{
    LOG_NETWORK_DEBUG(@"接收应用提醒消息：%@", [msg toString]);
    for (id<AppMsgDelegate> d in [self getListenerSet:@protocol(AppMsgDelegate)]) {
        if ([d respondsToSelector:@selector(recvAppMsgUpdate:)]) {
            [d recvAppMsgUpdate:msg];
        }
    }
}

- (void) sendUpdateUnReadCountDelegate
{
    NSUInteger count = 0;
    for (RecentAppMessageInfo* info in appMessageList_) {
        count += info.unreadCount;
    }
    LOG_NETWORK_DEBUG(@"未读应用提醒数据：%d", count);
    for (id<AppMsgDelegate> d in [self getListenerSet:@protocol(AppMsgDelegate)]) {
        if ([d respondsToSelector:@selector(updateAppMsgUnReadCount:)]) {
            [d updateAppMsgUnReadCount:count];
        }
    }
}

@end
