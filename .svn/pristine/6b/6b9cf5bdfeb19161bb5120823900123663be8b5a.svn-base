//
//  AccountInfo.h
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"

@interface AccountInfo : Entity <Jsonable> {

}

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *headImg;
@property (nonatomic) BOOL savePasswd;
@property (nonatomic) BOOL autoLogin;
@property (nonatomic, strong) NSString *lastLoginStatus;

- (void) setOnlineLogin;
- (void) setOfflineLogin;

- (BOOL) isInvisibleLogin;

- (BOOL) isUserNameValid;
- (BOOL) isPasswordValid;
- (void) reset;
@end
