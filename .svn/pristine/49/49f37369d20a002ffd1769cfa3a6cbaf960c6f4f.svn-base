//
//  RecentRecord.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"

#define kUPDATECURRENT @"update"
#define kEMPTY @"empty"
#define kNEW @"new"
#define kMARKREAD @"markRead"
#define kDELETE @"delete"

typedef enum RecentContactUpdateType {
    RecentContactUpdateType_UPDATECURRENT = 1,
    RecentContactUpdateType_EMPTY = 2,
    RecentContactUpdateType_NEW = 3,
    RecentContactUpdateType_MARKREAD = 4,
    RecentContactUpdateType_DELETE = 5,
} RecentContactUpdateType;

enum RecentRecordType {
    RecentRecord_Crowd,
    RecentRecord_Discussion,
    RecentRecord_Conversation,
    RecentRecord_Notice,
    RecentRecord_AppMsg,
    RecentRecord_System,
    RecentRecord_LightApp,
    RecentRecord_Error
    };

@class ActivateUnitInfo;
@interface RecentRecord : Entity<Jsonable>{
    NSString* time;
    
    int unreadAccount;
    
    NSString* type;
    
    NSString* speaker;
    
    NSDictionary* msgContent;
    
    NSString* jid;
    
}



@property (nonatomic, strong) NSString* time;

@property (nonatomic, assign)  int unreadAccount;

@property (nonatomic, strong) NSString* type;

@property (nonatomic, strong) NSString* speaker;

@property (nonatomic, strong) NSDictionary* msgContent;

@property (nonatomic, strong) NSString* jid;

@property (nonatomic, strong) NSString* speakerID;

@property (nonatomic) BOOL isSend;

@property (nonatomic, strong) id extraInfo;//额外信息，如果是聊天的话，这个对象为好友信息；lightapp的话，则是LightAppMessageInfo;系统消息的话，则是SystemMessageInfo;是群或者讨论组的话，则是CrowdInfo或者DiscussionInfo

@property (nonatomic,assign) RecentContactUpdateType updateType;

@property (nonatomic) BOOL isMyDevice;

@property (nonatomic,copy) NSDictionary *cacheJsonObj;

-(void)reset:(NSDictionary *)jsonObj;

-(RecentContactUpdateType) parseRecnetContactUpdateType:(NSDictionary *)jsonObj;

//得到发送人信息和聊天记录的文本格式信息，表情使用表情名，图片使用[图片]。用于app在后台时的本地提醒
//- (void) getNoticeTextMsg:(void(^)(NSString*,NSString*)) callback;

+(NSString *) getRecnetContactUpdateTypeString:(RecentContactUpdateType) type;

-(void)clear;

- (enum RecentRecordType) getType;
@end
