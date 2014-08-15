//
//  BizBridge.m
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

//#import "BizlayerProxy.h"
#import "BizBridge.h"
#import "JSONObjectHelper.h"
#import "OnBridgeCommandFinishedListener.h"

#define KEY_COMMANDID   @"callback_id"
#define KEY_METHOD      @"method"
#define KEY_ARGS        @"args"

//#define RESULT_KEY_RESULT       @"result"
//#define RESULT_KEY_REASON       @"reason"
//#define RESULT_STATUS_SUCCESS   @"success"
//#define RESULT_STATUS_FAIL      @"fail"

#define NOTIFY_TYPE             @"type"
#define NOTIFY_DATA             @"data"

static BizBridge *single = nil;

@implementation BizBridge


+(BizBridge *)getSingleInstance
{
    if(!single){
        single = [[BizBridge alloc] init];
    }
    return single;
}

-(id)init
{
    if(self = [super init]){
        self.callbackMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.listenerMap = [[NSMutableDictionary alloc] initWithCapacity:20];
        //self.notifyHandler = [[bizlayer_ios_notifier alloc] init];
    }
    return self;
}

-(NSString *)getAppConfig
{
    return [[bizlayer_ios_bridge getSingleInstance] getAppConfig];
    
}

-(void)nativeInit:(NSString *)config
{
    [[bizlayer_ios_bridge getSingleInstance] startBizLayer:config:self];

    
}

-(void)addNotificationListener:(WhistleNotificationListenerType)listener withType:(NSString *)type
{
    NSLog(@"ready to add notification listener for type %@",type);
    NSMutableArray *listeners = (NSMutableArray *)[self.listenerMap valueForKey:type];
    
    if(listeners == nil){
        listeners = [[NSMutableArray alloc] initWithCapacity:3];
        
        [self.listenerMap setValue:listeners forKey:type];
    }
    
    if (![listeners containsObject:listener]){
        [listeners addObject:listener];
    }else{
        NSLog(@"can not add duplicated listener!");
    }
        
    
}

-(void)removeNotificationListener:(WhistleNotificationListenerType)listener withType:(NSString *)type
{
    NSMutableArray *listeners = (NSMutableArray *)[self.listenerMap valueForKey:type];
    
    if(listeners == nil){
        //NSLog(@"no listeners for %@",type);
        return;
    }
    
    if (![listeners containsObject:listener]){
        //NSLog(@"the specified listener is not registered!");
        return;
    }else{
        [listeners removeObject:listener];
        if([listeners count] == 0){
            [self.listenerMap removeObjectForKey:type];
        }
    }
    
}

-(void)removeAllListener
{
    
    NSEnumerator *it =  [self.listenerMap keyEnumerator];
    NSString *key = [it nextObject];
    NSMutableArray *value = nil;
    while(key != nil){
        value = [self.listenerMap objectForKey:key];
        [value removeAllObjects];
        key = [it nextObject];
    }
    [self.listenerMap removeAllObjects];

}

-(void)onBizNotify:(NSString *)jsonString
{
    @autoreleasepool {
        
    
    //[super onBizNotify:jsonString];
//    NSLog(@"\nbiz start to send message");
//    NSLog(@"noBizNotify %@",jsonString);

    LOG_NETWORK_DEBUG(@"notify的原始数据: %@",jsonString);
    if (jsonString == Nil) {
        return;
    }
    NSMutableDictionary *notificationJson = nil;
    notificationJson = (NSMutableDictionary *)[JSONObjectHelper decodeJSON:jsonString];
    NSLog(@"\nnotification json == %@", notificationJson);
    NSString *notifyType = [notificationJson objectForKey:NOTIFY_TYPE];
//    NSLog(@"\nnotifyType == %@", notifyType);
    LOG_NETWORK_INFO(@"notify的类型:%@", notifyType);

    id data = [notificationJson objectForKey:NOTIFY_DATA];
    NSLog(@"\ndata== %@", data);

    
    //NSLog(@"data class is %@", [data class]);
    NSMutableDictionary *notificationData = nil;
    if([data isKindOfClass:[NSString class]]){
        notificationData = (NSMutableDictionary *)[JSONObjectHelper decodeJSON:data];
    }else if([data isKindOfClass:[NSMutableDictionary class]]){
        notificationData = data;
    //}else if([data isMemberOfClass:[NSCFString class]]){
        
    }else{
        NSLog(@"error notification data!");
        return;
    }
    
    
    [self dispatchNoficationData:notifyType data:notificationData];
    notificationJson = nil;
    notificationData = nil;
    }
}

-(void)dispatchNoficationData:(NSString *)type data:(NSDictionary *)data
{
    @autoreleasepool {
        
    
    NSDictionary *listeners = [NSDictionary dictionaryWithDictionary:self.listenerMap];
    
    NSArray *listenerWithType = [listeners objectForKey:type];
    
    //NSLog(@"dispatch notification for type %@ with count %d",type,[listenerWithType count]);
    if(listenerWithType){
        WhistleNotificationListenerType listener = nil;
        NSLog(@"bizbridge listener map count == %d", [listenerWithType count]);
        for (int i = 0; i < [listenerWithType count]; i ++) {
            NSLog(@"dispatch data for listener index == %d",i);
            NSLog(@"dispatch data for listener === %@", [listenerWithType objectAtIndex:i]);

            listener = [listenerWithType objectAtIndex:i];
            
            listener(data);
        }
    }else{
        NSLog(@"no listeners for %@",type);
    }
    }
}

-(void)callNative:(NSString *)para
{
    [[bizlayer_ios_bridge getSingleInstance] callBiz:para];
}

- (void) callback:(NSString*) para
{
    [[bizlayer_ios_bridge getSingleInstance] callback:para];
}


-(void)asyncCall:(NSString*)commandCode inputPara:(NSString*)para callback:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        
    
        NSString *cmdId = [[NSString alloc] initWithFormat:@"cmd%f",[[NSDate date] timeIntervalSince1970]];
        if(listener != nil){
            //NSLog(@"callback push %@,%p",cmdId,listener);
            [self.callbackMap setObject:listener forKey:cmdId];
        }
        
        id paraJson = nil;
        id totalJson = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        if(para == nil || [para length] <= 0){
            paraJson = [[NSMutableDictionary alloc] initWithCapacity:1];
        }else{
            paraJson = [JSONObjectHelper decodeJSON:para];
        }
        
        [totalJson setObject:cmdId forKey:KEY_COMMANDID];
        [totalJson setObject:commandCode forKey:KEY_METHOD];
        [totalJson setObject:paraJson forKey:KEY_ARGS];
        NSLog(@"request params = %@",totalJson);
        [self callNative:[JSONObjectHelper encodeStringFromJSON:totalJson]];
    }
}


-(void)onNativeCommandResult:(NSString *)data
{
    @autoreleasepool {
        
    
        NSDictionary *jsonValue = (NSDictionary *)[JSONObjectHelper decodeJSON:data];
        NSLog(@"response jsonValue = %@",jsonValue);
        NSString* commandId = [jsonValue objectForKey:@"callback_id"];
        //NSObject<OnBridgeCommandFinishedListener> *listener = [self.callbackMap objectForKey:commandId];
        void(^listener)(NSDictionary*) = [self.callbackMap objectForKey:commandId];
        if(listener != nil){
            [self.callbackMap removeObjectForKey:commandId];
            listener(jsonValue);
            
        }else{
            //[JSONObjectHelper releaseJson:jsonValue];
            NSLog(@"onNativeCommandResult listener is nil");
        }
        jsonValue = nil;
    }
}

//-(ResultInfo *) parseCommandResusltInfo:(NSDictionary *) jsonObj {
//    ResultInfo *resultInfo = [[ResultInfo alloc] init];
//    resultInfo.succeed = [self parseResultStatus:jsonObj];
//    resultInfo.errorMsg = [jsonObj objectForKey:RESULT_KEY_REASON];
//    return resultInfo;
//}

//-(BOOL) parseResultStatus:(NSDictionary *) jsonObj {
//    NSString *status = [jsonObj objectForKey:RESULT_KEY_RESULT];
//    if(status==nil || [status isEqualToString:RESULT_STATUS_SUCCESS]) {
//        return true;
//    }
//    return false;
//}

@end
