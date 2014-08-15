//
//  LightAppMessageInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LightAppMessageInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation LightAppNewsMessageInfo

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.title = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_title];
        self.description = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DESCRIPTION];
        self.picUrl = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_PIC_URL];
        self.url = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_URL];
    }
    return self;
}

- (NSString*) toString
{
    return [super toString:self];
}

@end

@implementation LightAppMessageInfo

@synthesize articles = _articles;

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    if ([jsonObj valueForKey:KEY_MSG]) {
        self = [super initFromJsonObject:jsonObj];
        if (self) {
            self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APPID];
            self.msg_id = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_MSG_ID];
            self.lightappType = [JSONObjectHelper getStringFromJSONObject:self.msg forKey:KEY_TYPE];
            self.createtime = [JSONObjectHelper getStringFromJSONObject:self.msg forKey:KEY_CREATETIME];
            if (!(self.createtime) || [@"" isEqualToString:self.createtime]) {
                self.createtime = [NSString stringWithFormat:@"%d", (NSUInteger)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970];
            }
            if ([KEY_TEXT isEqualToString:self.lightappType]) {
                //文本类型
                self.content = [JSONObjectHelper getStringFromJSONObject:self.msg forKey:KEY_CONTENT];
            }else if ([KEY_MUSIC isEqualToString:self.lightappType]) {
                //音乐类型
                NSDictionary* music = [JSONObjectHelper getJSONFromJSON:self.msg forKey:KEY_MUSIC];
                self.title = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_title];
                self.description = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_DESCRIPTION];
                self.url = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_MUSICURL];
                self.hqUrl = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_HQMUSICURL];
            }else if ([KEY_NEWS isEqualToString:self.lightappType]){
                //新闻类型
                NSDictionary* news = [JSONObjectHelper getJSONFromJSON:self.msg forKey:KEY_NEWS];
                self.articleCount = [JSONObjectHelper getIntFromJSONObject:news forKey:KEY_ARTICLECOUNT defaultValue:0];
                _articles = [JSONObjectHelper getObjectArrayFromJsonObject:news forKey:KEY_ARTICLES withClass:[LightAppNewsMessageInfo class]];
            }else if ([KEY_IMAGE isEqualToString:self.lightappType]){
                NSDictionary *dic = [jsonObj valueForKey:KEY_MSG];
                self.image = [[JSONObjectHelper getStringFromJSONObject:dic forKey:KEY_IMAGE] componentsSeparatedByString:@"/"].lastObject;
                //新闻类型
//                NSDictionary* news = [JSONObjectHelper getJSONFromJSON:self.msg forKey:KEY_NEWS];
//                self.articleCount = [JSONObjectHelper getIntFromJSONObject:news forKey:KEY_ARTICLECOUNT defaultValue:0];
//                _articles = [JSONObjectHelper getObjectArrayFromJsonObject:news forKey:KEY_ARTICLES withClass:[LightAppNewsMessageInfo class]];
            }
            
            self.rowid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ROWID];
            self.isSend =( 1 == [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_IS_SEND defaultValue:0]);//[@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_SEND]] ? YES : NO;
            self.isRead = [@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_READ]] ? YES : NO;
            self.dt = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DT];
            self.ntime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_NTIME];
            if (!(self.ntime) || [@"" isEqualToString:self.ntime]) {
                self.ntime = [NSString stringWithFormat:@"%d", (NSUInteger)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970];
            }
        }

    }else{
        return [self init4Json:jsonObj];
    }
    return self;
}

- (id) init4Json:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APPID];
        self.lightappType = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE];
        self.createtime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_CREATETIME];
        if ([KEY_TEXT isEqualToString:self.lightappType]) {
            //文本类型
            self.content = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_CONTENT];
        }else if ([KEY_MUSIC isEqualToString:self.lightappType]) {
            //音乐类型
            NSDictionary* music = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_MUSIC];
            self.title = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_title];
            self.description = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_DESCRIPTION];
            self.url = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_MUSICURL];
            self.hqUrl = [JSONObjectHelper getStringFromJSONObject:music forKey:KEY_HQMUSICURL];
        }else if ([KEY_NEWS isEqualToString:self.lightappType]){
            //新闻类型
            NSDictionary* news = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_NEWS];
            self.articleCount = [JSONObjectHelper getIntFromJSONObject:news forKey:KEY_ARTICLECOUNT defaultValue:0];
            _articles = [JSONObjectHelper getObjectArrayFromJsonObject:news forKey:KEY_ARTICLES withClass:[LightAppNewsMessageInfo class]];
        }else if ([KEY_VOICE isEqualToString:self.lightappType]){
            self.voice = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_VOICE];
            self.voiceLength = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_VOICE_LENGTH defaultValue:0];
        }else if ([KEY_IMAGE isEqualToString:self.lightappType]){
            //新闻类型
            //                NSDictionary* news = [JSONObjectHelper getJSONFromJSON:self.msg forKey:KEY_NEWS];
            //                self.articleCount = [JSONObjectHelper getIntFromJSONObject:news forKey:KEY_ARTICLECOUNT defaultValue:0];
            //                _articles = [JSONObjectHelper getObjectArrayFromJsonObject:news forKey:KEY_ARTICLES withClass:[LightAppNewsMessageInfo class]];
        }
        self.rowid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ROWID];
        self.isSend = ( 1 == [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_IS_SEND defaultValue:0]);//[@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_SEND]] ? YES : NO;
        self.isRead = [@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_READ]] ? YES : NO;
        self.dt = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DT];
        self.ntime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_NTIME];
    }
    return self;

}

- (id) init4Text:(NSString *)appid txt:(NSString *)content
{
    self = [super init];
    if (self) {
        self.lightappType = KEY_TEXT;
        self.content = content;
        self.isSend = YES;
        self.jid = appid;
        self.ntime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

- (id) init4Image:(NSString *)appid image:(NSString *)imgPath
{
    self = [super init];
    if (self) {
        self.lightappType = KEY_IMAGE;
        self.image = imgPath;
        self.jid = appid;
        self.isSend = YES;
        self.ntime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

- (id) init4Voice:(NSString *)appid voice:(NSString *)voicePath length:(NSUInteger)length
{
    self = [super init];
    if (self) {
        self.lightappType = KEY_VOICE;
        self.voice = voicePath;
        self.jid = appid;
        self.isSend = YES;
        self.voiceLength = length;
        self.ntime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

//
//- (id) init4Link:(NSString *)title description:(NSString *)description url:(NSString *)url
//{
//    self = [super init];
//    if (self) {
//        self.lightappType = KEY_LINK;
//        self.;
//    }
//    return self;
//}

- (NSString*) toString
{
    return [super toString:self];
}







@end
