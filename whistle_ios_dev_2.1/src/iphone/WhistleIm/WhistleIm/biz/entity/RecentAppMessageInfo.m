//
//  RecentAppMessageInfo.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "RecentAppMessageInfo.h"
#import "JSONObjectHelper.h"
#import "BizBridge.h"
#import "BizlayerProxy.h"
#import "Constants.h"



@implementation RecentAppMessageInfo

@synthesize unreadCount;
@synthesize countAll;
@synthesize message;
@synthesize serviceInfo;

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if(self){
        self.unreadCount = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_UNREAD_COUNT defaultValue:0];
        self.countAll = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_COUNT_ALL defaultValue:0];
        self.msgid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_MESSAGE_ID];
        id temp = [jsonObj valueForKey:KEY_LAST_MESSAGE];
        self.message = [JSONObjectHelper getObjectFromJSON:temp  withClass:[AppMsgInfo class]];
        self.message.sendTime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SEND_TIME];
        self.sendTime = self.message.sendTime;
        temp = [jsonObj valueForKey:KEY_SERVICEINFO];
        self.serviceInfo = [JSONObjectHelper getObjectFromJSON:temp withClass:[ServiceInfo class]];
        self.isRead = [@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_READ]] ? YES : NO;
        temp = nil;
        jsonObj = nil;
    }
    
    return self;
}

-(void)markReadWithCallback:(void(^)(BOOL)) callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
        if(resultInfo.succeed){
            self.unreadCount = 0;
            callback(YES);
        }else{
            callback(NO);
        }
    };
    [[BizlayerProxy shareInstance] markAppMsgRead:self.serviceInfo.id withListener:listener];
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
