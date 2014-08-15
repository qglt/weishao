//
//  Manager.m
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Manager.h"
#import "Constants.h"
#import "WeakReferenceObject.h"
#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"

static dispatch_queue_t queue = nil;
static NSString *FILE_NAME_ANT_CONFIG = @"antconfig.json";
static NSString *FILE_NAME_APPCONFIG = @"appconfig.dat";

static BOOL isReset_ = YES;

static NSString* mainFolder_;

@interface Manager()
{
    NSMutableSet* listenerSet_;
}

@end

@implementation Manager

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

- (BOOL) isNull:(id)ref
{
    return !ref || [[NSNull null] isEqual:ref];
}

- (BOOL) isExist:(id) listener
{
    for (WeakReferenceObject* w in listenerSet_) {
        if ([w.baseObject isEqual: listener]) {
            return YES;
        }
    }
    return NO;
}

- (void) addListener:(id)listener
{
    if (!listenerSet_) {
        listenerSet_ = [[NSMutableSet alloc] initWithCapacity:2];
    }
    if ([listenerSet_ count] > 5) {
        [self clearUnRefObject];
    }
    if (![self isExist:listener]) {
        [listenerSet_ addObject:[WeakReferenceObject weakReferenceObjectWithObject:listener]];
    }
}

- (void) clearUnRefObject
{
    for (WeakReferenceObject* w in listenerSet_) {
        if (!(w.baseObject)) {
            [listenerSet_ removeObject:w];
            break;
        }
    }
}

- (void) removeListener:(id)listener
{
    for (WeakReferenceObject* w in listenerSet_) {
        if ([w.baseObject isEqual:listener] ) {
            [listenerSet_ removeObject:w];
            break;
        }
    }
}

- (NSMutableSet*) getListenerSet:(Protocol*) p
{
    NSMutableSet* set = [[NSMutableSet alloc] init];
    if ([self isNull: listenerSet_]) {
        return set;
    }
    
    for (WeakReferenceObject* d in listenerSet_) {
        if ([d.baseObject conformsToProtocol:p]) {
            [set addObject:d.baseObject];
        }
    }
    return set;
}

- (NSString*) getMainFolder
{
    return mainFolder_;
}

- (void) register4Biz
{
    isReset_ = NO;
}

- (void) reset
{
    [listenerSet_ removeAllObjects];
    isReset_ = YES;
}

- (void) runInThread:(void (^)())block
{
    if (!queue) {
        queue = dispatch_queue_create("manager", NULL);
    }
    
    dispatch_async(queue, ^{
        block();
    });
}

-(void) sendUpdateRecentContactNotify:(NSString *)jid from:(NSString*) conversationType to:(RecentContactUpdateType) recentContactUpdateType
{
    @autoreleasepool {

        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
        [JSONObjectHelper putObject: conversationType withKey:KEY_TYPE toJSONObject:dataDic];
        [JSONObjectHelper putObject:[RecentRecord getRecnetContactUpdateTypeString:recentContactUpdateType] withKey:KEY_FLAG toJSONObject:dataDic];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        
        [JSONObjectHelper putObject:jid withKey:KEY_JID toJSONObject:infoDic];
        [JSONObjectHelper putObject:infoDic withKey:KEY_INFO toJSONObject:dataDic];
        
        NSMutableDictionary *totalDic = [NSMutableDictionary dictionary];
        [JSONObjectHelper putObject:dataDic withKey:KEY_DATA toJSONObject:totalDic];
        [JSONObjectHelper putObject:NOTIFY_update_recent_contact withKey:KEY_TYPE toJSONObject:totalDic];
        NSLog(@"SendUpdateRecentContact %@",[JSONObjectHelper encodeStringFromJSON:totalDic]);
        [[[BizlayerProxy shareInstance] whistleBizBridge] onBizNotify:[JSONObjectHelper encodeStringFromJSON:totalDic]];
        dataDic = nil;
        infoDic = nil;
        totalDic = nil;
    }
}
+ (void) appInit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Manager appInitImpl];
    });
}

+ (void)appInitImpl
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * destRootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *whistleFolder = [destRootPath stringByAppendingPathComponent:@"Whistle"];
    mainFolder_ = whistleFolder;
    
    NSString *whistleSubFolder = [whistleFolder stringByAppendingPathComponent:@"Whistle"];
    NSString *logFolder = [whistleFolder stringByAppendingPathComponent:@"log"];
    if (![fileManager fileExistsAtPath:whistleFolder]) {
        [fileManager createDirectoryAtPath:whistleFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:whistleSubFolder]) {
        [fileManager createDirectoryAtPath:whistleSubFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:logFolder]) {
        [fileManager createDirectoryAtPath:logFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *rootPath = [[NSBundle mainBundle] resourcePath];
    [self copyFile:[rootPath stringByAppendingPathComponent:FILE_NAME_ANT_CONFIG] toFile:[whistleFolder stringByAppendingPathComponent:FILE_NAME_ANT_CONFIG]];
    [self copyFile:[rootPath stringByAppendingPathComponent:FILE_NAME_APPCONFIG] toFile:[whistleFolder stringByAppendingPathComponent:FILE_NAME_APPCONFIG]];
    
    [[BizlayerProxy shareInstance].whistleBizBridge nativeInit:whistleFolder];
}

+ (void)copyFile:(NSString *)srcPath toFile:(NSString *)destPath {
    NSLog(@"srcpath : %@, \n destPath : %@", srcPath, destPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:destPath]) {
        [fileManager removeItemAtPath:destPath error:nil];
    }
    
    NSString *dirPath = [destPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:srcPath];
    [fileManager createFileAtPath:destPath contents:data attributes:nil];
}

+ (BOOL) isReset
{
    return isReset_;
}

+ (NSString*) getMainFolder4Log
{
    static NSString* log_ = nil;
    if (!log_) {
        log_ = [NSString stringWithFormat:@"%@/%@", mainFolder_, @"debug.rawnsloggerdata"];
    }
    return log_;
}


- (void) http_get_raw:(NSString *)urlStr succuess:(void (^)(NSData *))succuessCallback noData:(void (^)())noDataCallback error:(void (^)())errorCallback
{
    LOG_NETWORK_DEBUG(@"http的get请求url：%@", urlStr);
    NSString* url_encode = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:url_encode];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"http的get请求原始数据：%@, error:%@", data, error);
            if ([data length] > 0 && !error) {
                //成功操作
                succuessCallback(data);
            }else if ([data length] == 0 && !error){
                //没有数据也没有错误
                LOG_NETWORK_WARNING(@"网络get操作成功,返回原始数据为空");
                noDataCallback();
            }else if (error){
                //错误,超时
                LOG_NETWORK_ERROR(@"网络get操作失败,出错原因：%@", error);
                errorCallback();
            }else{
                LOG_NETWORK_ERROR(@"网络get操作失败,出错原因：%@", error);
                errorCallback();
            }
        }];
    }];
    
}

- (void) http_post_raw:(NSString *)urlStr body:(NSString *)body succuess:(void (^)(NSData *))succuessCallback noData:(void (^)())noDataCallback error:(void (^)())errorCallback
{
    NSString* url_encode = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:url_encode];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        [self runInThread:^{
            LOG_NETWORK_DEBUG(@"http的post请求原始数据：%@, error:%@", data, error);
            if ([data length] > 0 && !error) {
                //成功操作
                succuessCallback(data);
            }else if ([data length] == 0 && !error){
                //没有数据也没有错误
                LOG_NETWORK_WARNING(@"网络post操作成功,返回原始数据为空");
                noDataCallback();
            }else if (error){
                //错误,超时
                LOG_NETWORK_ERROR(@"网络post操作失败,出错原因：%@", error);
                errorCallback();
            }else{
                LOG_NETWORK_ERROR(@"网络post操作失败,出错原因：%@", error);
                errorCallback();
            }
        }];
    }];

}

- (void) getToken:(void(^)(NSString*)) callback
{
    [[BizlayerProxy shareInstance] getToken:@"" forceNew:NO callback:^(NSDictionary *data) {
        LOG_NETWORK_DEBUG(@"得到Token的原始数据：%@", data);
        ResultInfo* result = [self parseCommandResusltInfo:data];
        if (result.succeed) {
            NSString* token = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_TOKEN];
            callback(token);
        }else{
            LOG_NETWORK_ERROR(@"得到Token的值出错，原始数据：%@", data);
            callback(nil);
        }
    }];
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

- (NSDictionary*) try2Dic:(NSString *)str
{
    if ([str hasPrefix:@"\""] && [str hasSuffix:@"\""]) {
        NSString* s = [str substringWithRange:NSMakeRange(1, str.length - 2)];
        return [JSONObjectHelper decodeJSON:s];
    }
    return [JSONObjectHelper decodeJSON:str];
}

@end
