//
//  NoticeInfo.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "NoticeInfo.h"
#import "JSONObjectHelper.h"

#define KEY_TITLE           @"title"
#define KEY_SIGNATURE           @"signature"
#define KEY_PUBLISH_TIME           @"publish_time"
#define KEY_PRIORITY           @"priority"
#define KEY_ID           @"id"
#define KEY_HTML           @"html"
#define KEY_EXPIRED_TIME           @"expired_time"
#define KEY_BODY           @"body"


@implementation NoticeInfo

@synthesize title;
@synthesize signature;
@synthesize publishTime;
//@synthesize priority;
@synthesize noticeId;
@synthesize html;
@synthesize expiredTime;
@synthesize body;

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [self init];
    if(self){
        self.title = [jsonObj objectForKey:KEY_TITLE];
        self.signature = [jsonObj objectForKey:KEY_SIGNATURE];
        self.publishTime = [jsonObj objectForKey:KEY_PUBLISH_TIME];
//        self.priority = [jsonObj objectForKey:KEY_PRIORITY];
        self.noticeId = [jsonObj objectForKey:KEY_ID];
        self.html = [jsonObj objectForKey:KEY_HTML];
        self.expiredTime = [jsonObj objectForKey:KEY_EXPIRED_TIME];
        self.body = [jsonObj objectForKey:KEY_BODY];
        if ([@"" isEqualToString:self.body]) {
            self.body = self.html;
        }
        //[JSONObjectHelper releaseJson:jsonObj];
        jsonObj = nil;
    }
    
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
