//
//  SystemMessageInfo.h
//  WhistleIm
//
//  Created by wangchao on 13-8-14.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Whistle.h"
#import "Constants.h"
#import "Entity.h"



@interface SystemMessageInfo : Entity <Jsonable>

@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *msgType;
@property (nonatomic,strong) NSString *serverTime;
@property (nonatomic,strong) NSString *extraInfo;
@property (nonatomic,strong) NSString *jid;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *rowId;
@property (nonatomic,strong) NSString *info;
@property (nonatomic,strong) NSString *lastTime;
@property (assign) BOOL isRead;
//新增属性，用于解析群的相关数据
@property (nonatomic,strong) NSString *actor_name;
@property (nonatomic,strong) NSString *actor_jid;
@property (nonatomic, strong) NSString* actor_sex;
@property (nonatomic, strong) NSString* actor_identity;
@property (nonatomic,strong) NSString *name;//被操作人的名字
@property (nonatomic,strong) NSString *name_jid;//被操作人的jid
@property (nonatomic,strong) NSString *crowd_name;
@property (nonatomic) NSInteger category;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *txt;
@property (nonatomic,strong) NSString *result;
@property (nonatomic,strong) NSString *reason;
@property (nonatomic,strong) NSString *remark;

@property (nonatomic) BOOL isAgree;//这个用来区别“你已经同意或者拒绝别人的邀请，但显示的还是别人邀请的文字”问题
//额外信息，如果是群系统消息，则为CrowdInfo;如果是好友的系统消息，则是friendInfo
@property (nonatomic, strong) id extraObject;
@property (nonatomic) BOOL crowdHasDismiss;

- (NSDictionary*) getCrowdContent;

- (BOOL) isInviteOrAuthen;

- (NSString*) getShowTxt;

- (BOOL) isCrowdSystemMsg;

- (BOOL) isFriendSystemMsg;

- (BOOL) isAnswer;

- (void) answerInviteByCrowd:(BOOL)isAccpt WithCallback:(void(^)(BOOL))callback;

- (void) answerApplyJonCrowd:(BOOL) isApply withCallback:(void(^)(BOOL))callback;
@end
