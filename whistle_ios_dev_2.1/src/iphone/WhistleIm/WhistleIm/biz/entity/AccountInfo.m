//
//  AccountInfo.m
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "AccountInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"


@implementation AccountInfo


- (id)initFromJsonObject:(NSDictionary *)jsonObject
{

    if(self = [super init])
    {
        if(jsonObject != nil)
        {
            self.userName = [jsonObject objectForKey:KEY_USER_NAME];
            self.password = [jsonObject objectForKey:KEY_USER_PASSWD];
            self.lastLoginStatus = [jsonObject objectForKey:KEY_LAST_LOGIN_STATUS];
            id tempObj = [jsonObject objectForKey:KEY_AUTO_LOGIN];
            if (tempObj && [tempObj isKindOfClass:[NSNumber class]])
            {
                self.autoLogin = ((NSNumber *)tempObj).intValue != 0;
            }
            else
            {
                self.autoLogin = NO;
            }
            tempObj = [jsonObject objectForKey:KEY_SAVE_PASSWD];
            if (tempObj && [tempObj isKindOfClass:[NSNumber class]])
            {
                self.savePasswd = ((NSNumber *)tempObj).intValue != 0;
            }
            else
            {
                self.savePasswd = NO;
            }
            self.headImg = [jsonObject objectForKey:KEY_HEAD_IMG];
            if (!(self.headImg) || [@"" isEqualToString: self.headImg]) {
                self.headImg = @"identity_man_new.png";
            }
            NSLog(@"headImg:%@", self.headImg);
            //[JSONObjectHelper releaseJson:jsonObject];
            jsonObject = nil;
        }
        else
        {
            self.userName = nil;
            self.password = nil;
            self.autoLogin = NO;
            self.savePasswd = NO;
            self.headImg = nil;
        }
        
    }
    return self;
}

- (void) setOnlineLogin
{
    self.lastLoginStatus = PRESENCE_ONLINE;
}

- (void) setOfflineLogin
{
    self.lastLoginStatus = PRESENCE_INVISIBLE;
}

- (BOOL) isInvisibleLogin
{
    return [PRESENCE_INVISIBLE isEqualToString:self.lastLoginStatus];
}

- (void)reset
{
    self.userName = nil;
    self.password = nil;
    self.autoLogin = NO;
    self.savePasswd = NO;
    self.headImg = nil;
}

- (BOOL)isUserNameValid
{
    if (!(self.userName) || [[self.userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)isPasswordValid
{
    return YES;
}

- (NSString*) toString
{
    return [super toString:self];
}


@end
