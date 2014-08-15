//
//  Manager.h
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultInfo.h"
#import "WeakReferenceObject.h"
#import "ConversationInfo.h"
#import "RecentRecord.h"




@interface Manager : NSObject

@property (strong, nonatomic, getter = getMainFolder, readonly) NSString* mainFolder;

- (ResultInfo*) parseCommandResusltInfo:result;
/**
 *  判断一个对象是否为空，包括集合类和普通类
 *
 *  @param ref 对象
 *
 *  @return 是nil或者null时返回YES
 */
- (BOOL) isNull:(id) ref;
/**
 *  添加监听类，数据变更后会自动发送相应的事件。这里是弱引用，不需要手动去年监听类。
 *
 *  @param listener 监听类，一般为controller
 */
- (void) addListener:(id)listener;

/**
 *  手动去掉监听类，使用场景为：只想接收一次事件提醒，其他时候不需要再监听。
 *
 *  @param listener 监听类，一般为controller
 */
- (void) removeListener:(id) listener;

- (NSMutableSet*) getListenerSet:(Protocol*) p;
/**
 *  向biz层注册listener,包括获取数据列表的过程（roster列表、群列表、应用提醒列表等）。
    应该在注册listener完成后再调用该方法
 */
- (void) register4Biz;

- (void) reset;

- (void) runInThread:(void(^)()) block;

- (void) sendUpdateRecentContactNotify:(NSString *)jid from:(NSString*) conversationType to:(RecentContactUpdateType) recentContactUpdateType;

+ (void) appInit;

+ (BOOL) isReset;

+ (NSString*) getMainFolder4Log;
/**
 *  这个方法主要是用来debug; 得到一个集合中所有元素的字符串形式，目前这些元素需要实现ToStringDelegate协议或者元素本身是字符串。
 *
 *  @param array 集合对象，目前支持array和set
 *
 *  @return 返回集合的字符串形式
 */
- (NSString*) toArrayString:(id) array;

- (void) http_get_raw:(NSString *)urlStr succuess:(void (^)(NSData *))succuessCallback noData:(void (^)())noDataCallback error:(void (^)())errorCallback;
- (void) http_post_raw:(NSString *)urlStr body:(NSString*) body succuess:(void (^)(NSData *))succuessCallback noData:(void (^)())noDataCallback error:(void (^)())errorCallback;

- (void) getToken:(void(^)(NSString*)) callback;

- (NSDictionary*) try2Dic:(NSString*) str;

@end
