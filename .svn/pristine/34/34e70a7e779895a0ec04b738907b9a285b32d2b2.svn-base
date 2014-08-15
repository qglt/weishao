//
//  ChatGroupInfo.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"
#import "DiscussionMemberInfo.h"

@interface ChatGroupInfo : Entity<Jsonable>

@property (strong, nonatomic) NSString* sessionId;

@property (strong, nonatomic) NSString* groupName;

@property (strong, nonatomic) NSMutableArray* members;


- (DiscussionMemberInfo*) getMember:(NSString*) jid;

- (void) removeDiscussionMemberByJID:(NSString*) jid;

- (BOOL) mergeMemberInfo:(DiscussionMemberInfo*) info;
@end
