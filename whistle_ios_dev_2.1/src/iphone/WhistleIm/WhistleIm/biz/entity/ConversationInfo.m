//
//  ConversationInfo.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//




#import "ConversationInfo.h"
#import "JSONObjectHelper.h"
#import "ChatRecord.h"
#import "Constants.h"
#import "BizlayerProxy.h"
#import "ImUtils.h"

@interface MsgInfo()
{
    BOOL isVoice_;//语音、视频、文本混排
    BOOL isVideo_;
    BOOL isTxt_;
    BOOL isImg_;
    BOOL isCrowdVote_;
    
    NSMutableDictionary* json_;
}

@end

@implementation MsgInfo

@synthesize tmp_arr_ = _tmp_arr_;
@synthesize isPlay = _isPlay;

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        json_ = [[NSMutableDictionary alloc] initWithDictionary:jsonObj];
        isVoice_ = NO;
        isVideo_ = NO;
        isImg_ = NO;
        isTxt_ = YES;
        isCrowdVote_ = NO;
        
        self.yourcls = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_YOURCLS];
        self.style = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_STYLE];
        self.txt = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TXT];
        self.time = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TIME];
        self.stdtime = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_STDTIME defaultValue:0];

        NSString *msg_ext= [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_MSG_EXT];//说明是文件发送

        if([msg_ext isEqualToString:@"send_file"])
        {
            self.txt=@"[文件]";
        }
        
        NSDictionary* voice = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_VOICE];//存在这个字段说明是声音
        if (voice) {
            [voice enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                self.src_id = key;
                self.src = obj;
            }];
            isVoice_ = YES;
            isTxt_ = NO;
        }

        self.rowid = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_ROWID defaultValue:0];
        self.duration = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_DURATION defaultValue:-1];
        self.details = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DETAILS];

        
        NSString* isPlay = [jsonObj objectForKey:KEY_IS_PLAY];
        if (isPlay) {
            _isPlay = YES;
        }else{
            if ([JSONObjectHelper getStringFromJSONObject:jsonObj forKey:[NSString stringWithFormat:@"\"%@\"", KEY_IS_PLAY]]) {
                _isPlay = YES;
            }else{
                _isPlay = NO;
            }
        }
        
        NSDictionary* images = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_IMAGE];
        if (images && images.count > 0) {
            isImg_ = YES;
            isTxt_ = NO;
            _tmp_arr_ = [self splitTextMsg:self.txt images:images];
        }
        
        if ([KEY_CROWDVOTE isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE]]) {
            //群投票信息
            self.vid = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_VID defaultValue:0];
            static NSRegularExpression* crowd_vote_re = nil;
            if (!crowd_vote_re) {
                crowd_vote_re = [[NSRegularExpression alloc] initWithPattern:@"jid='(.+?)\\s?gid='(.+?)'" options:NSRegularExpressionCaseInsensitive error:nil];
            }
            NSArray* ret = [crowd_vote_re matchesInString:self.txt options:NSMatchingReportProgress range:NSMakeRange(0, self.txt.length)];
            for (NSTextCheckingResult* match in ret) {
                if (match.numberOfRanges == 3) {
                    self.jid = [self.txt substringWithRange:[match rangeAtIndex:1]];
                    self.gid = [self.txt substringWithRange:[match rangeAtIndex:2]];
                    isCrowdVote_ = YES;
                    isTxt_ = YES;
                    break;
                }
            }
        }
        
    }
    return self;
}

- (NSString*) encode2String:(NSDictionary*) dic
{
    NSMutableString* ret = [[NSMutableString alloc] init];
    [ret appendString:@"{"];
    __block BOOL isFrist = YES;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"json 2 string:%@", ret);
      
        
        if ([obj isKindOfClass:[NSString class]] ) {
            if (!isFrist) {
                [ret appendString:@","];
            }
            [ret appendString:@"\""];
            [ret appendString:key];
            [ret appendString:@"\":\""];
            [ret appendString:obj];
            [ret appendString:@"\""];
        }else if([obj isKindOfClass:[NSArray class]]){
//            for (id value in obj) {
//                [ret appendString:[self encode2String:value]];
//            }
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            if (!isFrist) {
                [ret appendString:@","];
            }
            [ret appendString:@"\""];
            [ret appendString:key];
            [ret appendString:@"\":"];
            [ret appendString:[self encode2String:obj]];
        }else if([obj isKindOfClass:[NSNumber class]])
        {
            if (!isFrist) {
                [ret appendString:@","];
            }
            [ret appendString:@"\""];
            [ret appendString:key];
            [ret appendString:@"\":\""];
            [ret appendString:[NSString stringWithFormat:@"%@", obj]];
            [ret appendString:@"\""];

        }
        
        isFrist = NO;
    }];
//    if ([[ret substringFromIndex:ret.length - 1] isEqualToString:@","]) {
//        [ret deleteCharactersInRange:NSMakeRange(ret.length - 1, 1)];
//    }
    [ret appendString:@"}"];
    return ret;
}

- (void) markVoiceOrVideoRead:(NSString*) rowid type:(NSString*) type
{
    if (([self isVideoMsg] || [self isVoiceMsg]) && ![self isPlay]) {
        [json_ setValue:@"1" forKey:KEY_IS_PLAY];
        if (json_) {
            NSString* tmm = [self encode2String:json_];
            [[BizlayerProxy shareInstance] replaceMsgByRowid:tmm rowid:rowid withType:type  callback:^(NSDictionary *data) {
                LOG_NETWORK_DEBUG(@"设置声音已读callback的原始数据：%@", data);
            }];
        }
    }
}

- (id) initWithTxt:(NSString*) txt
{
    self = [super init];
    if (self) {
        self.txt = txt;
        self.time = [NSString stringWithFormat:@"%@", [NSDate date]];
        self.stdtime = [[NSDate date] timeIntervalSince1970];
        self.yourcls = @"tetails";
        isTxt_ = YES;
        isImg_ = NO;
        isVideo_ = NO;
        isVoice_ = NO;
    }
    return self;
}
- (id) initWithImg:(NSString*) srcid src:(NSString*) src
{
    self = [super init];
    if (self) {
        self.time = [NSString stringWithFormat:@"%@", [NSDate date]];
        self.stdtime = [[NSDate date] timeIntervalSince1970];
        self.yourcls = @"tetails";
        self.src_id = srcid;
        self.src = src;
        isTxt_ = NO;
        isImg_ = YES;
        isVideo_ = NO;
        isVoice_ = NO;
    }
    return self;
}
- (id) initWithVoice:(NSString*) srcid src:(NSString*) src
{
    self = [super init];
    if (self) {
        self.time = [NSString stringWithFormat:@"%@", [NSDate date]];
        self.yourcls = @"tetails";
        self.stdtime = [[NSDate date] timeIntervalSince1970];
        self.src_id = srcid;
        self.src = src;
        self.txt = src;
        isTxt_ = NO;
        isImg_ = NO;
        isVideo_ = NO;
        isVoice_ = YES;
        _isPlay = YES;
    }
    return self;
}

- (id) initWithVideo:(NSString*) srcid src:(NSString*) src
{
    self = [super init];
    if (self) {
        self.time = [NSString stringWithFormat:@"%@", [NSDate date]];
        self.yourcls = @"tetails";
        self.stdtime = [[NSDate date] timeIntervalSince1970];
        self.src_id = srcid;
        self.src = src;
        isTxt_ = NO;
        isImg_ = NO;
        isVideo_ = YES;
        isVoice_ = NO;
    }
    return self;
}

- (MsgInfo*) copy_msginfo
{
    MsgInfo* msg = [[MsgInfo alloc] init];
    msg.yourcls = self.yourcls;
    msg.txt = self.txt;
    msg.time = self.time;
    msg.stdtime = self.stdtime;
    msg.rowid = self.rowid;
    msg.duration = self.duration;
    msg.details = self.details;
    msg.style = self.style;
    msg.src_id =self.src_id;
    msg.src = self.src;
    msg.stdtime = self.stdtime;
    return msg;
}

- (NSMutableArray*) splitTextMsg:(NSString*) txt images:(NSDictionary*) images
{
    NSMutableArray* ret_ = [[NSMutableArray alloc] init];
    static NSRegularExpression* rex = nil;
    if (!rex) {
        rex = [[NSRegularExpression alloc] initWithPattern:@"<img\\s+src=.+?class=(.+?)>" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    LOG_NETWORK_DEBUG(@"正则解析的字符串：%@, %@", txt, rex);
    NSArray* arr = [rex matchesInString:txt options:NSMatchingReportProgress range:NSMakeRange(0, txt.length)];
    LOG_NETWORK_DEBUG(@"正则生成的数组：%@", arr);
    int index = 0;
    for(NSTextCheckingResult* match in arr){
        int count = match.numberOfRanges;
        NSRange range = [match range];
        if(range.location > index){
            NSString* v = [txt substringWithRange:NSMakeRange(index, range.location - index)];
            if ([@"<br>" isEqualToString:v] || [@"<br><br></ul>" isEqualToString:v] || [@"<div><br></div>" isEqualToString:v]) {
                
            }else{
                MsgInfo* msg = [self copy_msginfo];
                msg.txt = v;
                [msg setIsTxtMsg];
                [ret_ addObject:msg];
            }
        }
        if (count >= 2) {
            NSString* img_id = [txt substringWithRange: [match rangeAtIndex:1]];
            __block NSString* img = nil;
            [images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* k = key;
                if ([img_id rangeOfString:k].length != 0) {
                    img = obj;
                    *stop = YES;
                }
            }];
            
            MsgInfo* msg = [self copy_msginfo];
            msg.txt = nil;
            msg.src_id = img_id;
            msg.src = img;
            [msg setIsImgMsg];
            [ret_ addObject:msg];
        }
        index = range.location + range.length;
    }
    if (index < txt.length){
        NSString* v = [txt substringWithRange:NSMakeRange(index, txt.length - index)];
        if ([@"<br>" isEqualToString:v] || [@"<br><br></ul>" isEqualToString:v]|| [@"<div><br></div>" isEqualToString:v]) {
        }else{
            MsgInfo* msg = [self copy_msginfo];
            msg.txt = v;
            [msg setIsTxtMsg];
            [ret_ addObject:msg];
        }
    }
    return ret_;
}

static const NSInteger CHAR_PER_BUBBLE = 250;
static const NSInteger EMOTION_REPLACE_CHAR = 1;//一个表情表示一个字符

//-(NSMutableArray*) splitMsg4_250char:(NSString*) msg
//{
//    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:2];
//    if (msg.length > CHAR_PER_BUBBLE) {
//        static NSRegularExpression* rex = nil;
//        if (!rex) {
//            rex = [[NSRegularExpression alloc] initWithPattern:@"<img\\bname[.+?]SystemFace[.+?]>" options:NSRegularExpressionCaseInsensitive error:nil];
//        }
//        NSMutableArray* em_arr = [[NSMutableArray alloc] init];
//        NSArray* matchs = [rex matchesInString:msg options:NSMatchingReportProgress range:NSMakeRange(0, msg.length)];
//        if (matchs && matchs.count > 0) {
            //存在表情
//            NSString* msg_copy = [msg copy];
//            NSInteger index = 0;
//            for (NSTextCheckingResult* match in matchs) {
//                NSRange range = match.range;
//                [em_arr addObject:[msg_copy substringWithRange:NSMakeRange(range.location - index, range.length)]];
//                msg_copy = [msg_copy stringByReplacingCharactersInRange:NSMakeRange(range.location - index, range.length) withString:@"й"];
//                index += range.length - 1;
//            }
//            
//            NSInteger count = msg.length / CHAR_PER_BUBBLE;
//            NSMutableArray* ret_tmp = [[NSMutableArray alloc] init];
//            int i = 0;
//            for (; i < count; ++ i) {
//                [ret_tmp addObject: [msg_copy substringWithRange:NSMakeRange(i * CHAR_PER_BUBBLE, CHAR_PER_BUBBLE)]];
//            }
//            [ret_tmp addObject:[msg_copy substringWithRange:NSMakeRange(i * CHAR_PER_BUBBLE, msg_copy.length - i * CHAR_PER_BUBBLE)]];
//            
//            i = 0;
//            for (NSString* tmp in ret_tmp) {
//                NSMutableString* tt = [[NSMutableString alloc] initWithString:tmp];
//                NSRange r = [tmp rangeOfString:@"й"];
//                while (r.length != 1) {
//                    [tt stringByReplacingCharactersInRange:r withString:(NSString*)[em_arr objectAtIndex:i]];
//                    i ++;
//                    r = [tmp rangeOfString:@"й"];
//                }
//            }
//            [ret addObject:msg];//先不做表情的解析
//        }else{
//            //不存在表情
//            NSInteger count = msg.length / CHAR_PER_BUBBLE;
//            int i = 0;
//            for (; i < count; ++ i) {
//                [ret addObject: [msg substringWithRange:NSMakeRange(i * CHAR_PER_BUBBLE, CHAR_PER_BUBBLE)]];
//            }
//            [ret addObject:[msg substringWithRange:NSMakeRange(i * CHAR_PER_BUBBLE, msg.length - i * CHAR_PER_BUBBLE)]];
//        }
//    }else{
//        [ret addObject:msg];
//    }
//    return ret;
//}

- (BOOL) isVideoMsg
{
    return isVideo_;
}

- (BOOL) isVoiceMsg
{
    return isVoice_;
}

- (BOOL) isTxtMsg
{
    return isTxt_;
}

- (BOOL) isImgMsg
{
    return isImg_;
}
- (BOOL) isCrowdVote
{
    return isCrowdVote_;
}

- (void) setIsImgMsg
{
    isImg_ = YES;
}

- (void) setIsTxtMsg
{
    isTxt_ = YES;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end


@interface ConversationInfo()
{
    BOOL isMsgHistory_;
}

@end

@implementation ConversationInfo


-(id)initFromJsonObject:(NSDictionary *)data
{
    self = [super initFromJsonObject:data];
    if(self){
        if (self.messageType) {
            //实时聊天消息
            [self initConv:data];
            isMsgHistory_ = NO;
        }else{
            //获取历史消息
            [self initConvHistory:data];
            isMsgHistory_ = YES;
        }
        self.msgInfo = [JSONObjectHelper getObjectFromJSON:self.msg withClass:[MsgInfo class]];
    }
    return  self;
}

- (void) initConv : (NSDictionary* ) data
{
    self.jid = [JSONObjectHelper getStringFromJSONObject:data forKey:SESSION_ID];
    self.messageType = [JSONObjectHelper getStringFromJSONObject:data forKey: KEY_TYPE];
    self.showName = [JSONObjectHelper getStringFromJSONObject:data forKey: KEY_SHOW_NAME];
    NSDictionary* dic = [JSONObjectHelper getJSONFromJSON:data forKey:KEY_MSG];
    self.content = [JSONObjectHelper getStringFromJSONObject:dic forKey:KEY_TXT];
    
    self.send_jid  = [JSONObjectHelper getStringFromJSONObject:data forKey: @"send_id"];
    
    data = nil;
}

- (void) initConvHistory:(NSDictionary*) data
{
    self.rowid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_ROW_ID];
    self.speaker = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_SPEAKER];
    self.isSend = [[JSONObjectHelper getStringFromJSONObject:data forKey:KEY_IS_SEND] isEqualToString:@"1"];
    self.isRead = [[JSONObjectHelper getStringFromJSONObject:data forKey:KEY_IS_READ] isEqualToString:@"1"] ? YES : NO;
    self.time = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_DATETIME];
    self.showName = [JSONObjectHelper getStringFromJSONObject:data forKey: KEY_SHOW_NAME];
    self.jid = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_JID];
    [self initCrowdConvHistory:data];
    data = nil;
}

- (id) copy_conversation_
{
    ConversationInfo* msg = [[ConversationInfo alloc] init];
    msg.jid = [self.jid copy];
    msg.showName = [self.showName copy];
    msg.time = [self.time copy];
    msg.content = [self.content copy];
    msg.conversationType = [self.conversationType copy];
    msg.jsonObj = [self.jsonObj copy];
    msg.from_jid = [self.from_jid copy];
    msg.send_jid = [self.send_jid copy];
    msg.speaker = [self.speaker copy];
    msg.crowd_name = [self.crowd_name copy];
    msg.extraInfo = self.extraInfo;
    msg.crowdOrDiscussion = self.crowdOrDiscussion;
    msg.messageType = [self.messageType copy];
    msg.isSend = self.isSend;
    return msg;
}

- (void) initCrowdConvHistory:(NSDictionary*) data
{
    self.crowd_name = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_CROWD_NAME];
}

- (BOOL) isMsgHistory
{
    return isMsgHistory_;
}

+ (NSArray*) split:(ConversationInfo *)info
{
    NSMutableArray* ret = [[NSMutableArray alloc] initWithCapacity:5];
    if (info.msgInfo.tmp_arr_) {
        //包含多个图片和文本的混排，需要拆分
        for (MsgInfo* msg in info.msgInfo.tmp_arr_) {
            ConversationInfo* conv = [info copy_conversation_];
            conv.msgInfo = msg;
            if ([msg isImgMsg] && ![[NSFileManager defaultManager] fileExistsAtPath:[ImUtils getVacrdImagePath:msg.src]]) {
                conv.status = MSG_RECVING;
            }else if([msg isTxtMsg]){
                conv.status = MSG_RECV_SUCCUSS;
            }
            [ret addObject:conv];
        }
    }else{
        [ret addObject:info];
    }
    //文字超过250字符分隔
    
//    NSMutableArray* ret_split = [[NSMutableArray alloc] initWithCapacity:ret.count];
//    for (ConversationInfo* con in ret) {
//        if ([con.msgInfo isTxtMsg]) {
//            NSArray* str_arr = [con.msgInfo splitMsg4_250char:info.msgInfo.txt];
//            if (str_arr.count <= 1) {
//                [ret_split addObjectsFromArray:[con.msgInfo splitMsg4_250char:info.msgInfo.txt]];
//            }else{
//                for (NSString* txt in str_arr) {
//                    ConversationInfo* conv = [con copy_conversation_];
//                    MsgInfo* msg = [con.msgInfo copy_msginfo];
//                    msg.txt = txt;
//                    [msg setIsTxtMsg];
//                    conv.msgInfo = msg;
//                    [ret_split addObject:conv];
//                }
//            }
//
//        }else{
//            [ret_split addObject:con];
//        }
//    }

    return ret;
}

- (void) markVoiceOrVideoRead
{
    if (self.isSend) {
        
    }else{
        [self.msgInfo markVoiceOrVideoRead:self.rowid type:self.messageType];
    }

}

- (NSString*) toString
{
    return [super toString:self];
}

@end
