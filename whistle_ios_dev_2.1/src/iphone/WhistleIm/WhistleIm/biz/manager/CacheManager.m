//
//  CacheManager.m
//  WhistleIm
//
//  Created by liuke on 14-2-27.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CacheManager.h"
#import "Entity.h"
#import "JSONObjectHelper.h"
#import "AccountManager.h"
#import "AccountInfo.h"

#define FILE_PATH @"app_cache/info"

static NSMutableDictionary* cache = nil;



@implementation CacheManager

SINGLETON_IMPLEMENT(CacheManager)

//将每种manager生成一个字典
+ (NSArray*) get:(NSArray*) array
{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (Entity* entity in array) {
        NSString* str = [JSONObjectHelper encodeStringFromJSON:[entity encode]];
        [arr addObject: str];
    }
    return arr;
}

+ (BOOL) serialization:(NSString*) type array:(NSArray*) array
{
    if (!cache) {
        cache = [[NSMutableDictionary alloc] init];
    }
    [cache setObject:[CacheManager get:array] forKey:type];
    return YES;
}

+ (BOOL) save
{
    if (cache) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* path = [NSString stringWithFormat:@"%@/%@", [AccountManager shareInstance].mainFolder, FILE_PATH];
        if(![fileManager fileExistsAtPath:path]){
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString* file = [path stringByAppendingPathComponent:[AccountManager shareInstance].currentAccount.userName];
        
//        NSString* str = [JSONObjectHelper encodeStringFromJSON:cache];
//        [str writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
//        [cache writeToFile:file atomically:YES];
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:file append:NO];
        [outputStream open];
        [NSJSONSerialization writeJSONObject:cache toStream:outputStream options:0 error:nil];
        [outputStream close];
        return YES;
    }else{
        return NO;
    }
}

+ (NSDictionary*) getCache:(NSString*) user
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* path = [NSString stringWithFormat:@"%@/%@", [AccountManager shareInstance].mainFolder, FILE_PATH];
    if(![fileManager fileExistsAtPath:path]){
        return nil;
    }
    NSString* file = [path stringByAppendingPathComponent:user];
    NSString* str = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    if (!str) {
        return nil;
    }
//    str = [str stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
//    str = [str stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    NSData* jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* ret = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
//    NSDictionary* ret = [JSONObjectHelper decodeJSON:str];
    if (!ret || [[NSNull null] isEqual:ret]) {
        return nil;
    }
    return ret;
}

- (void) unserialization:(NSString*) userName
{
    NSDictionary* dic = [CacheManager getCache:userName];
    for (id<CacheDelegate> d in [super getListenerSet:@protocol(CacheDelegate)]) {
        if ([d respondsToSelector:@selector(unserialization:)]) {
            [d unserialization:dic];
        }
    }
}

- (void) serialization
{
    for (id<CacheDelegate> d in [super getListenerSet:@protocol(CacheDelegate)]) {
        if ([d respondsToSelector:@selector(serialization)]) {
            [d serialization];
        }
    }
    [CacheManager save];
}

@end
