//
//  LightAppMenuInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LightAppMenuInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation LightAppMenuInfo

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.type = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE];
        self.name = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_NAME];
        self.key = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_KEY];
        self.url = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_URL];
        self.subButton = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:KEY_SUB_BUTTON withClass:[LightAppMenuInfo class]];
        if ([super isNull:self.subButton]) {
            self.subButton = nil;
        }
    }
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
