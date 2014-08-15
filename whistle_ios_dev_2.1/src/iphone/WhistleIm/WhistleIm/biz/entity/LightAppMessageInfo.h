//
//  LightAppMessageInfo.h
//  WhistleIm
//
//  Created by liuke on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "BaseMessageInfo.h"

@interface LightAppNewsMessageInfo : Entity<Jsonable>
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* picUrl;//图片链接
@property (nonatomic, strong) NSString* url;//图文消息跳转链接
@end

@interface LightAppMessageInfo : BaseMessageInfo

@property (nonatomic, strong) NSString* lightappType;//text/music/news
@property (nonatomic, strong) NSString* createtime;
@property (nonatomic, strong) NSString* msg_id;

@property (nonatomic, strong) NSString* image;//发送时需要，接收时没有这个属性
@property (nonatomic, assign) BOOL isDownload;//发送时需要，接收时没有这个属性

@property (nonatomic, strong) NSString* voice;//声音
@property (nonatomic) NSUInteger voiceLength;
//文本
@property (nonatomic, strong) NSString* content;

//声音
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* hqUrl;

//新闻
@property (nonatomic) NSInteger articleCount;
@property (nonatomic, strong, readonly) NSMutableArray* articles;//LightAppNewsMessageInfo的集合

//历史消息
@property (nonatomic, strong) NSString* dt;
@property (nonatomic, strong) NSString* ntime;

@property (nonatomic, strong) id lightappDetail;

@property (nonatomic) CGSize size_;
@property (nonatomic, strong) NSMutableAttributedString* attr_;

- (id) init4Json:(NSDictionary *)jsonObj;

- (id) init4Text:(NSString*) appid txt: (NSString*) content;

- (id) init4Image:(NSString*) appid image:(NSString*) imgPath;

- (id) init4Voice:(NSString*) appid voice:(NSString*) voicePath length:(NSUInteger) length;
//
//- (id) init4Localtion:(float) x y:(float) y z:(float) z scale:(float) scale label:(NSString*) label;
//
//- (id) init4Link:(NSString*) title description:(NSString*) description url:(NSString*) url;
//
//- (id) init4Event:(NSString*) event eventKey:(NSString*) eventkey;

@end
