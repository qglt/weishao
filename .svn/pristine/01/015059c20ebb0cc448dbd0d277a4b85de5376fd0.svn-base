//
//  ConversationInfo.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"
#import "BaseMessageInfo.h"


@interface MsgInfo : Entity<Jsonable>
- (id) initWithTxt:(NSString*) txt;
- (id) initWithImg:(NSString*) srcid src:(NSString*) src;
- (id) initWithVoice:(NSString*) srcid src:(NSString*) src;
- (id) initWithVideo:(NSString*) srcid src:(NSString*) src;
//这里以后需要对txt属性中的图文进行分析，找个合适的方式来表现
@property (nonatomic, strong) NSString* yourcls;
//如果是文本类型，则是文本或者表情的字符串；如果是图片类型，则是图片的路径,但是得需要下载本地后才有
@property (nonatomic, strong) NSString* txt;
@property (nonatomic, strong) NSString* time;
@property (nonatomic) long stdtime;
@property (nonatomic) NSInteger rowid;
@property (nonatomic) NSInteger duration;
@property (nonatomic, strong) NSString* details;
@property (nonatomic, strong) NSString* style;
@property (nonatomic, strong) NSString* src_id;
@property (nonatomic, strong) NSString* src;
@property (nonatomic, readonly) BOOL isPlay;//语音或者视频是否播放过
@property (nonatomic, assign) BOOL isDownload;//语音或者视频是否播放过
//群投票
@property (nonatomic) NSInteger vid;
@property (nonatomic, strong) NSString* gid;
@property (nonatomic, strong) NSString* jid;

@property (nonatomic, strong, readonly) NSMutableArray* tmp_arr_;//仅供内部使用

- (BOOL) isVoiceMsg;

- (BOOL) isVideoMsg;

- (BOOL) isTxtMsg;//包括表情和文字

- (BOOL) isImgMsg;//图片

- (BOOL) isCrowdVote;

- (void) setIsImgMsg;//仅供内部使用

- (void) setIsTxtMsg;//仅供内部使用

- (void) markVoiceOrVideoRead:(NSString*) rowid type:(NSString*) type;

//- (NSMutableArray*) splitMsg4_250char:(NSString*) msg;

@end

@interface ConversationInfo : BaseMessageInfo

@property (nonatomic,strong) NSString *showName;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *conversationType;
@property (nonatomic,strong) NSDictionary *jsonObj;
@property (nonatomic, strong) NSString* from_jid;
@property (nonatomic, strong) NSString* send_jid;
@property (nonatomic, strong) NSString* speaker;
//@property (nonatomic, strong) NSString* alert;

@property (nonatomic, strong) MsgInfo* msgInfo;
@property (nonatomic, strong) NSString* crowd_name;

@property (nonatomic, strong) id extraInfo;//好友信息
@property (nonatomic, strong) id crowdOrDiscussion;

//供界面使用的属性
@property (nonatomic) CGSize size_;
@property (nonatomic, strong) NSMutableAttributedString* attr_;

- (BOOL) isMsgHistory;

+ (NSArray*) split:(ConversationInfo*) info;

- (id) copy_conversation_;

- (void) markVoiceOrVideoRead;

@end
