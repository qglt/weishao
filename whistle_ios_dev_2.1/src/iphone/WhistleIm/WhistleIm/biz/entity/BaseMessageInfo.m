//
//  BaseMessageInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "BaseMessageInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@class ConversationInfo;
@class LightAppMessageInfo;

@implementation BaseMessageInfo



- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.messageType = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey: KEY_TYPE];
        id msg_ = [jsonObj valueForKey:KEY_MSG];//[JSONObjectHelper getJSONFromJSON:jsonObj forKey: KEY_MSG];
        if ([msg_ isKindOfClass:[NSDictionary class]]) {
            self.msg = msg_;
        }else if([msg_ isKindOfClass:[NSString class]]){
            
            if ([@"\"" isEqualToString:[msg_ substringWithRange:NSMakeRange(0, 1)]]) {
                [msg_ deleteCharactersInRange:NSMakeRange(0, 1)];
                msg_ = [msg_ stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            }
            if ([@"\"" isEqualToString:[msg_ substringWithRange:NSMakeRange([msg_ length] - 1, 1)]]) {
                [msg_ deleteCharactersInRange:NSMakeRange([msg_ length] - 1, 1)];
            }
            self.msg = [JSONObjectHelper decodeJSON:msg_];
        }

        self.status = MSG_RECVING;
    }
    return self;
}

- (ConversationType) msgType
{
    if ([@"conversation" isEqualToString:self.messageType]) {
        return SessionType_Conversation;
    }else if ([@"crowd_chat" isEqualToString:self.messageType]){
        return SessionType_Crowd;
    }else if ([@"group_chat" isEqualToString:self.messageType]){
        return SessionType_Discussion;
    }else if ([@"lightapp_msg" isEqualToString:self.messageType]){
        return SessionType_LightApp;
    }
    
    return SessionType_Error;
}

+(NSString *)getConvType:(ConversationType)type
{
    NSString *result = nil;
    switch (type) {
        case SessionType_Conversation:
            result = @"conversation";
            break;
        case SessionType_Discussion:
            result = @"group_chat";
            break;
        case SessionType_Crowd:
            result = @"crowd_chat";
            break;
        case SessionType_LightApp:
            return @"lightapp_msg";
        default:
            result = @"conversation";
    }
    return  result;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
