//
//  CacheManager.h
//  WhistleIm
//
//  Created by liuke on 14-2-27.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manager.h"

@protocol CacheDelegate <NSObject>

@optional

- (void) serialization;
- (void) unserialization:(NSDictionary*) data;

@end

@interface CacheManager : Manager

SINGLETON_DEFINE(CacheManager)

- (void) serialization;//写入数据

- (void) unserialization:(NSString*) userName;//读取数据

+ (BOOL) serialization:(NSString*) type array:(NSArray*) array;

+ (BOOL) save;

@end
