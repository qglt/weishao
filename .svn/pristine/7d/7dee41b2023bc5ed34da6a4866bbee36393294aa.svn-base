//
//  bizlayer_ios_proxy.h
//  AnanCmdIM
//
//  Created by chao.wang on 12-12-20.
//  Copyright (c) 2012年 chao.wang. All rights reserved.
//

#ifndef AnanCmdIM_bizlayer_ios_proxy_h
#define AnanCmdIM_bizlayer_ios_proxy_h

#import <Foundation/Foundation.h>

@protocol bizlayer_ios_notifier;

@interface bizlayer_ios_bridge : NSObject

@property (nonatomic, weak) id<bizlayer_ios_notifier> notifyHandler;

+ (bizlayer_ios_bridge *)getSingleInstance;

- (void)startBizLayer: (NSString*)dataPath : (id<bizlayer_ios_notifier>)notifyHandler;

//- (void) initBizLayerWithNotifier:(id<bizlayer_ios_notifier>)notifyHandler;

- (void)callBiz: (NSString*)para;

- (NSString *)getAppConfig;

- (void) callback:(NSString*) para;



@end

@protocol bizlayer_ios_notifier

@required
- (void) onBizNotify: (NSString*)jsonString;
- (void) onNativeCommandResult: (NSString *)result;
@end

#endif
