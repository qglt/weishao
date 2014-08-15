//
//  RemoteConfigInfo.m
//  WhistleIm
//
//  Created by liuke on 13-12-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "RemoteConfigInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"



@implementation RemoteConfigInfo

@synthesize isRecommand = _isRecommand;

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.name = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_NAME];
        self.domain = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DOMAIN];
        self.pinyin = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_PINYIN];
        NSDictionary* config = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_CONFIG];
        if (!config || [[NSNull null] isEqual:config]) {
            _isRecommand = NO;
        }else{
            _isRecommand = YES;
        }
    }
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
