//
//  FriendGroup.h
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "FriendInfo.h"
#import "Entity.h"

@interface FriendGroup : Entity <Jsonable> {
}
@property (copy, nonatomic) NSString *rid;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) int onlineCount;
@property (assign, nonatomic) int totalCount;
@property (strong, nonatomic) NSMutableArray *friends;
@property (assign, nonatomic) Boolean canbeDeleted;
@property (assign) Boolean canbeRenamed;

//根据给的好友信息的presence来刷新当前在线人数，返回最新的在线人数,可以根据返回值和原来值进行判断是否在当前组中
- (void) refrashOnlineAndSort;
- (BOOL) isExist:(FriendInfo*) friendInfo;
- (FriendInfo*) getFriendInfo:(NSString*) jid;
- (void) sortByOnline;
- (void) clear;
- (BOOL) removeFriendByJid:(NSString*) jid;

@end
