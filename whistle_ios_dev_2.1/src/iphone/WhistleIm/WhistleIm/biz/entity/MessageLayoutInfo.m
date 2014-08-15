//
//  MessageLayoutInfo.m
//  WhistleIm
//
//  Created by wangchao on 13-9-9.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "MessageLayoutInfo.h"
#import "MessageText.h"
#import "JSONObjectHelper.h"
#import "ImUtils.h"
#import "CrowdManager.h"
#import "DiscussionManager.h"
#import "RosterManager.h"



@implementation MessageLayoutInfo

@synthesize type;
@synthesize msgObj;
@synthesize extraInfo;
@synthesize jid;
@synthesize showName;
@synthesize send;

- (id)init
{
    self = [super init];
    if (self) {
        send = true;
    }
    return self;
}
-(id)initWithLayoutType:(MessageLayoutType)layouttype message:(NSString *)msg
{
    self = [super init];
    if (self) {
        type = layouttype;
        NSLog(@"msg is %@",msg);
        msgObj = [self getMessageObjFromJson:msg];
        send = true;
    }
    return self;
}

-(id)initWithLayoutType:(MessageLayoutType)layouttype messageText:(MessageText *)msg
{
    self = [super init];
    if (self) {
        self.type = layouttype;
        msgObj = msg;
        send = true;
    }
    return self;
}

-(MessageText *)getMessageObjFromJson:(NSString *)msg
{
    NSDictionary *dic = [JSONObjectHelper decodeJSON:msg];

    MessageText *mt = [[MessageText alloc] init];

    NSString *stdtime = [NSString stringWithFormat:@"%i",[JSONObjectHelper getIntFromJSONObject:dic forKey:STDTIME defaultValue:0]];

    if(stdtime && stdtime.length>0)
    {
        mt.time = [MessageLayoutInfo formatTime:stdtime];
    }else
    {
        mt.time = [self formatAppTime:[JSONObjectHelper getStringFromJSONObject:dic forKey:TIMES]];
        
    }
    mt.style = [JSONObjectHelper getStringFromJSONObject:dic forKey:STYLE];
    mt.txt = [JSONObjectHelper getStringFromJSONObject:dic forKey:TXT];
    return mt;
}


-(NSDate *)formatAppTime:(NSString *)time
{
    if(time == nil)
    {
        return [NSDate date];
    }
 
    NSMutableString *formatResult = [NSMutableString stringWithString:time];
    
    [formatResult replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];

    if([formatResult rangeOfString:@"上午"].location!=NSNotFound)
    {
         [formatResult replaceOccurrencesOfString:@"上午" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];
    }

    if([formatResult rangeOfString:@"下午"].location!=NSNotFound)
    {
         [formatResult replaceOccurrencesOfString:@"下午" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

     return [formatter dateFromString:formatResult];

}

+(NSDate *)formatTime:(NSString *)time
{
      NSLog(@"4-1");
    if(time == nil)
    {
        NSLog(@"4-2");
        return [NSDate date];
    }else
    {
        NSLog(@"4-3");
        return [NSDate dateWithTimeIntervalSince1970:time.doubleValue];
    }
}

-(void)getFriendInfoByJid:(NSString *)inputJid withCallback:(void (^)(FriendInfo *))callback
{
    
    __weak MessageLayoutInfo *temp = self;
    switch ([ImUtils getChatType:inputJid]) {
        case SessionType_Crowd:
        {
            [[RosterManager shareInstance] getFriendInfoByJid:self.jid needRealtime:NO WithCallback:^(FriendInfo *info) {
                if(info)
                {
                    temp.extraInfo = info;
                    callback(info);
                }else
                {
                    [[RosterManager shareInstance] getFriendInfoByJid:jid needRealtime:YES WithCallback:^(FriendInfo * tempinfo) {
                        temp.extraInfo = tempinfo;
                        callback(tempinfo);
                    }];
                }
                
            }];
        }
            
            break;
        case SessionType_Discussion:
        {
            [[RosterManager shareInstance] getFriendInfoByJid:inputJid checkStrange:NO WithCallback:^(FriendInfo *info) {
                temp.extraInfo = info;
                callback(info);
            }];
        }
            break;
        case SessionType_AppMsg:
        {
            
        }
            
            break;
        case SessionType_Error:
        {
            
        }
            
            break;
    }
}


-(void)dealloc
{
     msgObj = nil;
     extraInfo = nil;
     jid = nil ;
     showName = nil;
}
@end
