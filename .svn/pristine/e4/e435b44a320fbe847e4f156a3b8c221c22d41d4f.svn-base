//
//  ChatGroupInfo.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

static NSString *KEY_SESSION_ID = @"session_id";
static NSString *KEY_GROUP_NAME = @"group_name";


#import "ChatGroupInfo.h"
#import "JSONObjectHelper.h"
#import "FriendInfo.h"

@implementation ChatGroupInfo

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [self init];
    
    if(self){
        self.sessionId = [jsonObj objectForKey:KEY_SESSION_ID];//[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SESSION_ID];
        self.groupName = [jsonObj objectForKey:KEY_GROUP_NAME];//[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_GROUP_NAME];
        //[JSONObjectHelper releaseJson:jsonObj];
        jsonObj = nil;
    }
    
    return self;
}

- (DiscussionMemberInfo*) getMember:(NSString *)jid
{
    if (!(self.members)) {
        return nil;
    }
    for (DiscussionMemberInfo* f in self.members) {
        if ([f.jid isEqualToString:jid]) {
            return f;
        }
    }
    return nil;
}

- (void) removeDiscussionMemberByJID:(NSString *)jid
{
    if (self.members) {
        for (DiscussionMemberInfo* m in self.members) {
            if ([m.jid isEqualToString:jid]) {
                [self.members removeObject:m];
                break;
            }
        }
    }
}

- (BOOL) mergeMemberInfo:(DiscussionMemberInfo *)info
{
    if (self.members) {
        for (DiscussionMemberInfo* m in self.members) {
            if ([m mergeInfo:info]) {
                return YES;
            }
        }
        return NO;
    }
    return NO;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
