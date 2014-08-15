//
//  BaseAppInfo.h
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"


@interface AppCommentItem : Entity<Jsonable>
@property (nonatomic, strong) NSString* comment_jid;
@property (nonatomic, strong) NSString* comment_name;
@property (nonatomic, strong) NSString* comment_organization;
@property (nonatomic, strong) NSString* comment_text;
@property (nonatomic) NSInteger comment_score;
@property (nonatomic, strong) NSString* comment_addTime;
@property (nonatomic, strong) NSString* comment_addTimeFormat;

@property (nonatomic, weak) id extraInfo;

@end

@interface AppCommentInfo : Entity<Jsonable>
//评论
@property (nonatomic) BOOL isCommented; //是否讨论过该应用
@property (nonatomic) NSInteger comment_total;//评论总数
@property (nonatomic, strong, readonly) NSMutableArray* comments;//评论数据集合
@property (nonatomic) NSUInteger statistics_total;//总评分
@property (nonatomic) NSUInteger average;//平均分
@property (nonatomic) NSUInteger scroe_5;
@property (nonatomic) NSUInteger scroe_4;
@property (nonatomic) NSUInteger scroe_3;
@property (nonatomic) NSUInteger scroe_2;
@property (nonatomic) NSUInteger scroe_1;

- (void) appendComments:(NSDictionary*) data;

@end

/**
 *  应用的父类，包含共用的属性和方法。其子类主要有本地应用、轻应用和Web应用
 */
@interface BaseAppInfo : Entity<Jsonable>

@property (nonatomic, strong) NSString* appName;
@property (nonatomic, strong) NSString* appIcon_large_url_;
@property (nonatomic, strong) NSString* appIcon_middle_url_;
@property (nonatomic, strong) NSString* appIcon_large;
@property (nonatomic, strong) NSString* appIcon_middle;
@property (nonatomic, strong) NSString* appCode;
@property (nonatomic, strong) NSString* type;
@property (nonatomic) BOOL isCollection;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* describe;
@property (nonatomic) NSInteger popularity;
@property (nonatomic, strong) NSString* app_secret;
@property (nonatomic)  BOOL  isSchoolOfficial;
@property (nonatomic, strong) NSString* modifyTime;
@property (nonatomic) BOOL isSupport;//是否点击了合格按钮

@property (nonatomic) NSInteger score_total;
@property (nonatomic) NSInteger score_times;
@property (nonatomic) NSInteger score_average;

@property (nonatomic, strong) NSString* sale_startTime;
@property (nonatomic, strong) NSString* sale_endTime;

@property (nonatomic, strong) NSString* developer_jid;
@property (nonatomic, strong) NSString* developer_name;
@property (nonatomic, strong) NSString* developer_organization;

@property (nonatomic, strong) AppCommentInfo* comment;

//应用详情中部分字段
@property (nonatomic, strong) NSMutableArray* screenshot_url_;
@property (nonatomic, strong) NSMutableArray* screenshot;
@property (nonatomic, strong) NSString* recommend_icon_url_;
@property (nonatomic, strong) NSString* recommend_icon;
@property (nonatomic, strong) NSString* category;
@property (nonatomic) BOOL isWhistle;

@property (nonatomic, strong) NSString* status;//应用状态

- (BOOL) isLightApp;
- (BOOL) isNativeApp;
- (BOOL) isWebApp;

//应用状态
- (BOOL) isDelete;//删除
- (BOOL) isDevelopment;//开发
- (BOOL) isTesting;//测试
- (BOOL) isOpening;//开放
- (BOOL) isRecommend;//推荐

- (void) appendDetailInfo:(NSDictionary*) data;

- (void) appendCommentInfo:(NSDictionary*) data;

@end
