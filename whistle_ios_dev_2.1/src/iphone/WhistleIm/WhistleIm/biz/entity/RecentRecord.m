//
//  RecentRecord.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

static NSString *KEY_JID = @"jid";
static NSString *KEY_TYPE = @"type";
static NSString *KEY_TIME = @"time";
static NSString *KEY_UNREAD_ACCOUNT = @"unread_account";
static NSString *KEY_INFO = @"info";
static NSString *KEY_MSG = @"msg";
static NSString *KEY_TEXT = @"txt";
static NSString *KEY_SPEAKER = @"speaker";
static NSString *KEY_FLAG = @"flag";

#import "RecentRecord.h"
#import "JSONObjectHelper.h"
#import "Whistle.h"
#import "LightAppMessageInfo.h"
#import "SmileyParser.h"
#import "SystemMessageInfo.h"

@implementation RecentRecord
@synthesize time;

@synthesize unreadAccount;

@synthesize type;

@synthesize speaker;

@synthesize msgContent;

@synthesize jid;
-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [self init];
    if(self){
        [self reset:jsonObj];
        self.isMyDevice = NO;
        jsonObj = nil;
    }
    
    return self;
}

-(void)reset:(NSDictionary *)jsonObj
{
    self.cacheJsonObj = jsonObj;
    self.time = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TIME];
    self.unreadAccount = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_UNREAD_ACCOUNT defaultValue:0];
    self.type = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE];
    self.updateType  = [self parseRecnetContactUpdateType:jsonObj];
    id msgObj = [jsonObj objectForKey:KEY_MSG];
    if ([self getType] == RecentRecord_LightApp) {
        NSDictionary* tmp = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_INFO];
        self.jid = [JSONObjectHelper getStringFromJSONObject:tmp forKey:KEY_JID];
        if (!self.jid) {
            self.jid = [JSONObjectHelper getStringFromJSONObject:tmp forKey:KEY_APPID];
        }
        LightAppMessageInfo* detail = nil;
        if(self.updateType == RecentContactUpdateType_DELETE)
        {
            
            return;
        }else if ([msgObj isKindOfClass:[NSDictionary class]]) {
            detail = [JSONObjectHelper getObjectFromJSON: msgObj withClass:[LightAppMessageInfo class]];
        }else{
            detail = [JSONObjectHelper getObjectFromJSON:[msgObj isKindOfClass:[NSNull null]]?[JSONObjectHelper decodeJSON:msgObj]:[NSDictionary dictionary] withClass:[LightAppMessageInfo class]];
            LOG_NETWORK_DEBUG(@"msgobj不是个字典，是什么：%@",msgObj);
        }

        self.extraInfo = detail;
    }else{
        if(msgObj != nil){
            NSDictionary *msgJson = nil;
            if([msgObj isKindOfClass:[NSDictionary class]]){
                msgJson = [NSDictionary dictionaryWithDictionary:msgObj];
            }else{
                msgJson = [JSONObjectHelper decodeJSON:[msgObj description]];
            }
            
            self.msgContent = msgJson;
        }
        if ([self getType] == RecentRecord_System) {
            self.speaker = @"系统消息";
            self.extraInfo = [JSONObjectHelper getObjectFromJSON:self.msgContent withClass:[SystemMessageInfo class]];
        }else{
            self.speaker = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SPEAKER];
        }
        
        self.jid = [JSONObjectHelper getStringFromJSONObject:[jsonObj objectForKey:KEY_INFO] forKey:KEY_JID];
        self.speakerID = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_JID];
        id send = [jsonObj objectForKey:KEY_IS_SEND];
        if (send) {
            if ([send isKindOfClass:[NSString class]]) {
                self.isSend = [@"1" isEqualToString:send];
            }else{
                self.isSend = [send boolValue];
            }
        }

    }
}

-(RecentContactUpdateType)parseRecnetContactUpdateType:(NSDictionary *)jsonObj
{
    NSString *result = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_FLAG];
    RecentContactUpdateType rType = RecentContactUpdateType_NEW;
    if([result isEqualToString:kUPDATECURRENT])
    {
        rType = RecentContactUpdateType_UPDATECURRENT;
    }else if([result isEqualToString:kEMPTY])
    {
        rType = RecentContactUpdateType_EMPTY;
    }else if([result isEqualToString:kNEW])
    {
        rType = RecentContactUpdateType_NEW;
    }else if([result isEqualToString:kMARKREAD])
    {
        rType = RecentContactUpdateType_MARKREAD;
    }else if([result isEqualToString:kDELETE])
    {
        rType = RecentContactUpdateType_DELETE;
    }
    return rType;
}

+(NSString *)getRecnetContactUpdateTypeString:(RecentContactUpdateType)recnetContactUpdateType
{
    switch (recnetContactUpdateType) {
        case RecentContactUpdateType_UPDATECURRENT:
            return kUPDATECURRENT;
        case RecentContactUpdateType_EMPTY:
            return kEMPTY;
        case RecentContactUpdateType_NEW:
            return kNEW;
        case RecentContactUpdateType_DELETE:
            return kDELETE;
        case RecentContactUpdateType_MARKREAD:
            return kMARKREAD;
        default:
            return kNEW;
            break;
    }
}

-(NSDictionary *)toJsonObject
{
    return self.cacheJsonObj;
}

- (void) clear
{
    self.cacheJsonObj = nil;
    self.extraInfo = nil;
}

- (enum RecentRecordType) getType
{
    if ([@"crowd" isEqualToString:self.type]) {
        return RecentRecord_Crowd;
    }else if ([@"group" isEqualToString:self.type]){
        return RecentRecord_Discussion;
    }else if ([@"conversation" isEqualToString:self.type]){
        return RecentRecord_Conversation;
    }else if ([@"notice" isEqualToString:self.type]){
        return RecentRecord_Notice;
    }else if ([@"system" isEqualToString:self.type]){
        return RecentRecord_System;
    }else if ([@"app_message" isEqualToString:self.type]){
        return RecentRecord_AppMsg;
    }else if ([@"lightapp" isEqualToString:self.type]){
        return RecentRecord_LightApp;
    }
    return RecentRecord_Error;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
