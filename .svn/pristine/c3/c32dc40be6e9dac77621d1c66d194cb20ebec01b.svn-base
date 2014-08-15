//
//  Roster.h
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"

@class FriendInfo;
@class FriendGroup;
@interface Roster : Entity <Jsonable> {
}

@property (nonatomic, strong) FriendInfo *myInitInfo;
@property (nonatomic, strong) NSMutableArray * groupList;

-(BOOL)groupExists:(NSString *)groupName;
-(FriendGroup *)getGroup:(NSString *)groupName;
-(void)addFriend:(FriendInfo *)newFriend;
-(FriendInfo*) getFriendInfo:(NSString*)jid;
- (void) sortByOnline;
- (void) clear;
- (void) removeFriend:(NSString*) jid;
@end
