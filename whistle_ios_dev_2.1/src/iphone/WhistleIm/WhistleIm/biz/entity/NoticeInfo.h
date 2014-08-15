//
//  NoticeInfo.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"


@interface NoticeInfo : Entity <Jsonable>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *publishTime;
//@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *noticeId;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, copy) NSString *expiredTime;
@property (nonatomic, copy) NSString *body;


@end
