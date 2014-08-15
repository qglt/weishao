//
//  LightAppInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LightAppInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation LightAppInfo




- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super initFromJsonObject:jsonObj];
    if (self) {
        self.appid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_ID];
        id m = [jsonObj valueForKey:KEY_MENU];
        if (m) {
            if ([m isKindOfClass:[NSString class]]) {
                NSDictionary* tmp = [JSONObjectHelper decodeJSON:m];
                NSArray* menus = [JSONObjectHelper getObjectArrayFromJsonObject:tmp forKey:KEY_BUTTON withClass:[LightAppMenuInfo class]];
                if ([super isNull:menus]) {
                    self.menus = nil;
                }else{
                    self.menus = menus;
                }
            }else{
                self.menus = [JSONObjectHelper getObjectArrayFromJsonObject:m forKey:KEY_BUTTON withClass:[LightAppMenuInfo class]];
                if ([super isNull:self.menus]) {
                    self.menus = nil;
                }
            }
        }

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
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tmp addEntriesFromDictionary:[super encode]];
    [tmp addEntriesFromDictionary:[self encode:self classType:[LightAppInfo class]]];
    return tmp;
}

//- (void) decode
//{
//
//}

- (NSString*) toString
{
    return [super toString:self];
}

@end
