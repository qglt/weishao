//
//  NoticeManager.m
//  WhistleIm
//
//  Created by wangchao on 13-8-14.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticeManager.h"

#import "ChatRecordForNotice.h"
#import "JSONObjectHelper.h"
#import "BizlayerProxy.h"
#import "Constants.h"


@interface NoticeManager()
{
    NSMutableArray* noticeList_;
    BOOL getListSuccess_;
}

@property (nonatomic, strong) WhistleNotificationListenerType onRecvNoticeNotification;

@end


@implementation NoticeManager

SINGLETON_IMPLEMENT(NoticeManager)

-(id)init
{
   self = [super init];
    if(self){
        noticeList_ = [[NSMutableArray alloc] init];
        getListSuccess_ = NO;
    }
    
    return self;
}


- (void) register4Biz
{
    [super register4Biz];
    __weak NoticeManager* _self = self;

    LOG_NETWORK_DEBUG(@"向biz层注册事件");
    
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        LOG_NETWORK_DEBUG(@"得到通知列表的原始数据：%@", result);
        [_self getNoticeListImpl:result];
    };
    [[BizlayerProxy shareInstance] getNoticeList:-1 withCount:100 withListener:listener];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.onRecvNoticeNotification = ^(NSDictionary *data){
            LOG_NETWORK_DEBUG(@"接收通知更新的原始数据：%@",data);
            [_self onRecvNoticeNotificationImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:self.onRecvNoticeNotification withType:NOTIFY_recv_notice_message];
    });
    
}

- (void) onRecvNoticeNotificationImpl:(NSDictionary*) data
{
    NSString* jid = [data objectForKey:KEY_JID];
    NSLog(@"new jid %@", jid);
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            LOG_NETWORK_INFO(@"获取到通知的原始数据：%@", data);
            if(resultInfo.succeed){
                id notices = [JSONObjectHelper getObjectArrayFromJsonObject:result forKey:KEY_DATA withClass:[ChatRecordForNotice class]];
                if ([self isNull:notices]) {
                    LOG_NETWORK_ERROR(@"获取到错误的通知数据");
                }else{
                    LOG_NETWORK_INFO(@"获取到正确的通知数据");
                    [noticeList_ removeAllObjects];
                    [noticeList_ addObjectsFromArray:notices];
                    for (ChatRecordForNotice* notice in noticeList_) {
                        NSLog(@"notice jid %@, new jie:%@", notice.jid, jid);
                        if ([notice.jid isEqualToString:jid]) {
                            [self sendRecvNoticeUpdateDelegate:notice];
                            break;
                        }
                    }
                    [self sendUpdateUnReadCountDelegate];
                }
                [self sendNoticeListChangedDelegate];
            }else{
            }

        }];
    };
    [[BizlayerProxy shareInstance] getNoticeList:-1 withCount:100 withListener:listener];
}

- (void) getNoticeList
{
    if (getListSuccess_) {
        [self runInThread:^{
            [self sendGetNoticeFinishDelegate];
        }];
        return;
    }
    __weak NoticeManager* _self = self;
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        LOG_NETWORK_DEBUG(@"得到通知列表的原始数据：%@",result);
        [_self getNoticeListImpl:result];
    };
    [[BizlayerProxy shareInstance] getNoticeList:-1 withCount:100 withListener:listener];
}

- (void) getNoticeListImpl:(NSDictionary*) data
{
    [self runInThread:^{
        @autoreleasepool {
            ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
            LOG_NETWORK_INFO(@"获取到通知的原始数据：%@", data);
            if(resultInfo.succeed){
                id notices = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_DATA withClass:[ChatRecordForNotice class]];
                if ([self isNull:notices]) {
                    [noticeList_ removeAllObjects];
                }else{
                    LOG_NETWORK_INFO(@"获取到正确的通知数据");
                    [noticeList_ removeAllObjects];
                    [noticeList_ addObjectsFromArray:notices];
                }
                [self sendGetNoticeFinishDelegate];
                getListSuccess_ = YES;
            }else{
                getListSuccess_ = NO;
                [self sendGetNoticeFailureDelegate];
            }
        }
    }];
}

- (void) reset
{
    [super reset];
    [noticeList_ removeAllObjects];
    getListSuccess_ = NO;
}


-(void)markRead: (ChatRecordForNotice *)entry withCallback:(void(^)(BOOL)) callback
{
    [self runInThread:^{
        [entry markRead:^(BOOL is){
            LOG_NETWORK_DEBUG(@"设置通知已读：%@, 成功：%d", [entry toString], is);
            if (is) {
                [self sendNoticeListChangedDelegate];
            }
            callback(is);
            [self sendUpdateUnReadCountDelegate];
        }];
    }];
}

- (void)deleteNotice:(ChatRecordForNotice *)entry withCallback:(void(^)(BOOL)) callback
{
    WhistleCommandCallbackType  deleteNoticeCallback = ^(NSDictionary *result){
        [self runInThread:^{
            ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
            if(resultInfo.succeed){
                LOG_NETWORK_DEBUG(@"删除通知成功：%@", [entry toString]);
                [noticeList_ removeObject:entry];
                [self sendNoticeListChangedDelegate];
                callback(YES);
            }else{
                LOG_NETWORK_DEBUG(@"删除通知失败");
                callback(NO);
            }
        }];
    };
    
    [[BizlayerProxy shareInstance] deleteNoticeHistory:entry.jid withListener:deleteNoticeCallback];
    
}

- (void) deleteAllNotice:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteAllNotices:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
            [noticeList_ removeAllObjects];
            [self sendNoticeListChangedDelegate];
        }else{
            callback(NO);
        }
    }];
}

- (void) deleteReadedNotice:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteReadedNotices:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            for (ChatRecordForNotice* n in noticeList_) {
                if (n.isRead) {
                    [arr addObject:n];
                }
            }
            [noticeList_ removeObjectsInArray:arr];
            [self sendNoticeListChangedDelegate];
        }else{
            callback(NO);
        }
    }];
}

- (ChatRecordForNotice *)getNoticeByJid : (NSString *)jid
{
    for (ChatRecordForNotice *entry in noticeList_) {
        if([entry.jid isEqualToString:jid]){
            return entry;
        }
    }
    return nil;
}


#pragma delegate发送函数

- (void) sendNoticeListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"通知列表变更消息:%@", [super toArrayString:noticeList_]);
    for (id<NoticeDelegate> d in [self getListenerSet:@protocol(NoticeDelegate)]) {
        if ([d respondsToSelector:@selector(noticeListChanged:)]) {
            [d noticeListChanged:noticeList_];
        }

    }
}

- (void) sendGetNoticeFinishDelegate
{
    LOG_NETWORK_DEBUG(@"得到通知列表成功：%@", [super toArrayString:noticeList_]);
    for (id<NoticeDelegate> d in [self getListenerSet:@protocol(NoticeDelegate)]) {
        if ([d respondsToSelector:@selector(getNoticeFinish:)]) {
            [d getNoticeFinish:noticeList_];
        }

    }
}

- (void) sendGetNoticeFailureDelegate
{
    LOG_NETWORK_DEBUG(@"得到通知列表失败");
    for (id<NoticeDelegate> d in [self getListenerSet:@protocol(NoticeDelegate)]) {
        if ([d respondsToSelector:@selector(getNoticeFailure)]) {
            [d getNoticeFailure];
        }
    }
}

- (void) sendRecvNoticeUpdateDelegate:(ChatRecordForNotice*) notice
{
    LOG_NETWORK_DEBUG(@"接收到通知更新消息：%@", [notice toString]);
    for (id<NoticeDelegate> d in [self getListenerSet:@protocol(NoticeDelegate)]) {
        if ([d respondsToSelector:@selector(recvNoticeUpdate:)]) {
            [d recvNoticeUpdate:notice];
        }
    }
}

- (void) sendUpdateUnReadCountDelegate
{
    NSUInteger count = 0;
    for (ChatRecordForNotice* c in noticeList_) {
        if (!(c.isRead)) {
            count ++;
        }
    }
    LOG_NETWORK_DEBUG(@"通知未读消息数据:%d", count);
    for (id<NoticeDelegate> d in [self getListenerSet:@protocol(NoticeDelegate)]) {
        if ([d respondsToSelector:@selector(updateNoticeUnReadCount:)]) {
            [d updateNoticeUnReadCount:count];            
        }
    }
}

@end
