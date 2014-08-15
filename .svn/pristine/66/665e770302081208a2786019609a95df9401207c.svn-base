//
//  WebAppInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "WebAppInfo.h"

@implementation WebAppInfo


- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super initFromJsonObject:jsonObj];
    if (self) {
        [self decodeData:jsonObj];
    }
    return self;
}

- (void) decodeData:(NSDictionary*) data
{
    
}

- (void) appendDetailInfo:(NSDictionary *)data
{
    [super appendDetailInfo:data];
    [self decodeData:data];
}

- (NSDictionary*) encode
{
    ENCODE(WebAppInfo);
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
