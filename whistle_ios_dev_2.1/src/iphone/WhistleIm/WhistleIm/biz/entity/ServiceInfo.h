//
//  ServiceInfo.h
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"

@interface ServiceInfo : Entity<Jsonable>

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSDictionary *jsonObj;

@end
