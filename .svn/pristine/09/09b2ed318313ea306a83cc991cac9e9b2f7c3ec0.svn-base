//
//  JSONObjectHelper.h
//  Whistle
//
//  Created by chao.wang on 13-1-16.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface JSONObjectHelper : NSObject

+ (NSString *)encodeStringFromJSON:(id)json;
+ (NSString *)encodeStringFromJSON:(id)json error:(NSError **)error;

+ (id)decodeJSON:(NSString *)jsonStr;
+ (id)decodeJSON:(NSString *)jsonStr error:(NSError **)error;

+ (void)putObject:(id)object withKey:(NSString *)key toJSONObject:(NSMutableDictionary *)jsonObj;

+ (NSString *)getStringFromJSONObject:(NSDictionary *)jsonObj forKey:(NSString *)key;

+ (NSArray *)getObjectArrayFromJSONArray:(NSArray *)jsonArr withClass:(Class)c;

+ (id)getObjectFromJSON:(NSDictionary *)jsonDic withClass:(__unsafe_unretained Class)c;

+ (int)getIntFromJSONObject:(NSDictionary *)jsonObj forKey:(NSString *)key defaultValue:(int)defaultVal;

+ (id)getObjectArrayFromJsonObject:(NSDictionary *)object forKey:(NSString *)key withClass:(__unsafe_unretained Class)c;

+ (void) mergeJSONObject:(NSDictionary *)oldJson from:(NSDictionary *)newJson;

+ (NSDictionary *) getJSONFromJSON: (NSDictionary *) jsonObj forKey: (NSString *) key;

//+ (void)releaseJson:(id)json;

@end
