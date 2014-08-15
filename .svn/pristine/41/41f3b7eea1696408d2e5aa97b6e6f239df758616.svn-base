//
//  RecentAppMessageInfo.h
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "AppMsgInfo.h"
#import "ServiceInfo.h"
#import "Entity.h"

@interface RecentAppMessageInfo : Entity <Jsonable>
{
    int unreadCount;
    int countAll;
    AppMsgInfo *message;
    ServiceInfo *serviceInfo;
}
@property (nonatomic, assign) int unreadCount;
@property (nonatomic, assign) int countAll;
@property (nonatomic, strong) AppMsgInfo *message;
@property (nonatomic, strong) ServiceInfo *serviceInfo;
@property (nonatomic, strong) NSString* msgid;
@property (nonatomic, strong) NSString* sendTime;
@property (nonatomic) BOOL isRead;

//暂时放在这里
-(void)markReadWithCallback:(void(^)(BOOL)) callback;

@end
