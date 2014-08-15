//
//  BizBridge.h
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"




typedef void(^WhistleCommandCallbackType)(NSDictionary* data);
typedef void(^WhistleNotificationListenerType)(NSDictionary*);


@interface BizBridge : NSObject<bizlayer_ios_notifier>

+(BizBridge *)getSingleInstance;

-(NSString *)getAppConfig;

-(void)nativeInit:(NSString*)config;

-(void)asyncCall:(NSString*)commandCode inputPara:(NSString*)para callback:(WhistleCommandCallbackType)listener;

-(void)callNative:(NSString*)para;

- (void) callback:(NSString*) para;
//-(void)onCommandResult:(NSString*)data;

-(void)addNotificationListener:(WhistleNotificationListenerType)listener withType:(NSString *)type;

-(void)removeNotificationListener:(WhistleNotificationListenerType)listener withType:(NSString *)type;

-(void)removeAllListener;

//-(void)onBizlayerNotify:(NSString*)data;

@property (nonatomic, strong) NSMutableDictionary *callbackMap;

@property (nonatomic,strong) NSMutableDictionary *listenerMap;

//@property (nonatomic, strong) bizlayer_ios_notifier *notifyHandler;

//-(ResultInfo *) parseCommandResusltInfo:(NSDictionary *) jsonObj;

@end

