//
//  JSONObjectHelper.m
//  Whistle
//
//  Created by chao.wang on 13-1-16.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "JSONObjectHelper.h"
#import "SBJson.h"
#import "Jsonable.h"


static SBJsonParser *mJSONDecoder;
static SBJsonWriter *mJSONEncoder;

@implementation JSONObjectHelper

+ (void)putObject:(id)object withKey:(NSString *)key toJSONObject:(NSMutableDictionary *)jsonObj {
    if (object==nil || key==nil || jsonObj==nil) {
        return;
    }
    [jsonObj setObject:object forKey:key];
}


+ (NSString *)encodeStringFromJSON:(id)json {
    return [JSONObjectHelper encodeStringFromJSON:json error:nil];
}

+ (NSString *)encodeStringFromJSON:(id)json error:(NSError *__autoreleasing *)error {
    if(mJSONEncoder == nil) {
        mJSONEncoder = [[SBJsonWriter alloc] init];
    }
    if (json == nil) {
        *error = [NSError errorWithDomain:@"data is nil!" code:0 userInfo:nil];
        return  nil;
    }
    return [mJSONEncoder stringWithObject:json];
}

+ (id)decodeJSON:(NSString *)jsonStr {
    return [JSONObjectHelper decodeJSON:jsonStr error:nil];
}

+ (id)decodeJSON:(NSString *)jsonStr error:(NSError *__autoreleasing *)error {
    @autoreleasepool {
    
    if(mJSONDecoder == nil) {
        mJSONDecoder = [[SBJsonParser alloc] init];
    }
    if (jsonStr == nil) {
        *error = [NSError errorWithDomain:@"json string is nil!" code:0 userInfo:nil];
        return nil;
    }
    return [mJSONDecoder objectWithString:jsonStr error:error];
    }
}

+ (NSString *)getStringFromJSONObject: (NSDictionary *)jsonObj forKey : (NSString *)key
{
    if(jsonObj == nil || key == nil) {
        return nil;
    }
    
    id value = [jsonObj objectForKey:key];
    
    if(value != nil){
        if(value == [NSNull null]){
            return nil;
        }
        return value;
    }
    
    return nil;
}

+ (NSArray *)getObjectArrayFromJSONArray:(NSArray *)jsonArr withClass:(__unsafe_unretained Class)c {
    @autoreleasepool {
        
    
    if (jsonArr==nil || (id)jsonArr == [NSNull null] || (id)c == [NSNull null] || c==nil) {
        c = nil;
        return nil;
    }
    if (![c conformsToProtocol:@protocol(Jsonable)]) {
        [NSException raise:@"getObjectArrayFromJSONArray class is not kind of Jsonable!" format:nil];
    }

    NSMutableArray *objArr = [NSMutableArray arrayWithCapacity:jsonArr.count];
    for (NSDictionary *tempJson in jsonArr) {
        if (tempJson == nil) {
            continue;
        }
        
        id obj = [[c alloc] initFromJsonObject:tempJson];
        if (obj) {
            [objArr addObject:obj];
        }
        obj = nil;

    }
    c = nil;
    return objArr;
    }
}

+(id)getObjectArrayFromJsonObject:(NSDictionary *)object forKey:(NSString *)key withClass:(__unsafe_unretained Class)c
{
    if (![c conformsToProtocol:@protocol(Jsonable)]) {
        [NSException raise:@"getObjectArrayFromJsonObject class is not kind of Jsonable!" format:nil];
    }

    //NSMutableArray *objArr = [[NSMutableArray alloc] init];
    
    id obj = [object objectForKey:key];
    
    if (obj == [NSNull null] || obj == nil) {
        c = nil;
        obj = [NSNull null];
        return obj;
    }
    
    if( ![obj isKindOfClass:[NSArray class]]){
        NSLog(@"invalid json object for getObjectArrayFromJsonObject !");
        NSLog(@"obj real class is %@",obj);
        c = nil;
        return [NSNull null];
    }
    
    
    return [JSONObjectHelper getObjectArrayFromJSONArray:obj withClass:c];
    
}

+ (id)getObjectFromJSON:(NSDictionary *)jsonDic withClass:(__unsafe_unretained Class)c {
    @autoreleasepool {
        
    
    if (jsonDic==nil || (id)jsonDic == [NSNull null] || (id)c == [NSNull null] || c==nil) {
        c = nil;
        return nil;
    }
    NSMutableDictionary *objDic = [NSMutableDictionary dictionaryWithDictionary:jsonDic];
    id obj = [[c alloc] initFromJsonObject:objDic];
    c = nil;
    return obj;
    }
}

+(int)getIntFromJSONObject:(NSDictionary *)jsonObj forKey:(NSString *)key defaultValue:(int)defaultVal
{
    if (jsonObj==nil || (id)jsonObj == [NSNull null]) {
        return defaultVal;
    }
    
    id value = [jsonObj objectForKey:key];
    
    if(value != nil){
        if(value == [NSNull null]){
            return defaultVal;
        }
        return [(NSNumber *)value intValue];
    }
    
    return defaultVal;

}

+(void)mergeJSONObject:(NSDictionary *)oldJson from:(NSDictionary *)newJson
{
    if(newJson ==nil)
    {
        return;
    }
    
    NSArray *keyArray =  newJson.allKeys;
    
    for (NSString *key in keyArray) {
        NSObject *obj = [newJson objectForKey:key];
        if(obj == [NSNull null])
        {
            continue;
        }
        [oldJson setValue:obj forKey:key];
    }
    
}

+ (NSDictionary *) getJSONFromJSON:(NSDictionary *)jsonObj forKey:(NSString *)key
{
    if (jsonObj) {
        NSDictionary* ret = [jsonObj objectForKey:key];
        if ([ret isKindOfClass:[NSDictionary class]]) {
            return ret;
        }else if([ret isKindOfClass:[NSString class]]){
            return [self decodeJSON:[jsonObj objectForKey:key]];
        }

    }
    return nil;
}

+ (void)releaseJson:(id)json
{
    
    return;
    
    /*
    @autoreleasepool {
        
    
    if([json isKindOfClass: [NSMutableDictionary class]]){
        NSMutableDictionary *rjson = json;
        NSEnumerator *it =  [rjson keyEnumerator];
        NSString *key = [it nextObject];
        id value = nil;
        while(key != nil){
            value = [rjson objectForKey:key];
            [JSONObjectHelper releaseJson:value];
            key = [it nextObject];
        }
        [rjson removeAllObjects];
        
    }
    
    if([json isKindOfClass: [NSMutableArray class]]){
        NSMutableArray *rjson = json;
        
        for (id value in rjson) {
            [JSONObjectHelper releaseJson:value];
        }
        [rjson removeAllObjects];
    }
    }
     */
    
}

@end

