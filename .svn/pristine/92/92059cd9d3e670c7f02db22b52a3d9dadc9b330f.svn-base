//
//  Entity.m
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Entity.h"
#import "Constants.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "JSONObjectHelper.h"

@implementation Entity

- (ResultInfo*) parseCommandResusltInfo:(id)result
{
    ResultInfo *resultInfo = [[ResultInfo alloc] init];
    resultInfo.succeed = [self parseResultStatus:result];
    resultInfo.errorMsg = [result objectForKey:RESULT_KEY_REASON];
    return resultInfo;
}

-(BOOL) parseResultStatus:(NSDictionary *) jsonObj {
    NSString *status = [jsonObj objectForKey:RESULT_KEY_RESULT];
    if(status == nil || [status isEqualToString:RESULT_STATUS_SUCCESS]) {
        return true;
    }
    return false;
}

- (NSString*) toStringWithClass:(id) obj withClass:(Class) classType
{
    NSMutableString* ret = [[NSMutableString alloc] initWithCapacity:10];
    [ret appendFormat:@"\n类名:%@{", NSStringFromClass(classType)];
#ifdef DEBUG_INFO_DETAIL_
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(classType, &outCount);
    for (int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [obj valueForKey:(NSString *)propertyName];
        //对于属性是集合的处理
        if ([propertyValue isKindOfClass:[NSArray class]] || [propertyValue isKindOfClass:[NSSet class]]) {
            [ret appendString:[self toArrayString:propertyValue]];
        }else{
            //非集合
            if ([propertyValue conformsToProtocol:@protocol(ToStringDelegate)]) {
                id<ToStringDelegate> d = propertyValue;
                if ([d respondsToSelector:@selector(toString)]) {
                    [ret appendFormat:@"\n%@:%@;\n", propertyName, [d toString]];
                }else{
                    [ret appendFormat:@"%@:%@;", propertyName, propertyValue];
                }
            }else{
                [ret appendFormat:@"%@:%@;", propertyName, propertyValue];
            }
        }
    }
    free(properties);
#endif
    [ret appendString:@"}\n"];
    return ret;
}

- (NSString*) toString:(id)obj
{
    if ([obj superclass] != [NSObject class] && [obj superclass] != [Entity class]) {
        NSMutableString* ret = [[NSMutableString alloc] init];
        Class sClass = [obj superclass];
        [ret appendFormat:@"父类：{%@}；\n子类：{%@}", [self toStringWithClass:obj withClass: sClass], [self toStringWithClass:obj withClass:[obj class]]];
        return ret;
    }else{
        return [self toStringWithClass:obj withClass:[obj class]];
    }
}

- (NSString*) toArrayString:(id)array
{
    NSMutableString* ret = [[NSMutableString alloc] initWithCapacity:10];
    [ret appendString:@"\n{\n"];
#ifdef DEBUG_INFO_DETAIL_
    if ([array isKindOfClass:[NSArray class]] || [array isKindOfClass:[NSSet class]]) {
        for (id obj in array) {
            if ([obj respondsToSelector:@selector(toString)]) {
                id<ToStringDelegate> d = obj;
                [ret appendString:[d toString]];
            }else{
                [ret appendString:NSStringFromClass([obj class])];
            }
            [ret appendString:@"\n\n"];
        }
    }
#endif
    [ret appendString:@"}"];
    return ret;
}

- (NSDictionary*) encode
{
    return [self encode:self classType:[Entity class]];
}

- (NSDictionary*) encode:(id)obj classType:(Class)classType
{
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] initWithCapacity:50];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(classType, &outCount);
    for (int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [obj valueForKey:propertyName];
        [ret setValue:propertyValue forKey:propertyName];
    }
    return ret;
}
- (NSDictionary*) try2Dic:(NSString *)str
{
    if ([str hasPrefix:@"\""] && [str hasSuffix:@"\""]) {
        NSString* s = [str substringWithRange:NSMakeRange(1, str.length - 2)];
        return [JSONObjectHelper decodeJSON:s];
    }
    return [JSONObjectHelper decodeJSON:str];
}
- (void) decode:(NSDictionary*) data obj:(id) obj
{
    if ([data isKindOfClass:[NSString class]]) {
        data = [self try2Dic:(NSString*)data];
    }
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    for (int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [self setValue: [data objectForKey:propertyName] forKeyPath:propertyName];
    }
    properties = class_copyPropertyList([obj superclass], &outCount);
    for (int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [self setValue: [data objectForKey:propertyName] forKeyPath:propertyName];
    }
}

- (BOOL) isNull:(id)obj
{
    if ([[NSNull null] isEqual:obj] || !obj) {
        return YES;
    }
    return NO;
}

- (BOOL) merge:(id)dest src :(id)src
{
    if (src && dest) {
        dest = src;
        return YES;
    }
    return NO;
}

@end
