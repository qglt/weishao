//
//  CrowdMemberInfo.h
//  WhistleIm
//
//  Created by liuke on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"

@interface CrowdMember : Entity<Jsonable>

@property (nonatomic, strong) NSString* jid;
@property (nonatomic, strong) NSString* showName;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* head;
@property (nonatomic, strong) NSString* sex;
@property (nonatomic, strong) NSString* identity;
@property (nonatomic, strong) NSString* role;

//额外信息，friendInfo
@property (nonatomic, weak) id friendInfo;


/**
 *  是否性别男
 *
 *  @return
 */
- (BOOL) isBoy;
/**
 *  是否管理员
 *
 *  @return
 */
- (BOOL) isAdmin;
/**
 *  是否超级管理员
 *
 *  @return
 */
- (BOOL) isSuper;
/**
 *  是否普通成员
 *
 *  @return
 */
- (BOOL) isNone;
/**
 *  是否在线
 *
 *  @return 
 */
- (BOOL) isOnline;

@end
