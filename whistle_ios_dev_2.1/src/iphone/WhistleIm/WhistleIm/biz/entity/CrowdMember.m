//
//  CrowdMemberInfo.m
//  WhistleIm
//
//  Created by liuke on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdMember.h"
#import "Constants.h"
#import "JSONObjectHelper.h"

@implementation CrowdMember

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_JID];
        self.showName = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SHOWNAME];
        self.status = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_STATUS];
        self.head = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_HEAD];
        self.sex = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SEX_SHOW];
        self.identity = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_identity_show];
        self.role = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ROLE];
    }
    return self;
}

- (BOOL) isBoy
{
    return YES;
}

- (BOOL) isAdmin
{
    return [KEY_ADMIN isEqualToString:self.role];
}

- (BOOL) isSuper
{
    return [KEY_SUPER isEqualToString:self.role];
}

- (BOOL) isNone
{
    return [KEY_NONE isEqualToString:self.role];
}

- (BOOL) isOnline
{
    return [KEY_ONLINE isEqualToString:self.status];
}

@end
