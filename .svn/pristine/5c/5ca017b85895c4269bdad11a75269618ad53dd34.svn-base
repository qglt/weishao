//
//  MessageLayoutInfo.h
//  WhistleIm
//
//  Created by wangchao on 13-9-9.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>



#define YOURCLS @"yourcls"
#define TXT @"txt"
#define STYLE @"style"
#define TIMES @"time"
#define STDTIME @"stdtime"

@class MessageText;
@class ChatRecord;
@class FICDPhoto;

typedef enum{
    FROMMSG,FROMIMG,TOMSG,TOIMG//,FROMVOICE,TOVOICE,FROMFILE,TOFILE
}MessageLayoutType;
@interface MessageLayoutInfo : NSObject

@property(nonatomic,assign) MessageLayoutType type;
@property(nonatomic,strong) MessageText *msgObj;
@property(nonatomic,strong) id extraInfo;
@property(nonatomic,strong) NSString *jid;
@property(nonatomic,strong) NSString *time;
@property(nonatomic,strong) NSString *showName;
@property(nonatomic,assign) Boolean send;


+(NSDate *) formatTime:(NSString *)time;

-(id)initWithLayoutType:(MessageLayoutType)layouttype message:(NSString *)msg;

-(id)initWithLayoutType:(MessageLayoutType)layouttype messageText:(MessageText *)msg;

-(void) getFriendInfoByJid:(NSString *)jid withCallback:(void (^)(FriendInfo*))callback;


@end
