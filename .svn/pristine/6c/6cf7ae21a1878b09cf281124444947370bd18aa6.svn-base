//
//  DiscussionMemberInfo.m
//  WhistleIm
//
//  Created by liuke on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "DiscussionMemberInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation DiscussionMemberInfo

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_JID];
        self.showName = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SHOWNAME];
        self.presence = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_presence];
        self.head = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_HEAD];
        self.sex = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_sex];
        self.identity = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_identity];
        self.photoCredential = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_PHOTO_CREDENTIAL];
    }
    return self;
}

- (BOOL) isOnline
{
    return [KEY_ONLINE isEqualToString:self.presence];
}

- (BOOL) mergeInfo:(DiscussionMemberInfo *)info
{
    if ([self.jid isEqualToString:info.jid]) {
//        [super merge:self.showName src:info.showName];
//        [super merge:self.presence src:info.presence];
//        [super merge:self.head src:info.head];
//        [super merge:self.sex src:info.sex];
//        [super merge:self.identity src:info.identity];
//        [super merge:self.photoCredential src:info.photoCredential];
        return YES;
    }
    return NO;
}

@end
