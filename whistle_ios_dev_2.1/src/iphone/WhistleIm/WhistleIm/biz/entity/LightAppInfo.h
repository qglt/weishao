//
//  LightAppInfo.h
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"
#import "BaseAppInfo.h"
#import "LightAppMenuInfo.h"
/**
 *  轻应用的实体类，类似微信聊天窗口
 */
@interface LightAppInfo : BaseAppInfo

@property (nonatomic, strong) NSArray* menus;
@property (nonatomic, strong) NSString* appid;

//- (void) decode;

@end
