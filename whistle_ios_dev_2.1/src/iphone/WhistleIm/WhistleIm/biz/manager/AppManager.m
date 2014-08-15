//
//  AppManager.m
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppManager.h"
#import "Constants.h"
#import "JSONObjectHelper.h"
#import "LightAppInfo.h"
#import "NativeAppInfo.h"
#import "WebAppInfo.h"
#import "BizlayerProxy.h"
#import "LightAppMenuInfo.h"
#import "RosterManager.h"
#import "CacheManager.h"

#define APP_PATH_DIR @"app_cache"

@interface AppManager()<CacheDelegate, LoginStateDelegate>
{
    NSMutableArray* whistleAppList_;
    NSMutableArray* whistleRecommandAppList_;
    NSMutableArray* campusAppList_;
    NSMutableArray* campusRecommandAppList_;
    NSMutableArray* myCollectAppList_;
    
    NSMutableArray* cycleImageList_;
    NSMutableArray* cloudAppcyCleImageList_;
    
    BOOL isGetDataByNet_;
}

@end

@implementation AppManager

SINGLETON_IMPLEMENT(AppManager)

- (id) init
{
    self = [super init];
    if (self) {
        whistleAppList_ = [[NSMutableArray alloc] init];
        whistleRecommandAppList_ = [[NSMutableArray alloc] init];
        campusAppList_ = [[NSMutableArray alloc] init];
        campusRecommandAppList_ = [[NSMutableArray alloc] init];
        myCollectAppList_ = [[NSMutableArray alloc] init];
        cycleImageList_ = [[NSMutableArray alloc] init];
        cloudAppcyCleImageList_ = [[NSMutableArray alloc] init];
        [[CacheManager shareInstance] addListener:self];
        isGetDataByNet_ = NO;
    }
    return self;
}

- (void) register4Biz
{
    [super register4Biz];
    [[AccountManager shareInstance] addListener:self];
}


- (void) reset
{
    [super reset];
    [whistleAppList_ removeAllObjects];
    [whistleRecommandAppList_ removeAllObjects];
    [campusAppList_ removeAllObjects];
    [campusRecommandAppList_ removeAllObjects];
    [myCollectAppList_ removeAllObjects];
    [cycleImageList_ removeAllObjects];
    [cloudAppcyCleImageList_ removeAllObjects];
}

- (BOOL) isSuccess:(NSDictionary*) data
{
    if ([data objectForKey:KEY_ERROR_CODE] || [data objectForKey:KEY_ERROR]) {
        return NO;
    }
    return YES;
}

#pragma mark --
#pragma mark 得到应用的url拼接
- (NSString*) getRootAppUrl
{
    static NSString* url = nil;
    if (url) {
        return url;
    }
    NSString* root = [[BizlayerProxy shareInstance] getHttpRoot];
    if (!root || [@"" isEqualToString:root]) {
        url = nil;
        return @"";
    }
    url = [NSString stringWithFormat:@"%@/appcenter/", root];
    return  url;
}

- (NSString*) getAllAppURLByWhistle:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=cloud_app&a=list&platform=ios&offset=%d&limit=%d&token=%@",
                                        [self getRootAppUrl], offset, limit, token];
    LOG_NETWORK_DEBUG(@"微哨应用的url：%@",ret);
    return ret;
}

- (NSString*) getRecommandAppURLByWhistle:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=cloud_app&a=recommend&platform=ios&offset=%d&limit=%d&token=%@",
                            [self getRootAppUrl], offset, limit, token];
    LOG_NETWORK_DEBUG(@"微哨推荐应用的url：%@",ret);
    return ret;
}

- (NSString*) getAllAppURLByOther:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=opening&platform=ios&offset=%d&limit=%d&token=%@",
                            [self getRootAppUrl], offset, limit, token];
    LOG_NETWORK_DEBUG(@"校内应用的url：%@",ret);
    return ret;
}

- (NSString*) getRecommandAppURLByOther:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=recommend&platform=ios&offset=%d&limit=%d&token=%@",
                            [self getRootAppUrl], offset, limit, token];
    LOG_NETWORK_DEBUG(@"校内推荐应用的url：%@",ret);
    return ret;
}

- (NSString*) getAppDetailUrl:(NSString*) app_code token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=detail&app_code=%@&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, token];
    LOG_NETWORK_DEBUG(@"应用详细信息的url：%@",ret);
    return ret;
}
- (NSString*) getAppDetailUrlByAppid:(NSString*) appid token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=detail&app_id=%@&token=%@&platform=ios",
                            [self getRootAppUrl], appid, token];
    LOG_NETWORK_DEBUG(@"应用详细信息的url：%@",ret);
    return ret;
}
- (NSString*) getCommentAppListUrl:(NSString*) app_code offset:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=comment&a=list&app_code=%@&offset=%d&limit=%d&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, offset, limit, token];
    LOG_NETWORK_DEBUG(@"应用评论信息的url：%@",ret);
    return ret;
}

- (NSString*) getDeliverCommentUrl:(NSString*) app_code commnet:(NSString*) comment score:(NSInteger) score token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=comment&a=add&app_code=%@&comment=%@&score=%d&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, comment, score, token];
    LOG_NETWORK_DEBUG(@"发表应用评论信息的url：%@",ret);
    return ret;
}
- (NSString*) getDeliverCommentUrlNotScore:(NSString*) app_code commnet:(NSString*) comment token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=comment&a=add&app_code=%@&comment=%@&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, comment, token];
    LOG_NETWORK_DEBUG(@"发表应用评论信息的url：%@",ret);
    return ret;
}

- (NSString*) getCollectAppURL:(NSInteger) offset limit:(NSInteger) limit token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=collection&a=list&offset=%d&limit=%d&token=%@&platform=ios",
                            [self getRootAppUrl], offset, limit, token];
    LOG_NETWORK_DEBUG(@"得到我的收藏应用的url：%@",ret);
    return ret;
}

- (NSString*) getAdd2CollectAppURL:(NSString*) app_code token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=collection&a=add&app_code=%@&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, token];
    LOG_NETWORK_DEBUG(@"添加到收藏应用的url：%@",ret);
    return ret;
}

- (NSString*) getRemoveFromCollectAppURL:(NSString*) app_code token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=collection&a=remove&app_code=%@&token=%@&platform=ios",
                            [self getRootAppUrl], app_code, token];
    LOG_NETWORK_DEBUG(@"取消收藏应用的url：%@",ret);
    return ret;
}

- (NSString*) getAppCycleImageURL:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=promotionImage&platform=ios&token=%@",
                            [self getRootAppUrl], token];
    LOG_NETWORK_DEBUG(@"得到转轮图片的url：%@",ret);
    return ret;
}
- (NSString*) getCloudAppCycleImageURL:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=cloud_app&a=promotionImage&platform=ios&token=%@",
                            [self getRootAppUrl], token];
    LOG_NETWORK_DEBUG(@"得到微哨转轮图片的url：%@",ret);
    return ret;
}

- (NSString*) getQueryAppURL:(NSString*) str token:(NSString*) token
{
    NSMutableString* ret = [[NSMutableString alloc] initWithFormat:@"%@?m=app&a=search&platform=ios&token=%@&query=%@", [self getRootAppUrl], token, str];
    LOG_NETWORK_DEBUG(@"搜索应用的url：%@", ret);
    return ret;
}

- (NSString*) getMenuURL:(NSString*) appid token:(NSString*) token
{
    NSString* ret = [[NSString alloc] initWithFormat:@"%@?m=menu&a=viewMenu&app_id=%@&platform=ios", [self getRootAppUrl], appid];
    LOG_NETWORK_DEBUG(@"查看lightapp菜单的url：%@", ret);
    return ret;
}

#pragma mark --
#pragma mark 网络相关方法

- (void) http_get:(NSString*) urlStr succuess:(void(^)(NSDictionary*, BOOL)) succuessCallback noData:(void(^)()) noDataCallback error:(void(^)()) errorCallback
{
    NSLog(@"%@",urlStr);
    [super http_get_raw:urlStr succuess:^(NSData *data) {
        NSString* ret_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary* ret = [JSONObjectHelper decodeJSON:ret_str];
        BOOL isSuceess = [self isSuccess:ret];
        LOG_NETWORK_DEBUG(@"网络get操作成功,返回原始数据：%@, 返回的数据是否正确：%d", ret_str, isSuceess);
        succuessCallback(ret, isSuceess);
    } noData:^{
        noDataCallback();
    } error:^{
        errorCallback();
    }];
}

- (void) downloadImage:(NSString*) urlStr callback:(void(^)(NSString*)) callback
{
    NSString* fileName;
    fileName = [urlStr lastPathComponent];
    
    static NSString* app_cache = nil;
    static NSFileManager* fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [NSFileManager defaultManager];
        app_cache = [[super getMainFolder] stringByAppendingPathComponent:APP_PATH_DIR];
        if (![fileManager fileExistsAtPath: app_cache]) {
            [fileManager createDirectoryAtPath:app_cache withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    
    NSString* file = [app_cache stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:file]) {
        callback(file);
    }else{
        [self http_get_raw:urlStr succuess:^(NSData *data) {
            [data writeToFile:file atomically:YES];
            callback(file);
        } noData:^{
            callback(nil);
        } error:^{
            callback(nil);
        }];
    }
}

- (NSMutableArray*) appFactory:(NSDictionary*) data
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    NSArray* list_data_arr = [data objectForKey:KEY_LIST_DATA];
    if ([list_data_arr isKindOfClass:[NSArray class]]) {
        for (NSDictionary* info in list_data_arr) {
            if ([info isKindOfClass:[NSDictionary class]]) {
                BaseAppInfo* base = [JSONObjectHelper getObjectFromJSON:info withClass:[BaseAppInfo class]];
                if ([base isLightApp]) {
                    LightAppInfo* lightapp = [JSONObjectHelper getObjectFromJSON:info withClass:[LightAppInfo class]];
                    [ret addObject:lightapp];
                }else if ([base isNativeApp]){
                    NativeAppInfo* native = [JSONObjectHelper getObjectFromJSON:info withClass:[NativeAppInfo class]];
                    [ret addObject:native];
                }else if ([base isWebApp]){
                    WebAppInfo* webapp = [JSONObjectHelper getObjectFromJSON:info withClass:[WebAppInfo class]];
                    [ret addObject:webapp];
                }else{
                    //其他情况再讨论
                }
            }
        }
    }
    
    return ret;
}

- (NSInteger) getTotal:(NSDictionary*) data
{
    return [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_TOTAL defaultValue:0];
}


#pragma mark --
#pragma mark 应用操作

/*
 {"total":1,"list_data":[{"app_name":"hulala","app_code":"","url":"http://hulala.duapp.com","type":"lightapp","describe":"报时","popularity":0,"recommend":0,"iscollection":0,"custom_info":[],"icon":{"pc":{"large":"http://172.16.56.103/image/13883739801000.png","middle":"http://172.16.56.103/image/1388374171999.png","small":"http://172.16.56.103/image/1388374021999.png"},"android":{"large":"http://172.16.56.103/image/1388373988999.png","middle":"http://172.16.56.103/image/13883740011000.png"},"ios":{"large":"http://172.16.56.103/image/1388373994999.png","middle":"http://172.16.56.103/image/13883739981000.png"}},"open_with":[],"developer":{"jid":0,"name":"校方应用","organization":"开发联调组织"},"score":{"total":0,"times":0,"average":0}}]}
 */
- (void) getCampusApp:(NSInteger) offset count:(NSInteger) count callback:(void (^)(BOOL))callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAllAppURLByOther:offset limit:count token:token];
        [self http_get: url succuess:^(NSDictionary* data, BOOL isSuccuss){
            if (isSuccuss) {
                NSArray* arr = [self appFactory:data];
                [self addAppArray:campusAppList_ new:arr];
                [self sendGetCampusAppListFinishDelegate: [self getTotal:data]];
                [self getAppImage:campusAppList_ finish:^{
                    [self sendCampusAppListChangedDelegate];
                }];
                callback(arr.count == count);
            }else{
                [self sendGetCampusAppListFailureDelegate];
                callback(YES);
            }
            
        } noData:^{
            [self sendGetCampusAppListFailureDelegate];
            callback(YES);
        } error:^{
            [self sendGetCampusAppListFailureDelegate];
            callback(YES);
        }];
    }];
}

- (void) addAppArray:(NSMutableArray*) old new:(NSArray*) newer
{
    BOOL isFind = NO;
    for (BaseAppInfo* n in newer) {
        isFind = NO;
        for (BaseAppInfo* o in old) {
            if ([n.appCode isEqualToString:o.appCode]) {
                isFind = YES;
                break;
            }
        }
        if (!isFind) {
            [old addObject:n];
        }
    }
}

- (void) getWhistleApp:(NSInteger) offset count:(NSInteger) count callback:(void (^)(BOOL))callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAllAppURLByWhistle:offset limit:count token:token];
        [self http_get: url succuess:^(NSDictionary* data, BOOL isSuccuss){
            if (isSuccuss) {
                NSArray* arr = [self appFactory:data];
                [self addAppArray:whistleAppList_ new:arr];
                [self sendGetWhistleAppListFinsihDelegate: [self getTotal:data]];
                [self getAppImage:whistleAppList_  finish:^{
                    [self sendWhistleAppListChangedDelegate];
                }];
                callback(arr.count == count);
            }else{
                [self sendGetWhistleAppListFailureDelegate];
                callback(YES);
            }
        } noData:^{
            [self sendGetWhistleAppListFailureDelegate];
            callback(YES);
        } error:^{
            [self sendGetWhistleAppListFailureDelegate];
            callback(YES);
        }];

    }];
}


- (void) getRecommandCampusApp:(NSInteger) offset count:(NSInteger) count
{
    [super runInThread:^{
        if (campusRecommandAppList_.count > 0) {
            [self sendGetRecommandCampusAppListFinishDelegate: campusRecommandAppList_.count];
        }
        [self getToken:^(NSString *token) {
            NSString* url = [self getRecommandAppURLByOther:offset limit:count token:token];
            LOG_NETWORK_DEBUG(@"得到校园推荐应用的url：%@", url);
            [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
                LOG_NETWORK_ERROR(@"得到校园推荐应用成功，原始数据：%@", data);
                if (isSuccuss) {
                    [campusRecommandAppList_ removeAllObjects];
                    [campusRecommandAppList_ addObjectsFromArray:[self appFactory:data]];
                    [self sendGetRecommandCampusAppListFinishDelegate: [self getTotal:data]];
                    [self getAppImage:campusRecommandAppList_ finish:^{
                        [self sendRecommandCampusAppListChangedDelegate];
                    }];
                }else{
                    [self sendGetRecommandCampusAppListFailureDelegate];
                }
            } noData:^{
                LOG_NETWORK_ERROR(@"得到校园推荐应用失败");
                [self sendGetRecommandCampusAppListFailureDelegate];
            } error:^{
                LOG_NETWORK_ERROR(@"得到校园推荐应用失败");
                [self sendGetRecommandCampusAppListFailureDelegate];
            }];
            
        }];
    }];
}

- (void) getRecommandWhistleApp:(NSInteger) offset count:(NSInteger) count
{
    [super runInThread:^{
        if (whistleRecommandAppList_.count > 0) {
            [self sendGetRecommandWhistleAppListFinsihDelegate: whistleRecommandAppList_.count];
        }
        [self getToken:^(NSString *token) {
            NSString* url = [self getRecommandAppURLByWhistle:offset limit:count token:token];
            [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
                if (isSuccuss) {
                    [whistleRecommandAppList_ removeAllObjects];
                    [whistleRecommandAppList_ addObjectsFromArray:[self appFactory:data]];
                    [self sendGetRecommandWhistleAppListFinsihDelegate: [self getTotal:data]];
                    [self getAppImage:whistleRecommandAppList_ finish:^{
                        [self sendRecommandWhsitleAppListChangedDelegate];
                    }];
                }else{
                    [self sendGetRecommandWhistleAppListFailureDelegate];
                }
                
            } noData:^{
                [self sendGetRecommandWhistleAppListFailureDelegate];
            } error:^{
                [self sendGetRecommandWhistleAppListFailureDelegate];
            }];
        }];
    }];
    
}

- (void) getAppDetailInfo:(BaseAppInfo*) app// callback:(void(^)(BaseAppInfo*, BOOL)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAppDetailUrl:app.appCode token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            [app appendDetailInfo:data];
            BaseAppInfo* base = [JSONObjectHelper getObjectFromJSON:data withClass:[BaseAppInfo class]];
            if ([base isLightApp]) {
                base = [JSONObjectHelper getObjectFromJSON:data withClass:[LightAppInfo class]];
            }else if([base isNativeApp]){
                base = [JSONObjectHelper getObjectFromJSON:data withClass:[NativeAppInfo class]];
            }else if([base isWebApp]){
                base = [JSONObjectHelper getObjectFromJSON:data withClass:[WebAppInfo class]];
            }
            [self getAppImage:[[NSMutableArray alloc] initWithObjects:base, nil] finish:^{
                [self sendGetAppDetailFinishDelegate:base];
            }];
            [self getAppDetailImage:base finish:^{
                [self sendAppDetailInfoChangedDelegate:base];
            }];
        } noData:^{
            [self sendGetAppDetailFailureDelegate];
        } error:^{
            [self sendGetAppDetailFailureDelegate];
        }];
    }];
}

- (void) getAppDetailInfoByAppid:(NSString*) appid callback:(void(^)(BaseAppInfo*, BOOL)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAppDetailUrlByAppid:appid token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            LOG_NETWORK_DEBUG(@"通过appid得到应用的详细信息原始数据：%@", data);
            BaseAppInfo* app = nil;
            if (isSuccuss) {
                app = [JSONObjectHelper getObjectFromJSON:data withClass:[LightAppInfo class]];
                [self getAppImage:(NSMutableArray*)[[NSArray alloc] initWithObjects:app, nil] finish:^{
                    callback(app, YES);
                }];
            }else{
                callback(app, NO);
            }

        } noData:^{
            callback(nil, NO);
        } error:^{
            callback(nil, NO);
        }];
    }];
}

- (void) getAppDetailInfo:(NSString *)appid callback:(void (^)(BaseAppInfo *, BOOL))callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAppDetailUrl:appid token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            LOG_NETWORK_DEBUG(@"得到应用的详细信息：%@", data);
            if (isSuccuss) {
                BaseAppInfo* app = [JSONObjectHelper getObjectFromJSON:data withClass:[BaseAppInfo class]];
                [self getAppDetailImage:app finish:^{
                    callback(app, YES);
                }];
            }
        } noData:^{
            callback(nil, NO);
        } error:^{
            callback(nil, NO);
        }];
    }];
}

- (void) getAppComment:(BaseAppInfo*) app offset:(NSInteger) offset count:(NSInteger) count
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getCommentAppListUrl:app.appCode offset:offset limit:count token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            [app appendCommentInfo:data];
            [self sendGetAppCommentsDelegate:app];
            if (app.comment && app.comment.comments) {
                __block int count = app.comment.comments.count;
                for (AppCommentItem* item in app.comment.comments) {
                    [[RosterManager shareInstance] getFriendInfoByJid:item.comment_jid checkStrange:YES WithCallback:^(FriendInfo *f) {
                        item.extraInfo = f;
                        count --;
                        if (count <= 0) {
                            [self sendAppCommentsChangedDelegate:app];
                        }
                    }];
                }
            }
        } noData:^{
        } error:^{
        }];
    }];
}

- (void) deliverComment:(BaseAppInfo*) app comment: (NSString*) comment score:(NSInteger) score callback:(void(^)(BOOL)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = nil;
        if (app.comment.isCommented) {
            url = [self getDeliverCommentUrlNotScore:app.appCode commnet:comment token:token];
        }else{
            url = [self getDeliverCommentUrl:app.appCode commnet:comment score:score token:token];
        }
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            //发表成功后重新刷新下评论
            [self getAppComment:app offset:0 count:15];
            callback(YES);
        } noData:^{
            callback(NO);
        } error:^{
            callback(NO);
        }];
    }];
}

- (void) getMyCollectApp:(NSInteger) offset count:(NSInteger) count
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getCollectAppURL:offset limit:count token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            if (isSuccuss) {
                [myCollectAppList_ addObjectsFromArray:[self appFactory:data]];
                for (BaseAppInfo* ai in myCollectAppList_) {
                    ai.isCollection = YES;
                }
                [self sendGetMyCollectAppFinishDelegate: [self getTotal:data]];
                [self getAppImage:myCollectAppList_ finish:^{
                    [self sendMyCollectAppListChanged];
                }];
            }else{
                [self sendGetMyCollectAppFailureDelegate];
            }
        } noData:^{
            [self sendGetMyCollectAppFailureDelegate];
        } error:^{
            [self sendGetMyCollectAppFailureDelegate];
        }];
    }];
}

- (void) add2MyCollectApp:(BaseAppInfo*) app callback:(void(^)(BOOL)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAdd2CollectAppURL:app.appCode token: token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            app.isCollection = YES;
            [myCollectAppList_ addObject:app];
            [self sendMyCollectAppListChanged];
            for (BaseAppInfo* info in whistleAppList_) {
                if ([info.appCode isEqualToString:app.appCode]) {
                    info.isCollection = YES;
                    break;
                }
            }
            [self sendWhistleAppListChangedDelegate];
            for (BaseAppInfo* info in campusAppList_) {
                if ([info.appCode isEqualToString:app.appCode]) {
                    info.isCollection = YES;
                    break;
                }
            }
            [self sendCampusAppListChangedDelegate];
            callback(YES);
        } noData:^{
            callback(NO);
        } error:^{
            callback(NO);
        }];
    }];
}

- (void) removeFromMyCollectApp:(BaseAppInfo*) app callback:(void(^)(BOOL)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getRemoveFromCollectAppURL:app.appCode token:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            app.isCollection = NO;
            //[myCollectAppList_ removeObject:app];//这里可能存在app是一个copy值，就删除失败了
            NSMutableArray* tmp = [[NSMutableArray alloc] init];
            for (BaseAppInfo* bai in myCollectAppList_) {
                if ([bai.appCode isEqualToString:app.appCode]) {
                    [tmp addObject:bai];
                }
            }
            [myCollectAppList_ removeObjectsInArray:tmp];
            [self sendMyCollectAppListChanged];
            for (BaseAppInfo* info in whistleAppList_) {
                if ([info.appCode isEqualToString:app.appCode]) {
                    info.isCollection = NO;
                    break;
                }
            }
            [self sendWhistleAppListChangedDelegate];
            for (BaseAppInfo* info in campusAppList_) {
                if ([info.appCode isEqualToString:app.appCode]) {
                    info.isCollection = NO;
                    break;
                }
            }
            [self sendCampusAppListChangedDelegate];

            callback(YES);
        } noData:^{
            callback(NO);
        } error:^{
            callback(NO);
        }];
    }];
}

- (void) getAppCycleImage
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getAppCycleImageURL:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            LOG_NETWORK_DEBUG(@"得到轮播图片的数据:%@", data);
            if (isSuccuss) {
                int total = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_TOTAL defaultValue:0];
                NSArray* arr = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_LIST_DATA withClass:[BaseAppInfo class]];
                [cycleImageList_ removeAllObjects];
                [cycleImageList_ addObjectsFromArray:arr];
                [self getAppImage:cycleImageList_ finish:^{
                    [self sendGetCycleImageFinishDelegate:total];
                }];
                [self getCycleImage:cycleImageList_];
            }else{
                [self sendGetCycleImageFailureDelegate];
            }
        } noData:^{
            [self sendGetCycleImageFailureDelegate];
        } error:^{
            [self sendGetCycleImageFailureDelegate];
        }];
    }];
}

- (void) getCloudAppCycleImage
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getCloudAppCycleImageURL:token];
        [self http_get:url succuess:^(NSDictionary* data, BOOL isSuccuss){
            LOG_NETWORK_DEBUG(@"得到轮播图片的数据:%@", data);
            if (isSuccuss) {
                int total = [JSONObjectHelper getIntFromJSONObject:data forKey:KEY_TOTAL defaultValue:0];
                NSArray* arr = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_LIST_DATA withClass:[BaseAppInfo class]];
                [cloudAppcyCleImageList_ removeAllObjects];
                [cloudAppcyCleImageList_ addObjectsFromArray:arr];
                [self getAppImage:cloudAppcyCleImageList_ finish:^{
                    [self sendGetCloudAppCycleImageFinishDelegate:total];
                }];

                [self getCloudAppCycleImage:cloudAppcyCleImageList_];
            }else{
                [self sendGetCloudAppCycleImageFailureDelegate];
            }
        } noData:^{
            [self sendGetCloudAppCycleImageFailureDelegate];
        } error:^{
            [self sendGetCloudAppCycleImageFailureDelegate];
        }];
    }];
}

- (void) queryApp:(NSString *)str offset:(NSInteger)offset count:(NSInteger)count
{
    NSString* trim_str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([@"" isEqualToString: trim_str]) {
        [self sendGetQueryAppFinishDelegate:[NSArray array]];
    }else{
        [self getToken:^(NSString *token) {
            NSString* url = [self getQueryAppURL:trim_str token: token];
            [self http_get:url succuess:^(NSDictionary *data, BOOL isSuccess) {
                if (isSuccess) {
                    NSMutableArray* apps = [self appFactory:data];//[JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_LIST_DATA withClass:[BaseAppInfo class]];
                    [self sendGetQueryAppFinishDelegate:apps];
                    [self getAppImage:apps finish:^{
                        [self sendQueryAppListChangedDelegate:apps];
                    }];
                }else{
                    [self sendGetQueryAppFailureDelegate];
                }
            } noData:^{
                [self sendGetQueryAppFailureDelegate];
            } error:^{
                [self sendGetQueryAppFailureDelegate];
            }];
        }];
    }
}

- (void) getMenu:(NSString*) appid callback:(void(^)(NSArray*)) callback
{
    [self getToken:^(NSString *token) {
        NSString* url = [self getMenuURL:appid token:token];
        [self http_get:url succuess:^(NSDictionary *data, BOOL isSuccess) {
            if (isSuccess) {
                NSArray* menus = [JSONObjectHelper getObjectArrayFromJsonObject:data forKey:KEY_BUTTON withClass:[LightAppMenuInfo class]];
                callback(menus);
            }
            callback(nil);
        } noData:^{
            callback(nil);
        } error:^{
            callback(nil);
        }];
    }];
}

#pragma mark --
#pragma mark 内部方法
//得到应用的large和middle图片
- (void) getAppImage:(NSMutableArray*) list finish:(void(^)()) callback
{
    __block int count = list.count * 2;
    for (BaseAppInfo* info in list) {
        if (info.appIcon_large_url_) {
            if (info.appIcon_large) {
                count --;
                if (count <= 0) {
                    callback();
                }
            }else{
                [self downloadImage:info.appIcon_large_url_ callback:^(NSString *file) {
                    info.appIcon_large = file;
                    count --;
                    if (count <= 0) {
                        callback();
                    }
                }];
            }
        }else{
            count --;
            if (count <= 0) {
                callback();
            }
        }
        
        if (info.appIcon_middle_url_) {
            if (info.appIcon_middle) {
                count --;
                if (count <= 0) {
                    callback();
                }
            }else{
                [self downloadImage:info.appIcon_middle_url_ callback:^(NSString *file) {
                    info.appIcon_middle = file;
                    count --;
                    if (count <= 0) {
                        callback();
                    }
                }];
            }
        }else{
            count --;
            if (count <= 0) {
                callback();
            }
        }
        
    }
}

- (void) getAppDetailImage:(BaseAppInfo*) info finish:(void(^)()) callback
{
    __block BOOL isScreenshotDone_ = NO;
    __block BOOL isRecommendIconDone_ = NO;
    info.screenshot = [[NSMutableArray alloc] initWithCapacity:info.screenshot_url_.count];
    __block int count = info.screenshot_url_.count;
    NSArray* list = info.screenshot_url_;
    for (NSString* url in list) {
        [self downloadImage:url callback:^(NSString *file) {
            if (file) {
                [info.screenshot addObject:file];
            }
            count --;
            if (count <= 0) {
                isScreenshotDone_ = YES;
                if (isScreenshotDone_ && isRecommendIconDone_) {
                    callback();
                }
            }
        }];
    }
    [self downloadImage:info.recommend_icon_url_ callback:^(NSString *file) {
        info.recommend_icon = file;
        isRecommendIconDone_ = YES;
        if (isScreenshotDone_ && isRecommendIconDone_) {
            callback();
        }
    }];
}

- (void) getCycleImage:(NSArray*) list
{
    for (BaseAppInfo* info in list) {
        [self downloadImage:info.recommend_icon_url_ callback:^(NSString *file) {
            info.recommend_icon = file;
            [self sendCycleImageListChangedDelegate];
        }];
    }
}
- (void) getCloudAppCycleImage:(NSArray*) list
{
    for (BaseAppInfo* info in list) {
        [self downloadImage:info.recommend_icon_url_ callback:^(NSString *file) {
            info.recommend_icon = file;
            [self sendCloudAppCycleImageListChangedDelegate];
        }];
    }
}

- (void) loginSucess
{
    [self runInThread:^{
        isGetDataByNet_ = YES;
    }];
}

#pragma mark --
#pragma mark delegate事件发送函数

- (void) sendGetCampusAppListFinishDelegate:(NSInteger) count
{
    LOG_NETWORK_DEBUG(@"得到学校应用的数据：%@", [super toArrayString:campusAppList_]);
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCampusAppListFinish:total:)]) {
            [d getCampusAppListFinish: campusAppList_ total:count];
        }
    }
}

- (void) sendGetCampusAppListFailureDelegate
{
    LOG_NETWORK_DEBUG(@"得到学校应用的数据失败");
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCampusAppListFailure)]) {
            [d getCampusAppListFailure];
        }
    }
}

- (void) sendCampusAppListChangedDelegate
{
    LOG_NETWORK_DEBUG(@"学校应用的数据变更：%@", [super toArrayString:campusAppList_]);
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(campusAppListChanged:)]) {
            [d campusAppListChanged:campusAppList_];
        }
    }
    
}
- (void) sendGetRecommandCampusAppListFinishDelegate:(NSInteger) count
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getRecommandCampusAppListFinish:total:)]) {
            [d getRecommandCampusAppListFinish:campusRecommandAppList_ total:count];
        }
    }
}

- (void) sendGetRecommandCampusAppListFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getRecommandCampusAppListFailure)]) {
            [d getRecommandCampusAppListFailure];
        }
    }
    
}

- (void) sendRecommandCampusAppListChangedDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(recommandCampusAppListChanged:)]) {
            [d recommandCampusAppListChanged:campusRecommandAppList_];
        }
    }
    
}



- (void) sendGetWhistleAppListFinsihDelegate:(NSInteger) count
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getWhistleAppListFinsih:total:)]) {
            [d getWhistleAppListFinsih:whistleAppList_ total:count];
        }
    }
    
}

- (void) sendGetWhistleAppListFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getWhistleAppListFailure)]) {
            [d getWhistleAppListFailure];
        }
    }
    
}

- (void) sendWhistleAppListChangedDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(whsitleAppListChanged:)]) {
            [d whsitleAppListChanged:whistleAppList_];
        }
    }
    
}

- (void) sendGetRecommandWhistleAppListFinsihDelegate:(NSInteger) count
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getRecommandWhistleAppListFinsih:total:)]) {
            [d getRecommandWhistleAppListFinsih:whistleRecommandAppList_ total:count];
        }
    }
    
}

- (void) sendGetRecommandWhistleAppListFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getRecommandWhistleAppListFailure)]) {
            [d getRecommandWhistleAppListFailure];
        }
    }
    
}

- (void) sendRecommandWhsitleAppListChangedDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(recommandWhsitleAppListChanged:)]) {
            [d recommandWhsitleAppListChanged:whistleRecommandAppList_];
        }
    }
    
}


- (void) sendGetMyCollectAppFinishDelegate:(NSInteger) count
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getMyCollectAppFinish:total:)]) {
            [d getMyCollectAppFinish:myCollectAppList_ total:count];
        }
    }
    
}

- (void) sendGetMyCollectAppFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getMyCollectAppFailure)]) {
            [d getMyCollectAppFailure];
        }
    }
    
}

- (void) sendMyCollectAppListChanged
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(myCollectAppListChanged:)]) {
            [d myCollectAppListChanged:myCollectAppList_];
        }
    }
}

- (void) sendGetAppDetailFinishDelegate:(BaseAppInfo*) info
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getAppDetailFinish:)]) {
            [d getAppDetailFinish:info];
        }
    }
}

- (void) sendAppDetailInfoChangedDelegate:(BaseAppInfo*) info
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(appDetailInfoChanged:)]) {
            [d appDetailInfoChanged:info];
        }
    }
}

- (void) sendGetAppDetailFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getAppDetailFailure)]) {
            [d getAppDetailFailure];
        }
    }
}

- (void) sendCycleImageListChangedDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(cycleImageListChange:)]) {
            [d cycleImageListChange:cycleImageList_];
        }
    }
}

- (void) sendGetCycleImageFinishDelegate:(NSInteger) total
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCycleImageFinish:total:)]) {
            [d getCycleImageFinish:cycleImageList_ total:total];
        }
    }
}

- (void) sendGetCycleImageFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCycleImageFailure)]) {
            [d getCycleImageFailure];
        }
    }
}

- (void) sendCloudAppCycleImageListChangedDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(cloudAppCycleImageListChange:)]) {
            [d cloudAppCycleImageListChange:cloudAppcyCleImageList_];
        }
    }
}

- (void) sendGetCloudAppCycleImageFinishDelegate:(NSInteger) total
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCloudAppCycleImageFinish:total:)]) {
            [d getCloudAppCycleImageFinish:cloudAppcyCleImageList_ total:total];
        }
    }
}

- (void) sendGetCloudAppCycleImageFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getCloudAppCycleImageFailure)]) {
            [d getCloudAppCycleImageFailure];
        }
    }
}

- (void) sendGetAppCommentsDelegate:(BaseAppInfo*) app
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getAppComments:)]) {
            [d getAppComments:app];
        }
    }
}

- (void) sendAppCommentsChangedDelegate:(BaseAppInfo*) app
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(appCommentsChanged:)]) {
            [d appCommentsChanged:app];
        }
    }
}

- (void) sendGetQueryAppFinishDelegate:(NSArray*) list
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getQueryAppFinish:)]) {
            [d getQueryAppFinish:list];
        }
    }
}

- (void) sendGetQueryAppFailureDelegate
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(getQueryAppFailure)]) {
            [d getQueryAppFailure];
        }
    }
}

- (void) sendQueryAppListChangedDelegate:(NSArray*) list
{
    for (id<AppCenterDelegate> d in [self getListenerSet:@protocol(AppCenterDelegate)]) {
        if ([d respondsToSelector:@selector(queryAppListChanged:)]) {
            [d queryAppListChanged:list];
        }
    }
}

#pragma -- mark 序列化数据
#define KEY_WHISTLE_RECOMMAND_APP @"whistle_recommand_app"
#define KEY_CAMPUS_RECOMMND_APP @"compus_recommand_app"
- (void) serialization
{
    [CacheManager serialization:KEY_CAMPUS_RECOMMND_APP array:campusRecommandAppList_];
    [CacheManager serialization:KEY_WHISTLE_RECOMMAND_APP array:whistleRecommandAppList_];
}

- (void) unserialization:(NSDictionary *)data
{
    [campusRecommandAppList_ removeAllObjects];
    [whistleRecommandAppList_ removeAllObjects];
    if ([data isKindOfClass:[NSDictionary class]]) {
        id campusrecommand = [data objectForKey:KEY_CAMPUS_RECOMMND_APP];
        if ([campusrecommand isKindOfClass:[NSArray class]]) {
            for (id tmp in campusrecommand) {
                BaseAppInfo* info = [[BaseAppInfo alloc] init];
                [info decode:tmp obj:info];
                if ([info isLightApp]) {
                    LightAppInfo* linfo = [[LightAppInfo alloc] init];
                    [linfo decode:tmp obj:linfo];
                    info = linfo;
                }
                [campusRecommandAppList_ addObject:info];
            }
//                [self sendRecommandCampusAppListChangedDelegate];
        }
        id whsitlerecommand = [data objectForKey:KEY_WHISTLE_RECOMMAND_APP];
        if ([whsitlerecommand isKindOfClass:[NSArray class]]) {
            for (id tmp in whsitlerecommand) {
                BaseAppInfo* info = [[BaseAppInfo alloc] init];
                [info decode:tmp obj:info];
                if ([info isLightApp]) {
                    LightAppInfo* linfo = [[LightAppInfo alloc] init];
                    [linfo decode:tmp obj:linfo];
                    info = linfo;
                }
                [whistleRecommandAppList_ addObject:info];
            }
//                [self sendRecommandWhsitleAppListChangedDelegate];
        }
    }
}

@end
