//
//  CrowdInfo.h
//  WhistleIm
//
//  Created by liuke on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"
#import "CrowdMember.h"


@interface CrowdInfo : Entity <Jsonable>

@property (strong, nonatomic) NSString* icon;//群图标
@property (nonatomic) BOOL dismiss;//true/false是否可解散
@property (nonatomic) BOOL quit;//true/false是否可退出
@property (nonatomic) BOOL v;//true/false是否加V
@property (nonatomic) NSInteger status;//0-正常，1-冻结
@property (nonatomic) NSInteger alert;//0-接收并提醒；1-接收不提醒；2-不接收
@property (strong, nonatomic) NSString* role;//admin/super/none
@property (nonatomic) BOOL official;//是否官方群
@property (strong, nonatomic) NSString* active;//活跃
@property (strong, nonatomic) NSString* session_id;
@property (nonatomic) NSInteger category;//类别
@property (strong, nonatomic) NSString* remark; // 备注
@property (strong, nonatomic) NSString* name; // 名称
@property (strong, nonatomic) NSString* crowd_no; // 群号

@property (nonatomic) int auth;
//详细信息字段
@property (nonatomic) NSInteger cur_member_size;//群当前人数
@property (nonatomic) NSInteger max_member_size;//群上限人数
@property (nonatomic) NSInteger cur_space_size;
@property (nonatomic, strong) NSString* announce;//群公告
@property (nonatomic, strong) NSString* description;//群描述

@property (weak, nonatomic) NSMutableArray* members;//群成员

- (BOOL) isNormal;//是否正常
- (BOOL) isFrozen;//是否冻结
- (BOOL) isAdmin;//是否管理员
- (BOOL) isSuper;//是否超级管理员
- (BOOL) isAllowJoin;
- (BOOL) isActive;
- (BOOL) isVoiceAlert;

- (void) removeCrowdMemberByJID:(NSString*) jid;

- (CrowdMember*) getCrowdMember:(NSString*) jid;
/**
 *  群资料中是否包含详细信息
 *
 *  @return 
 */
- (BOOL) isHasDetailInfo;

- (CrowdInfo*) getUnionSetByCrowdInfo:(CrowdInfo*) crowdinfo;

- (UIImage* ) getCrowdIcon;

- (NSString*) getCrowdID;
//修改群成员的头像，修改成功后返回YES
- (BOOL) changeHead:(NSString*) jid head:(NSString*) head;

@end
