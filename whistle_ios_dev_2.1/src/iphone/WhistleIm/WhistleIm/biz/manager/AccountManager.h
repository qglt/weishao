//
//  AccountManager.h
//  Whistle
//
//  Created by wangchao on 13-2-20.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BizBridge.h"
#import "Manager.h"
#import "RemoteConfigInfo.h"

@protocol LoginStateDelegate <NSObject>

@optional
- (void) disconnected:(NSDictionary*) data;
/**
 *  同种设备登录
 */
- (void) disconnectedBySameDeviceLogin;
- (void) loginSucess;
- (void) loginFailure:(NSDictionary*) data;
- (void) recvCloudConfig:(NSArray*) list;
//- (void) conected:(NSDictionary*) data;


@end

enum AccountStatus {
    AccountLogout         = 0,
    AccountLogining       = 1,
    Offline               = 2,
    Away                  = 3,
    Busy                  = 4,
    Ios                   = 5,
    Android               = 6,
    Invisible             = 7,
    Online                = 8
};



typedef enum AccountStatus AccountStatus;

typedef void(^AccountListCallbackType)(NSArray*);

@class AccountInfo;

@interface AccountManager : Manager

@property (strong, nonatomic) AccountInfo* currentAccount;

@property (strong, nonatomic) NSMutableArray* historyAccounts;

@property (nonatomic) BOOL isCanChangePwd;

SINGLETON_DEFINE(AccountManager)

- (id)init;
/**
 *  获取用户登录历史列表，默认第0个账号设置为当前账号
 *
 *  @param callback 登录列表callback
 */
- (void)fetchAccountHistory:(AccountListCallbackType)callback;

/**
 *  使用cuurentAccount账号进行登录,使用delegate进行通知结果
 */
- (BOOL) login;
/**
 *  使用给定账号进行登录,使用delegate进行通知结果
 *
 *  @param userName 用户名
 *  @param pwd      密码
 */
- (BOOL) login:(NSString *)userName withPwd:(NSString *)pwd SavePWD:(BOOL) isSave invisible:(BOOL) invisible;

- (void) goOffline;

- (void) selectCouldConfig:(RemoteConfigInfo*) info;

- (void) changeUser;

- (void) searchCouldConfig:(NSString*) text withCallback:(void(^)(NSArray*)) callback;

- (void) changePwd:(void(^)(NSString*)) callback;

- (void) deleteAccount:(NSString*) user callback:(void(^)(BOOL)) callback;

- (void) setInvisibleStatus:(void(^)(BOOL)) callback;
- (void) setOnlineStatus:(void(^)(BOOL)) callback;

@end
