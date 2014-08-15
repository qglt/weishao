//
//  ChatRecordForNotice.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "ChatRecordForNotice.h"
#import "NoticeInfo.h"
#import "JSONObjectHelper.h"
#import "BizlayerProxy.h"

@implementation ChatRecordForNotice

@synthesize noticeInfo;

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super initFromJsonObject:jsonObj];
    
    if(self){
        NSDictionary *msgJSON = nil;
    
        if([self.msg isKindOfClass:[NSDictionary class]]){
            msgJSON = (NSDictionary *)self.msg;
        
        }else{
            msgJSON = [JSONObjectHelper decodeJSON:[self.msg description]];
        }
        
        
        self.noticeInfo = [[NoticeInfo alloc] initFromJsonObject:msgJSON];
        
        if (!(self.noticeInfo.noticeId)) {
            self.noticeInfo.noticeId = self.jid;
        }
        if (!(self.noticeInfo.signature)) {
            self.noticeInfo.signature = self.showName;
        }
        if (!(self.noticeInfo.expiredTime)) {
            self.noticeInfo.expiredTime = self.dt;
        }
        
        //[JSONObjectHelper releaseJson:jsonObj];
        jsonObj = nil;
        
    }
    
    return self;
}

-(void)markRead:(void(^)(BOOL)) callback
{
    WhistleCommandCallbackType  markReadCallback = ^(NSDictionary *result){
        ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
        if(resultInfo.succeed){
            self.isRead = YES;
            callback(YES);
        }else{
            callback(NO);
        }
        result = nil;
    };
    if(!self.isRead){
        [[BizlayerProxy shareInstance] getNoticeDetailInfoAndMarkReaded:self.jid  withListener:markReadCallback];
    }
    
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
