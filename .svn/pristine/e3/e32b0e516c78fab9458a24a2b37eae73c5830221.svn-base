//
//  DiscussionMemberInfo.h
//  WhistleIm
//
//  Created by liuke on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"
#import "FriendInfo.h"

@interface DiscussionMemberInfo : Entity<Jsonable>

@property (nonatomic, strong) NSString* jid;
@property (nonatomic, strong) NSString* showName;
@property (nonatomic, strong) NSString* presence;//online/offline
@property (nonatomic, strong) NSString* head;
@property (nonatomic, strong) NSString* identity;
@property (nonatomic, strong) NSString* photoCredential;
@property (nonatomic, strong) NSString* sex;

@property (nonatomic, weak) FriendInfo* info;

- (BOOL) isOnline;

- (BOOL) mergeInfo:(DiscussionMemberInfo*) info;

@end
