//
//  NetworkManager.m
//  WhistleIm
//
//  Created by liuke on 13-12-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NetworkManager.h"
#import "Reachability.h"
#import "AccountManager.h"
#import "NetworkEnv.h"
#import "DisconnectedByLogOnSameDevieceAlert.h"
#import "BizlayerProxy.h"

@interface NetworkManager() <LoginStateDelegate>
{
    BOOL isOnline_;
    Reachability* reach_;
}

@end

@implementation NetworkManager

@synthesize isOnlineState = _isOnlineState;

SINGLETON_IMPLEMENT(NetworkManager)

- (id) init
{
    self = [super init];
    if (self) {
        isOnline_ = YES;
    }
    return self;
}

- (void) register4Biz
{
    [super register4Biz];
    [[AccountManager shareInstance] addListener:self];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_GENERAL_DEBUG(@"注册网络变化提醒");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        reach_ = [Reachability reachabilityWithHostname:[[BizlayerProxy shareInstance] getExportUrl]];
        [reach_ startNotifier];

    });
}

- (void) reset
{
    [super reset];
}

- (void) reachabilityChanged: (NSNotification *) note
{
    Reachability* r = [note object];
    LOG_GENERAL_DEBUG(@"网络变化为:%d", [r currentReachabilityStatus]);
    if ([r currentReachabilityStatus] == NotReachable) {
        LOG_GENERAL_DEBUG(@"网络没有连接");
        isOnline_ = NO;
        _isOnlineState = NO;
        if (![NetworkEnv isLocalWifiAvailable]) {
            [self sendShowNetworkTipDelegate];
        }else{
            [self sendShowLoginTipDelegate];
        }
        [[AccountManager shareInstance] goOffline];
    }
    else if(!isOnline_){
        LOG_GENERAL_DEBUG(@"网络连接成功");
        isOnline_ = YES;
        [self sendShowLoginTipDelegate];
        if (!(self.isOnlineState)) {
            [[AccountManager shareInstance] login];
        }
    }
}


- (void) disconnected:(NSDictionary *)data
{
    _isOnlineState = NO;
    if ([NetworkEnv isLocalWifiAvailable]) {
        [self sendShowLoginTipDelegate];
    }else{
        [self sendShowNetworkTipDelegate];
    }

}

- (void) loginFailure:(NSDictionary *)data
{
    _isOnlineState = NO;
    [self sendShowLoginTipDelegate];
}

- (void) loginSucess
{
    _isOnlineState = YES;
    isOnline_ = YES;
    [self sendHideNetworkTipDelegate];
}

static DisconnectedByLogOnSameDevieceAlert* alert = nil;

- (void) disconnectedBySameDeviceLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [[DisconnectedByLogOnSameDevieceAlert alloc] init];
        [alert show];
    });
}

#pragma mark 发送delegate事件


- (void) sendShowNetworkTipDelegate
{
    LOG_NETWORK_DEBUG(@"显示网络提醒为网络状态显示");
    for (id<NetworkDelegate> d in [self getListenerSet:@protocol(NetworkDelegate)]) {
        if ([d respondsToSelector:@selector(showNetworkTip)]) {
            [d showNetworkTip];
        }
    }
}

- (void) sendShowLoginTipDelegate
{
    LOG_NETWORK_DEBUG(@"显示网络提醒为点击登录状态");
    for (id<NetworkDelegate> d in [self getListenerSet:@protocol(NetworkDelegate)]) {
        if ([d respondsToSelector:@selector(showLoginTip)]) {
            [d showLoginTip];
        }
    }
}

//- (void) sendShowConnectingTipDelegate
//{
//    for (id<NetworkDelegate> d in [self getListenerSet:@protocol(NetworkDelegate)]) {
//        if ([d respondsToSelector:@selector(showConnectingTip)]) {
//            [d showConnectingTip];
//        }
//    }
//}

- (void) sendHideNetworkTipDelegate
{
    LOG_NETWORK_DEBUG(@"隐藏网络提醒");
    for (id<NetworkDelegate> d in [self getListenerSet:@protocol(NetworkDelegate)]) {
        if ([d respondsToSelector:@selector(hideNetworkTip)]) {
            [d hideNetworkTip];
        }
    }
}

@end
