//
//  Message.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject


@property (nonatomic, copy) NSString* yourcls;
@property (nonatomic, strong) NSDate* time;
@property (nonatomic, copy) NSString* style;


@end
