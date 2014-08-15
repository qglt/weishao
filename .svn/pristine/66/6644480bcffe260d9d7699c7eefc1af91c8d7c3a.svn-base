 //
//  AccountManager.m
//  Whistle
//
//  Created by wangchao on 13-2-20.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "AccountManager.h"
#import "AccountInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"
#import "BizlayerProxy.h"

#import "RosterManager.h"
#import "CrowdManager.h"
#import "NoticeManager.h"
#import "AppMessageManager.h"
#import "DiscussionManager.h"
#import "MessageManager.h"
#import "RemoteConfigInfo.h"
#import "NetworkManager.h"
#import "AppManager.h"
#import "LocalRecentListManager.h"
#import "SystemMsgManager.h"
#import "CacheManager.h"
#import "CloudAccountManager.h"

static AccountListCallbackType bufferCallback = nil;


@interface AccountManager()
{
    NSArray* accountList_;
    NSString* callback_id;
}


@end

@implementation AccountManager

@synthesize currentAccount;


SINGLETON_IMPLEMENT(AccountManager)

-(id)init
{
    if(self = [super init]){
        self.currentAccount = [[AccountInfo alloc] init];
    }
    return self;
}

- (void) setInvisibleStatus:(void(^)(BOOL)) callback
{
    [[BizlayerProxy shareInstance] setStatus: @"Invisible" withListener:^(NSDictionary *data) {
        
    }];
}

- (void) setOnlineStatus:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] setStatus: @"Online" withListener:^(NSDictionary *data) {
        
    }];
}

-(void)reset
{
    [super reset];
    if(self.historyAccounts){
        [self.historyAccounts removeAllObjects];
    }
    self.historyAccounts = nil;
    callback_id = nil;
}


-(void)fetchAccountHistory:(AccountListCallbackType)callback
{
    void(^listener)(NSDictionary*) = ^(NSDictionary *result){
        [self runInThread:^{
            id rawData = [result objectForKey:KEY_LIST];
            NSArray *rawAccounts = nil;
            if([self isNull:rawData]){
                rawAccounts = [[NSArray alloc] initWithObjects:nil];
            }else{
                rawAccounts = rawData;
            }
            NSArray *accountList = [JSONObjectHelper getObjectArrayFromJSONArray:rawAccounts withClass:[AccountInfo class]];
            
            accountList_ = accountList;
            if ([accountList count] > 0) {
                self.currentAccount = [accountList objectAtIndex:0];
            }
            callback(accountList_);
            rawData = nil;
            LOG_NETWORK_DEBUG(@"获取得到的登录历史信息：%@",[super toArrayString:accountList_]);
            accountList = nil;
        }];
    };
    [[NetworkManager shareInstance] register4Biz];
    [[BizlayerProxy shareInstance] getLoginHistory:listener];
}

- (BOOL) login
{
    void(^listener)(NSDictionary*) = ^(NSDictionary *result){

        ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
        if(resultInfo.succeed){
            [self sendLoginSuccessToListener];
            [self changePwd:^(NSString *url) {
                
            }];
        }else{
            [self sendLoginFailureToListener:result];
        }
        result = nil;
    };

    [self register4Biz];
    [[NetworkManager shareInstance] register4Biz];
    [[CacheManager shareInstance] unserialization:self.currentAccount.userName];
    [[AppManager shareInstance] register4Biz];
    if ([self.currentAccount isUserNameValid]){
        [[BizlayerProxy shareInstance] login:self.currentAccount.userName password:self.currentAccount.password rememberPW:self.currentAccount.savePasswd autoLogin:self.currentAccount.autoLogin status: self.currentAccount.lastLoginStatus callback:listener];
        return YES;
    }
    return NO;

}

- (BOOL) login:(NSString *)userName withPwd:(NSString *)pwd SavePWD:(BOOL) isSave invisible:(BOOL) invisible
{

    AccountInfo* acc = nil;
    BOOL isFind = NO;
    for (AccountInfo* ai in accountList_) {
        if ([ai.userName isEqualToString:userName]) {
            acc = ai;
            acc.password = pwd;
            isFind = YES;
            break;
        }
    }
    if (!isFind) {
        acc = [[AccountInfo alloc] init];
        acc.userName = userName;
        acc.password = pwd;
    }

    acc.savePasswd = isSave;
    if (invisible) {
        [acc setOfflineLogin];
    }else{
        [acc setOnlineLogin];
    }
    self.currentAccount = acc;
    
    return [self login];
}

- (void) register4Biz
{
    [super register4Biz];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        WhistleNotificationListenerType onDisconnectedListener = ^(NSDictionary *data){
            LOG_NETWORK_INFO(@"微哨掉线后的信息：%@",data);
            if ([[data allKeys] containsObject:@"biz.disconnect_by_user_disconnect"]) {
                //用户切换账号
            }else{
                [self sendDisconnectedStateToListener:data];
                if ([[data allKeys] containsObject:@"biz.disconnect_by_logon_different_pc"]) {
                    [self sendDisconnectedBySameDeviceLogin];
                }
            }
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener:onDisconnectedListener withType:NOTIFY_disconnected];
        
        WhistleCommandCallbackType onRecvCloudConfig = ^(NSDictionary* data){
            LOG_NETWORK_INFO(@"接收云配置信息：%@", data);
            [self onRecvCloudConfigImpl:data];
        };
        [[[BizlayerProxy shareInstance] whistleBizBridge] addNotificationListener: onRecvCloudConfig withType:NOTIFY_recv_cloud_config];

        [NoticeManager shareInstance];
        [AppMessageManager shareInstance];
        [RosterManager shareInstance];
        [AccountManager shareInstance];
        [CrowdManager shareInstance];
        [LocalRecentListManager shareInstance];
        [SystemMsgManager shareInstance];
        [AppManager shareInstance];
    });
}

- (void) onRecvCloudConfigImpl:(NSDictionary*) data
{
    [self runInThread:^{
        LOG_NETWORK_INFO(@"云配置返回原始数据：%@", data);
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            callback_id = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_CALLBACKID];
            NSDictionary* config = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_CONFIG];
            NSDictionary* dataJson = [JSONObjectHelper getJSONFromJSON:config forKey: KEY_DATA];
            id list = [JSONObjectHelper getObjectArrayFromJsonObject:dataJson forKey: KEY_ITEMS withClass:[RemoteConfigInfo class]];
            if ([self isNull:list]) {
                
            }else{
                [self sendRecvCloudConfigDelegate:list];
            }
        }
    }];

}

- (void) selectCouldConfig:(RemoteConfigInfo *)info
{
    if (callback_id) {
        [[BizlayerProxy shareInstance] callback2biz:callback_id withDomain:info.domain];
    }
}

- (void) goOffline
{
    [[BizlayerProxy shareInstance] goOffline:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"账号下线:%@", data);
    }];
}

- (void) changeUser
{
    void(^listener)(NSDictionary*) = ^(NSDictionary* data){
        LOG_NETWORK_DEBUG(@"切换账号:%@", data);
    };
    [[BizlayerProxy shareInstance] changeUser:listener];
    [[NoticeManager shareInstance] reset];
    [[AppMessageManager shareInstance] reset];
    [[RosterManager shareInstance] reset];
    [[AccountManager shareInstance] reset];
//    [[AccountManager shareInstance] register4Biz];
    [[CrowdManager shareInstance] reset];
    [[LocalRecentListManager shareInstance] reset];
    [[SystemMsgManager shareInstance] reset];
    [[AppManager shareInstance] reset];
}

- (void) searchCouldConfig:(NSString *)text withCallback:(void (^)(NSArray *))callback
{
    [[BizlayerProxy shareInstance] searchCloudConfig:text withListener:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"搜索云配置返回的原始数据:%@", data);
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            NSArray* msgs = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:@"school" withClass:[RemoteConfigInfo class]];
            if ([self isNull:msgs]) {
                callback([[NSArray alloc] init]);
                LOG_NETWORK_DEBUG(@"搜索云配置返回的数据:%@", [super toArrayString:msgs]);
            }else{
                NSArray* ret = [msgs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    RemoteConfigInfo* r1 = obj1;
                    RemoteConfigInfo* r2 = obj2;
                    return [r1.pinyin compare:r2.pinyin];
                }];
                LOG_NETWORK_DEBUG(@"搜索云配置返回的数据:%@", [super toArrayString:msgs]);
                callback(ret);
                msgs = nil;
            }
        }else{
            callback([[NSArray alloc] init]);
        }
    }];
}

- (void) changePwd:(void (^)(NSString *))callback
{
    [[BizlayerProxy shareInstance] canUserChangedPassword:^(NSDictionary *data) {
        if ([data objectForKey:KEY_CAN_CHANGE_PASSWORD] && [[data objectForKey:KEY_CAN_CHANGE_PASSWORD] boolValue]) {
            self.isCanChangePwd = YES;
            [[BizlayerProxy shareInstance] getChangePasswordUri:^(NSDictionary *data) {
                LOG_NETWORK_DEBUG(@"得到修改密码uri的原始数据：%@", data);
                NSString* pwd = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_CHANGE_PASSWORD_URI];
                [super getToken:^(NSString *token) {
                    NSString* url = [NSString stringWithFormat:@"%@?type=1&token=%@", pwd, token];
                    callback(url);
                }];
                LOG_NETWORK_DEBUG(@"得到修改密码uri的数据：%@", pwd);

            }];
        }else{
            self.isCanChangePwd = NO;
            callback(nil);
        }
    }];
    
}

- (void) deleteAccount:(NSString *)user callback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] deleteAccountFromHistory:user withDeleteLocalFile:NO withListener:^(NSDictionary *data) {
        ResultInfo* result = [super parseCommandResusltInfo:data];
        if (result.succeed) {
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

#pragma 发送delegate消息


- (void) sendDisconnectedBySameDeviceLogin
{
    LOG_NETWORK_ERROR(@"同种设备登录");
    for (id<LoginStateDelegate> d in [self getListenerSet:@protocol(LoginStateDelegate)]) {
        if ([d respondsToSelector:@selector(disconnectedBySameDeviceLogin)]) {
            [d disconnectedBySameDeviceLogin];
        }
    }
}

- (void) sendDisconnectedStateToListener:(NSDictionary*) data
{
    LOG_NETWORK_ERROR(@"微哨掉线的信息：%@",data);
    for (id<LoginStateDelegate> d in [self getListenerSet:@protocol(LoginStateDelegate)]) {
        if ([d respondsToSelector:@selector(disconnected:)]) {
            [d disconnected:data];
        }
    }
}

- (void) sendLoginSuccessToListener
{
    //登录成功后，向biz层注册manager
    [LocalRecentListManager shareInstance];
    [[AccountManager shareInstance] register4Biz];
    
    [[CloudAccountManager shareInstance] reset];
    [[RosterManager shareInstance] addListener:[CloudAccountManager shareInstance]];
    [[AppMessageManager shareInstance] register4Biz];
    [[CrowdManager shareInstance] register4Biz];
    [[DiscussionManager shareInstance] register4Biz];
    [[RosterManager shareInstance] register4Biz];
    [[NoticeManager shareInstance] register4Biz];
    [[MessageManager shareInstance] register4Biz];
    LOG_NETWORK_DEBUG(@"登录成功");
    for (id<LoginStateDelegate> d in [self getListenerSet:@protocol(LoginStateDelegate)]) {
        if ([d respondsToSelector:@selector(loginSucess)]) {
            [d loginSucess];
        }
    }
}

- (void) sendLoginFailureToListener:(NSDictionary*) data
{
    LOG_NETWORK_ERROR(@"登录失败：%@",data);
    for (id<LoginStateDelegate> d in [self getListenerSet:@protocol(LoginStateDelegate)]) {
        if ([d respondsToSelector:@selector(loginFailure:)]) {
            [d loginFailure:data];            
        }

    }
}
- (void) sendRecvCloudConfigDelegate:(NSArray*) list
{
    NSArray* ret = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        RemoteConfigInfo* r1 = obj1;
        RemoteConfigInfo* r2 = obj2;
        return [r1.pinyin compare:r2.pinyin];
    }];
    LOG_NETWORK_DEBUG(@"接收到的云配置信息：%@", [self toArrayString:ret]);
    for (id<LoginStateDelegate> d in [self getListenerSet:@protocol(LoginStateDelegate)]) {
        if ([d respondsToSelector:@selector(recvCloudConfig:)]) {
            [d recvCloudConfig:ret];
        }
    }
}

@end
