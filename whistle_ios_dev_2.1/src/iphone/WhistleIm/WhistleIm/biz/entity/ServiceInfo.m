//
//  ServiceInfo.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "ServiceInfo.h"
#import "JSONObjectHelper.h"

#define KEY_NAME    @"name"
#define KEY_ICON    @"icon"
#define KEY_ID      @"id"

@implementation ServiceInfo

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if(self){
        self.jsonObj = jsonObj;
        self.name = [jsonObj valueForKey:KEY_NAME];
        self.icon = [jsonObj valueForKey:KEY_ICON];
        self.id = [jsonObj valueForKey:KEY_ID];
        //[JSONObjectHelper releaseJson:jsonObj];
        jsonObj = nil;
    }
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
