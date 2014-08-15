//
//  AppMsgInfo.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AppMsgInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"


@implementation AppMsgInfo

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    if (self = [super init]) {
        self.sendTime = [jsonObj valueForKey:KEY_SEND_TIME];
        NSDictionary *msgJson = [jsonObj valueForKey:KEY_MSG];
        self.body = [msgJson valueForKey:KEY_BODY];
        self.html = [msgJson valueForKey:KEY_HTML];
        self.hyperlink = [msgJson valueForKey:KEY_HYPERLINK];
        self.msgId = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_MESSAGE_ID defaultValue:0];
        if ([@"" isEqualToString: self.body]){
            self.showText = self.html;
        }else{
            self.showText = self.body;
        }
        jsonObj = nil;
    }
    
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
