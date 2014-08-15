//
//  ChatRecord.m
//  Whistle
//
//  Created by chao.wang on 13-1-16.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "ChatRecord.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation ChatRecord

- (id)initFromJsonObject:(NSDictionary *)jsonObj {
    if (self = [super init]) {
        self.rowId = [jsonObj objectForKey:KEY_ROW_ID];
        self.jid = [jsonObj objectForKey:KEY_JID];
        id tempObj = [jsonObj objectForKey:KEY_IS_SEND];
        if (tempObj) {
            self.isSend = ((NSNumber *)tempObj).intValue != 0;
        }
        else {
            self.isSend = NO;
        }
        self.msg = [jsonObj objectForKey:KEY_MSG];
        self.datatime = [jsonObj objectForKey:KEY_DATETIME];
        if (self.datatime == nil) {
            self.datatime = [jsonObj objectForKey:KEY_DT];
        }
        
        self.speaker = [jsonObj objectForKey:KEY_SPEAKER];
        self.type = [jsonObj objectForKey:KEY_TYPE];
        self.priority = [jsonObj objectForKey:KEY_PRIORITY];
        self.showName = [jsonObj objectForKey:KEY_SHOW_NAME];
        tempObj = [jsonObj objectForKey:KEY_IS_READ];
        if (tempObj && [tempObj isKindOfClass:[NSNumber class]]) {
            self.isRead = ((NSNumber *)tempObj).intValue != 0;
        }
        else {
            self.isRead = NO;
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
