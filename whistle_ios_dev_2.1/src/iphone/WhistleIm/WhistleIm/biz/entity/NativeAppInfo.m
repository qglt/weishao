//
//  NativeAppInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "NativeAppInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation NativeAppInfo

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super initFromJsonObject:jsonObj];
    if (self) {
        [self decodeData:jsonObj];
    }
    return self;
}

- (void) appendBaseAppInfo:(BaseAppInfo *)app
{
    
}

- (void) decodeData:(NSDictionary*) data
{
    NSDictionary* custom = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_CUSTOM_INFO];
    self.version = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_VERSION];
    self.redirect = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_REDIRECT];
    self.templates = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_TEMPLATE];
    self.identifier = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_IDENTIFIER];
    self.packageName = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_PACKAGE_NAME];
    self.package = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_PACKAGE];
    self.packageSize = [JSONObjectHelper getStringFromJSONObject:custom forKey:KEY_PACKAGESIZE];
}

- (void) appendDetailInfo:(NSDictionary *)data
{
    [super appendDetailInfo:data];
    [self decodeData:data];
}
- (NSDictionary*) encode
{
    ENCODE(NativeAppInfo)
}
- (NSString*) toString
{
    return [super toString:self];
}

@end
