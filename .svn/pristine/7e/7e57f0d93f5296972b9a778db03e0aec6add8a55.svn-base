//
//  BaseAppInfo.m
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "BaseAppInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"




@implementation AppCommentItem


- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.comment_jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_JID];
        self.comment_name = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_NAME];
        self.comment_organization = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_organization];
        self.comment_text = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_COMMENT];
        self.comment_score = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_SCORE defaultValue:0];
        self.comment_addTime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ADD_TIME];
        self.comment_addTimeFormat = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ADD_TIME_FORMAT];
    }
    return self;
}

@end

@implementation AppCommentInfo

@synthesize comments = _comments;

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.comment_total = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_TOTAL defaultValue:0];
        self.isCommented = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_ISCOMMENT defaultValue:0] == 1 ? YES : NO;
        NSMutableArray* comments = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:KEY_LIST_DATA withClass:[AppCommentItem class]];
        if (_comments) {
            [_comments addObjectsFromArray:comments];
            //这里可能需要有个排序
        }else{
            _comments = comments;
        }
        NSDictionary* statistics = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_STATISTICS];
        self.statistics_total = [JSONObjectHelper getIntFromJSONObject:statistics forKey:KEY_TOTAL defaultValue:0];
        self.average = [JSONObjectHelper getIntFromJSONObject:statistics forKey:KEY_AVERAGE defaultValue:0];
        NSDictionary* scroe = [JSONObjectHelper getJSONFromJSON:statistics forKey:KEY_SCORE];
        self.scroe_1 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_1 defaultValue:0];
        self.scroe_2 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_2 defaultValue:0];
        self.scroe_3 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_3 defaultValue:0];
        self.scroe_4 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_4 defaultValue:0];
        self.scroe_5 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_5 defaultValue:0];
    }
    return self;
}

- (void) appendComments:(NSDictionary *)jsonObj
{
    self.comment_total = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_TOTAL defaultValue:0];
    self.isCommented = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_ISCOMMENT defaultValue:0] == 1 ? YES : NO;
    NSMutableArray* comments = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:KEY_LIST_DATA withClass:[AppCommentItem class]];
    if (_comments) {
        [_comments addObjectsFromArray:comments];
        //这里可能需要有个排序
    }else{
        _comments = comments;
    }
    NSDictionary* statistics = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_STATISTICS];
    self.statistics_total = [JSONObjectHelper getIntFromJSONObject:statistics forKey:KEY_TOTAL defaultValue:0];
    self.average = [JSONObjectHelper getIntFromJSONObject:statistics forKey:KEY_AVERAGE defaultValue:0];
    NSDictionary* scroe = [JSONObjectHelper getJSONFromJSON:statistics forKey:KEY_SCORE];
    self.scroe_1 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_1 defaultValue:0];
    self.scroe_2 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_2 defaultValue:0];
    self.scroe_3 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_3 defaultValue:0];
    self.scroe_4 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_4 defaultValue:0];
    self.scroe_5 = [JSONObjectHelper getIntFromJSONObject:scroe forKey:KEY_5 defaultValue:0];
}

@end

@implementation BaseAppInfo

/*
 {"total":1,"list_data":[{"app_name":"hulala","app_code":"","url":"http://hulala.duapp.com","type":"lightapp","describe":"报时","popularity":0,"recommend":0,"iscollection":0,"custom_info":[],"icon":{"pc":{"large":"http://172.16.56.103/image/13883739801000.png","middle":"http://172.16.56.103/image/1388374171999.png","small":"http://172.16.56.103/image/1388374021999.png"},"android":{"large":"http://172.16.56.103/image/1388373988999.png","middle":"http://172.16.56.103/image/13883740011000.png"},"ios":{"large":"http://172.16.56.103/image/1388373994999.png","middle":"http://172.16.56.103/image/13883739981000.png"}},"open_with":[],"developer":{"jid":0,"name":"校方应用","organization":"开发联调组织"},"score":{"total":0,"times":0,"average":0}}]}
 */
- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.appName = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_NAME];
        self.appCode = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_CODE];
        self.type = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE];
        self.url = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_URL];
        self.isCollection = ([JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_ISCOLLECTION defaultValue:0] == 1);
        NSDictionary* icon_dic = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_ICON];
        NSDictionary* ios_icon_dic = [JSONObjectHelper getJSONFromJSON:icon_dic forKey:KEY_IOS];
        self.appIcon_large_url_ = [JSONObjectHelper getStringFromJSONObject:ios_icon_dic forKey:KEY_LARGE];
        self.appIcon_middle_url_ = [JSONObjectHelper getStringFromJSONObject:ios_icon_dic forKey:KEY_MIDDLE];
        self.describe = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DESCRIBE];
        
        NSDictionary* score = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_SCORE];
        self.score_total = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_TOTAL defaultValue:0];
        self.score_times = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_TIMES defaultValue:0];
        self.score_average = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_AVERAGE defaultValue:0];
        
        NSDictionary* developer = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_DEVELOPER];
        self.developer_jid = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_JID];
        self.developer_name = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_NAME];
        self.developer_organization = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_organization];
        
        //    self.screenshot_url_ = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:KEY_SCREENSHOT withClass:[NSString class]];
        NSMutableArray* scr_url_ = [jsonObj valueForKey:KEY_SCREENSHOT];
        if ([scr_url_ isKindOfClass:[NSArray class]]) {
            self.screenshot_url_ = scr_url_;
        }
        self.isSupport = [KEY_1 isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ISSUPPORT]];
        self.category = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_CATEGORY];
        self.isWhistle = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_IS_WHISTLE defaultValue:0] == 1 ? YES : NO;
        self.recommend_icon_url_ = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_RECOMMEND_ICON];
        self.app_secret = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_SECRET];
        self.isSchoolOfficial = [@"1" isEqualToString:[JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_SCHOOL_OFFICIAL]] ? YES : NO;
        NSDictionary* onsale = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_ONSALE];
        NSDictionary* onsale_ios = [JSONObjectHelper getJSONFromJSON:onsale forKey:KEY_IOS];
        static NSDateFormatter *formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat : @"M/d/yyyy h:m a"];
        }
        NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:[JSONObjectHelper getIntFromJSONObject:onsale_ios forKey:KEY_start_time defaultValue:0]];
        self.sale_startTime = [formatter stringFromDate:date];
        date = [[NSDate alloc] initWithTimeIntervalSince1970:[JSONObjectHelper getIntFromJSONObject:onsale_ios forKey:KEY_END_TIME defaultValue:0]];
        self.sale_endTime = [formatter stringFromDate:date];
        
        int mt = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_MODIFY_TIME defaultValue:0];
        date = [[NSDate alloc] initWithTimeIntervalSince1970:(double)mt];
        self.modifyTime = [formatter stringFromDate:date];
        self.status = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_STATUS];
    }
    return self;
}

- (void) decodeData:(NSDictionary*) jsonObj
{
    self.appName = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_NAME];
    self.appCode = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_APP_CODE];
    self.type = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TYPE];
    self.url = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_URL];
    self.isCollection = [@"1" isEqualToString: [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_IS_COLLECTION]] ? YES : NO;
    NSDictionary* icon_dic = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_ICON];
    NSDictionary* ios_icon_dic = [JSONObjectHelper getJSONFromJSON:icon_dic forKey:KEY_IOS];
    self.appIcon_large_url_ = [JSONObjectHelper getStringFromJSONObject:ios_icon_dic forKey:KEY_LARGE];
    self.appIcon_middle_url_ = [JSONObjectHelper getStringFromJSONObject:ios_icon_dic forKey:KEY_MIDDLE];
    self.describe = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DESCRIBE];
    
    NSDictionary* score = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_SCORE];
    self.score_total = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_TOTAL defaultValue:0];
    self.score_times = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_TIMES defaultValue:0];
    self.score_average = [JSONObjectHelper getIntFromJSONObject:score forKey:KEY_AVERAGE defaultValue:0];
    
    NSDictionary* developer = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_DEVELOPER];
    self.developer_jid = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_JID];
    self.developer_name = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_NAME];
    self.developer_organization = [JSONObjectHelper getStringFromJSONObject:developer forKey:KEY_organization];
    
//    self.screenshot_url_ = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:KEY_SCREENSHOT withClass:[NSString class]];
    NSMutableArray* scr_url_ = [jsonObj valueForKey:KEY_SCREENSHOT];
    if ([scr_url_ isKindOfClass:[NSArray class]]) {
        self.screenshot_url_ = scr_url_;
    }
    
    self.category = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_CATEGORY];
    self.isWhistle = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_IS_WHISTLE defaultValue:0] == 1 ? YES : NO;
    self.recommend_icon_url_ = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_RECOMMEND_ICON];
}

- (BOOL) isLightApp
{
    if ([@"lightapp" isEqualToString:self.type]) {
        return YES;
    }
    return NO;
}

- (BOOL) isNativeApp
{
    if ([@"native" isEqualToString:self.type]) {
        return YES;
    }
    return NO;
}

- (BOOL) isWebApp
{
    if ([@"websso" isEqualToString:self.type]) {
        return YES;
    }
    return NO;
}

- (BOOL) isDelete
{
    return [KEY_DELETE isEqualToString:self.status];
}

- (BOOL) isDevelopment
{
    return [KEY_DEVELOPMENT isEqualToString:self.status];
}

- (BOOL) isTesting
{
    return [KEY_TESTING isEqualToString:self.status];
}

- (BOOL) isOpening
{
    return [KEY_OPENING isEqualToString:self.status];
}

- (BOOL) isRecommend
{
    return [KEY_RECOMMEND isEqualToString:self.status];
}

- (void) appendDetailInfo:(NSDictionary *)data
{
    [self decodeData:data];
}

- (void) appendCommentInfo:(NSDictionary *)data
{
    AppCommentInfo* comment = [JSONObjectHelper getObjectFromJSON:data withClass:[AppCommentInfo class]];
    self.comment = comment;
}

- (NSDictionary*) encode
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tmp addEntriesFromDictionary:[super encode]];
    [tmp addEntriesFromDictionary:[self encode:self classType:[BaseAppInfo class]]];
    return tmp;
}

//- (NSString*) toString
//{
//    return [super toString:self];
//}

@end
