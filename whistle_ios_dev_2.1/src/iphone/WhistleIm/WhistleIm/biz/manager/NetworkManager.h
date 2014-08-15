//
//  NetworkManager.h
//  WhistleIm
//
//  Created by liuke on 13-12-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Manager.h"

@protocol NetworkDelegate <NSObject>

@optional

/**
 *  网络无连接状态的事件
 */
- (void) showNetworkTip;
/**
 *  点击重新登录界面的事件
 */
- (void) showLoginTip;
/**
 *  正在登录中的事件
 */
//- (void) showConnectingTip;
/**
 *  隐藏网络提醒事件
 */
- (void) hideNetworkTip;

@end

@interface NetworkManager : Manager

SINGLETON_DEFINE(NetworkManager)
/**
 *  是否在线标示。YES表示网络在线并且微哨在线
 */
@property (nonatomic, readonly) BOOL isOnlineState;

@end
