//
//  AppManager.h
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Manager.h"
#import "BaseAppInfo.h"

@protocol AppCenterDelegate <NSObject>

@optional

/**
 *  得到校内应用成功事件
 *
 *  @param list 校内应用列表
 */
- (void) getCampusAppListFinish:(NSArray*) list total:(NSInteger) total;

/**
 *  得到校内应用失败事件
 */
- (void) getCampusAppListFailure;
/**
 *  校内应用列表更新事件
 *
 *  @param list 校内应用列表
 */
- (void) campusAppListChanged:(NSArray*) list;

/**
 *  得到校内推荐应用成功事件
 *
 *  @param list 校内推荐应用列表
 */
- (void) getRecommandCampusAppListFinish:(NSArray*) list total:(NSInteger) total;

/**
 *  得到校内推荐应用失败事件
 */
- (void) getRecommandCampusAppListFailure;
/**
 *  校内推荐应用列表更新事件
 *
 *  @param list 校内推荐应用列表
 */
- (void) recommandCampusAppListChanged:(NSArray*) list;



/**
 *  得到微哨应用成功事件
 *
 *  @param list 微哨应用列表
 */
- (void) getWhistleAppListFinsih:(NSArray*) list total:(NSInteger) total;

/**
 *  得到微哨应用失败事件
 */
- (void) getWhistleAppListFailure;

/**
 *  微哨应用列表更新事件
 *
 *  @param list 微哨应用列表
 */
- (void) whsitleAppListChanged:(NSArray*) list;

/**
 *  得到微哨推荐应用成功事件
 *
 *  @param list 微哨推荐应用列表
 */
- (void) getRecommandWhistleAppListFinsih:(NSArray*) list total:(NSInteger) total;

/**
 *  得到微哨推荐应用失败事件
 */
- (void) getRecommandWhistleAppListFailure;

/**
 *  微哨推荐应用列表更新事件
 *
 *  @param list 微哨推荐应用列表
 */
- (void) recommandWhsitleAppListChanged:(NSArray*) list;



/**
 *  得到我的收藏列表成功事件
 *
 *  @param list 我的收藏列表集合
 */
- (void) getMyCollectAppFinish:(NSArray*) list total:(NSInteger) total;

/**
 *  得到我的收藏列表失败事件
 */
- (void) getMyCollectAppFailure;

/**
 *  我的收藏列表变更事件
 *
 *  @param list 我的收藏列表集合
 */
- (void) myCollectAppListChanged:(NSArray*) list;

/**
 *  得到应用详细信息
 *
 *  @param info 应用详细消息实体类
 */
- (void) getAppDetailFinish:(BaseAppInfo*) info;

- (void) getAppDetailFailure;
/**
 *  应用详细信息变更，主要是获得图片后再发这个事件
 *
 *  @param info 应用详细消息实体类
 */
- (void) appDetailInfoChanged:(BaseAppInfo*) info;
/**
 *  轮转图片更新事件
 *
 *  @param cycleImageLit 图片的集合
 */
- (void) cycleImageListChange:(NSArray*) list;

/**
 *  得到轮转图片的实体类，其实是BaseAppInfo类，但不包含图片的下载，这时应该使用默认图片代替
 *
 *  @param list  应用的实体类集合，每个实体类中包含一个图片
 *  @param total 图片的个数
 */
- (void) getCycleImageFinish:(NSArray*) list total:(NSInteger) total;

/**
 *  得到轮转图片失败
 */
- (void) getCycleImageFailure;

/**
 *  微哨轮转图片更新事件
 *
 *  @param cycleImageLit 图片的集合
 */
- (void) cloudAppCycleImageListChange:(NSArray*) list;

/**
 *  得到微哨轮转图片的实体类，其实是BaseAppInfo类，但不包含图片的下载，这时应该使用默认图片代替
 *
 *  @param list  应用的实体类集合，每个实体类中包含一个图片
 *  @param total 图片的个数
 */
- (void) getCloudAppCycleImageFinish:(NSArray*) list total:(NSInteger) total;

/**
 *  得到微哨轮转图片失败
 */
- (void) getCloudAppCycleImageFailure;

/**
 *  得到应用的评论
 *
 *  @param app 应用的实体类，其中包括应用的评论
 */
- (void) getAppComments:(BaseAppInfo*) app;

- (void) appCommentsChanged:(BaseAppInfo*) app;

/**
 *  搜索应用事件
 *
 *  @param list 搜索后的应用集合
 */
- (void) getQueryAppFinish:(NSArray*) list;
/**
 *  搜索数据失败事件
 */
- (void) getQueryAppFailure;
/**
 *  搜索数据变更事件，用于得到更完整的数据
 *
 *  @param list 搜索应用的集合
 */
- (void) queryAppListChanged:(NSArray*) list;


@end

@interface AppManager : Manager

SINGLETON_DEFINE(AppManager)

/**
 *  得到应用中心中校内应用列表，结果使用getCompusAppListFinsih或者getCompusAppListFailure接口返回.callback返回下次再请求是否还有数据
 *
 *  @param offset 起始位置
 *  @param count  数量
 */
- (void) getCampusApp:(NSInteger) offset count:(NSInteger) count callback:(void(^)(BOOL)) callback;

/**
 *  得到应用中心中微哨应用列表，结果使用getWhistleAppListFinsih或者getWhistleAppListFailure接口返回.callback返回下次再请求是否还有数据
 *
 *  @param offset 起始位置
 *  @param count  数量
 */
- (void) getWhistleApp:(NSInteger) offset count:(NSInteger) count callback:(void(^)(BOOL)) callback;


/**
 *
 *  得到推荐的校内应用列表，使用getRecommandCompusAppListFinsih或者
 *  getRecommandCompusAppListFailure接口返回结果
 *
 *  @param offset 起始位置
 *  @param count  数量
 *
 */
- (void) getRecommandCampusApp:(NSInteger) offset count:(NSInteger) count;
/**
 *  得到推荐的微哨应用列表，使用getRecommandWhistleAppListFinsih或者
 *  getRecommandWhistleAppListFailure接口返回结果
 *
 *  @param offset 起始位置
 *  @param count  数量
 */
- (void) getRecommandWhistleApp:(NSInteger) offset count:(NSInteger) count;


/**
 *  得到应用的详细信息，详细信息以callback形式返回，callback的第一个参数是包含详细信息的类，第二个是是否成功获取详细信息。
 *  内部实现是：第一次需要获取，获取后再保存。以后则不需要再向服务器获取。
 *
 *  @param app 应用实体类，这个类中包含简要信息
 */
- (void) getAppDetailInfo:(BaseAppInfo*) app;


/**
 *  回调的方式得到应用的详细，不用在应用页面
 *
 *  @param appid 应用的id
 */
- (void) getAppDetailInfo:(NSString*) appid callback:(void(^)(BaseAppInfo*, BOOL)) callback;

- (void) getAppDetailInfoByAppid:(NSString*) appid callback:(void(^)(BaseAppInfo*, BOOL)) callback;

/**
 *  得到一个应用的评论信息，通过getAppComments的delegate来传递
 *
 *  @param app    应用实体类
 *  @param offset 起始位置
 *  @param count  数量
 */
- (void) getAppComment:(BaseAppInfo*) app offset:(NSInteger) offset count:(NSInteger) count;


/**
 *  发表评论，评论成功或者失败由callback返回,并会重新获取下评论
 *
 *  @param app     应用实体类
 *  @param comment 评论内容
 *  @param score   分数
 */
- (void) deliverComment:(BaseAppInfo*) app comment: (NSString*) comment score:(NSInteger) score callback:(void(^)(BOOL)) callback;

/**
 *  得到我的收藏列表，收藏列表使用getMyCollectAppFinish:或者getMyCollectAppFailure返回
 *
 *  @param offset 起始位置
 *  @param count  数量
 */
- (void) getMyCollectApp:(NSInteger) offset count:(NSInteger) count;
/**
 *  添加收藏，成功或者失败由callback返回。如果成功，我的收藏列表会通过接口
 *   (void) myCollectAppListChanged:返回
 *
 *  @param app 应用的实体类
 */
- (void) add2MyCollectApp:(BaseAppInfo*) app callback:(void(^)(BOOL)) callback;
/**
 *  取消收藏，成功或者失败由callback返回。如果成功，我的收藏列表会通过接口
 *   (void) myCollectAppListChanged:返回
 *
 *  @param app 应用的实体类
 */
- (void) removeFromMyCollectApp:(BaseAppInfo*) app callback:(void(^)(BOOL)) callback;

/**
 *  得到轮转图片，callback返回图片的集合
 */
- (void) getAppCycleImage;
/**
 *  得到微哨轮转图片，callback返回图片的集合
 */
- (void) getCloudAppCycleImage;

- (void) queryApp:(NSString*) str offset:(NSInteger) offset count:(NSInteger) count;

- (void) getMenu:(NSString*) appid callback:(void(^)(NSArray*)) callback;

@end
