//
//  SystemMessageInfo.m
//  WhistleIm
//
//  Created by wangchao on 13-8-14.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemMessageInfo.h"
#import "JSONObjectHelper.h"
#import "BizlayerProxy.h"
#import "Constants.h"
#import "FriendInfo.h"

@interface SystemMessageInfo()
{
//    BOOL isRead_;
    NSDictionary* txtDic_;
    int isAnswer_;//负数表示未设置，0表示回答拒绝，1表示回答同意
}

@end

@implementation SystemMessageInfo 

@synthesize isRead = _isRead;

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [self init];
    if(self){
        isAnswer_ = -1;
        if (jsonObj && [jsonObj count] > 0) {
            [self creatSystemMessageInfo:jsonObj];
            jsonObj = nil;
        }else{
            return nil;
        }
    }
    
    return self;
}

-(void)creatSystemMessageInfo:(NSDictionary *)jsonObj
{
    LOG_GENERAL_INFO(@"系统消息：%@", jsonObj);
    self.time = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_TIME];
    self.msgType = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_MSG_TYPE];
    self.serverTime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_SERVER_TIME];
    self.extraInfo = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_EXTRA_INFO];
    self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_JID];
    self.date = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_DATE];
    self.rowId = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ROWID];
    self.info = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_INFO];
    self.lastTime = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_LAST_TIME];
    self.isRead = ([JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_IS_READ defaultValue:0] == 1);
    NSDictionary* info_dic = [JSONObjectHelper decodeJSON:self.info];
    if (info_dic && [self isCrowdSystemMsg]) {
        self.actor_name = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_ACTOR_NAME];
        self.actor_jid = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_ACTOR_JID];
        self.name = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_NAME];
        self.name_jid = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_NAME_JID];
        self.crowd_name = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_CROWD_NAME];
        self.category = [[JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_CATEGORY] integerValue];
        self.icon = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_ICON];
        self.txt = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_TXT];
        self.result = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_RESULT];
        self.reason = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_REASON];
        self.remark = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_REMARK];
        self.actor_sex = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_ACTOR_SEX];
        self.actor_identity = [JSONObjectHelper getStringFromJSONObject:info_dic forKey:KEY_ACTOR_IDENTITY];
    }else{
        NSDictionary* tmp = [JSONObjectHelper decodeJSON:self.info];
        if ([tmp isKindOfClass:[NSDictionary class]]) {
            NSString* str = [JSONObjectHelper getStringFromJSONObject:tmp forKey:KEY_INFO];
            if (str) {
                self.info = str;
            }
            str = nil;
        }
    }
}



/*
 字典内容组成：
 "result":"$1同意$2加入$3"
 "$1":{"txt":"显示内容" jid="jid"}
 "$2":{"txt":"显示内容" jid="jid"}
 "$3":{"txt":"显示内容" jid="jid"}
 
 */
- (NSDictionary*) getCrowdContent
{
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    
    if ([CROWD_SYS_MSG_CREATE_CROWD isEqualToString:self.msgType]) {
        [ret setObject:[NSString stringWithFormat: @"你成功创建了%@群", self.crowd_name] forKey:@"result"];
//        return [NSString stringWithFormat: @"你成功创建了%@群", self.crowd_name];
    } else if ([CROWD_SYS_MSG_DISMISS isEqualToString:self.msgType]
               || [CROWD_SYS_MSG_DISMISS_SUCESS isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"%@群已经被解散", self.crowd_name] forKey:@"result"];
//        return [NSString stringWithFormat: @"%@群已经被解散", self.crowd_name];
    } else if ([CROWD_SYS_MSG_INVITED_BY_CROWD isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1邀请你加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic forKey:@"$1"];
//        return [NSString stringWithFormat: @"%@邀请你加入%@", self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_INVATED_ACCEPT_SELF isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1同意了你的邀请加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic forKey:@"$1"];
//        return [NSString stringWithFormat: @"%@同意了你的邀请加入%@", self.name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_ANSWER_INVATED_DENY_SELF isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1拒绝你的邀请加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self.name , @"txt", self.name_jid, @"jid", nil];
        [ret setObject:dic forKey:@"$1"];
//        return [NSString stringWithFormat: @"%@拒绝你的邀请加入%@", self.name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_ANSWER_CROWD_INVITE_ACCEPT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1已同意$2的邀请加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.name , @"txt", self.name_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        NSDictionary* dic_2 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_2 forKey:@"$2"];

//        return [NSString stringWithFormat: @"%@已同意%@的邀请加入%@", self.name, self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_CROWD_APPLY_ACCEPT_ADMIN_OTHER isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1已同意$2加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        NSDictionary* dic_2 = [NSDictionary dictionaryWithObjectsAndKeys: self.name , @"txt", self.name_jid, @"jid", nil];
        [ret setObject:dic_2 forKey:@"$2"];
//        return [NSString stringWithFormat: @"%@已同意%@加入%@", self.actor_name, self.name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_CROWD_DEMISE isEqualToString:self.msgType]){
        [ret setObject: @"$1将超级管理员转让给你" forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];

        
//        return [NSString stringWithFormat: @"%@将超级管理员转让给你", self.actor_name];
    } else if ([CROWD_SYS_MSG_INVATE_ACCEPT isEqualToString:self.msgType]){
//        [ret setObject:[NSString stringWithFormat: @"你已同意$1的邀请加入%@", self.crowd_name] forKey:@"result"];
//        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
//        [ret setObject:dic_1 forKey:@"$1"];

        [ret setObject:[NSString stringWithFormat: @"$1邀请你加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic forKey:@"$1"];
        self.isAgree = YES;
        
    } else if ([CROWD_SYS_MSG_ACCEPT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"你的群邀请已被接受"] forKey:@"result"];
        
//        return [NSString stringWithFormat: @"你的群邀请已被接受"];
    } else if ([CROWD_SYS_MSG_INVATE_DENY isEqualToString:self.msgType]){
//        [ret setObject: @"你已拒绝$1的邀请" forKey:@"result"];
//        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
//        [ret setObject:dic_1 forKey:@"$1"];

        [ret setObject:[NSString stringWithFormat: @"$1邀请你加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic forKey:@"$1"];
        self.isAgree = NO;
        
    } else if ([CROWD_SYS_MSG_APPLY isEqualToString:self.msgType]){
        [ret setObject: @"你的申请已经发送成功，等待管理员验证" forKey:@"result"];
        
//        return [NSString stringWithFormat: @"你的申请已经发送成功，等待管理员验证。"];
    } else if ([CROWD_SYS_MSG_APPLY_AUTHEN isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1申请加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
//        return [NSString stringWithFormat: @"%@申请加入%@", self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_APPLY_ACCEPT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1已同意你加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
//        return [NSString stringWithFormat: @"%@已同意你加入%@", self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_APPLY_NOT_ACCEPT isEqualToString:self.msgType]){
        [ret setObject: @"$1拒绝了你的申请" forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
//        return [NSString stringWithFormat: @"%@拒绝了你的申请", self.actor_name];
    } else if ([CROWD_SYS_MSG_AUTH_ACCEPT_ADMIN isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1加入%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
//        return [NSString stringWithFormat: @"%@加入%@", self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_AUTH_ACCEPT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"你已加入群%@", self.crowd_name] forKey:@"result"];
        
//        return [NSString stringWithFormat: @"你已加入群%@", self.crowd_name];
    } else if ([CROWD_SYS_MSG_KICKOUT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"你已经被请出%@", self.crowd_name] forKey:@"result"];
        
//        return [NSString stringWithFormat: @"你已经被请出%@", self.crowd_name];
    } else if ([CROWD_SYS_MSG_KICKOUT_ADMIN_OTHER isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1被$2请出%@", self.crowd_name] forKey:@"result"];

        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.name , @"txt", self.name_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
        NSDictionary* dic_2 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_2 forKey:@"$2"];
        
//        return [NSString stringWithFormat: @"%@被%@请出%@", self.name, self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_KICKOUT_ADMIN_SELF isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1被你请出%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.name , @"txt", self.name_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
//        return [NSString stringWithFormat: @"%@被你请出%@", self.name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_QUIT isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1退出%@", self.crowd_name] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
        
//        return [NSString stringWithFormat: @"%@退出%@", self.actor_name, self.crowd_name];
    } else if ([CROWD_SYS_MSG_QUIT_SELF isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"你已退出了%@", self.crowd_name] forKey:@"result"];

//        return [NSString stringWithFormat: @"你已退出了%@", self.crowd_name];
    } else if ([CROWD_WEB_GROUPS_LIST isEqualToString:self.msgType]){
        if (!self.txt || [@"" isEqualToString:self.txt]) {
            [ret setObject:@"后端管理系统消息" forKey:@"result"];
        }else{
            [ret setObject:self.txt forKey:@"result"];
        }
//        return self.txt;
    } else if ([CROWD_SYS_MSG_WEB_MEMBER_LIST isEqualToString:self.msgType]){
        [ret setObject:self.txt forKey:@"result"];
    } else if ([CROWD_SYS_MSG_CROWD_ROLE_CHANGE isEqualToString:self.msgType]){
        [ret setObject:[NSString stringWithFormat: @"$1%@", self.txt] forKey:@"result"];
        NSDictionary* dic_1 = [NSDictionary dictionaryWithObjectsAndKeys: self.actor_name , @"txt", self.actor_jid, @"jid", nil];
        [ret setObject:dic_1 forKey:@"$1"];
//        return [NSString stringWithFormat: @"%@%@", self.actor_name, self.txt];
    }
    
    LOG_GENERAL_INFO(@"system message info  dic:%@", ret);
    txtDic_ = ret;
    return  ret;
}

- (BOOL) isInviteOrAuthen
{
    if ([CROWD_SYS_MSG_INVITED_BY_CROWD isEqualToString: self.msgType] || [CROWD_SYS_MSG_APPLY_AUTHEN isEqualToString:self.msgType]) {
        return YES;
    }
    return NO;
}

- (BOOL) isAnswer
{
    if ([CROWD_SYS_MSG_INVATE_ACCEPT isEqualToString:self.msgType] || [CROWD_SYS_MSG_INVATE_DENY isEqualToString:self.msgType] || isAnswer_ >= 0) {
        return YES;
    }
    return NO;
}

//- (void) setRead:(BOOL)isRead
//{
//    if (!isRead_) {
////        [[BizlayerProxy shareInstance] markSystemMessageRead: self.rowId  withListener:^(NSDictionary* data){
////            ResultInfo *resultInfo =[self parseCommandResusltInfo:data];
////            if (resultInfo.succeed) {
////                isRead_ = YES;
////            }
////        }];
//        
//    }
//}

//- (BOOL) getRead
//{
//    return isRead_;
//}

- (NSString*) getShowTxt
{
    if ([self isCrowdSystemMsg]) {
        if (!txtDic_) {
            [self getCrowdContent];
        }
        LOG_GENERAL_DEBUG(@"系统消息处理后的信息：%@", txtDic_);
        NSMutableString* result = [txtDic_ objectForKey:@"result"];
        NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                                  initWithPattern:@"\\$[0-9]"
                                                  options:NSRegularExpressionCaseInsensitive
                                                  error:nil];
        NSArray *arr = [regularexpression matchesInString:result options:NSMatchingReportProgress range:NSMakeRange(0, result.length)];
        
        NSMutableString* tmpResult = [result mutableCopy];
        if (!arr || [[NSNull null] isEqual:arr]) {
            return tmpResult;
        }
        NSUInteger step = 0;
        for (NSTextCheckingResult *match in arr) {
            NSRange matchRange = [match range];
            NSString* param = [result substringWithRange:matchRange];
            NSDictionary* d = [txtDic_ objectForKey:param];
            NSString* txt = [d objectForKey:@"txt"];
            
            [tmpResult replaceCharactersInRange:matchRange withString:txt];
            step += [txt length] - matchRange.length;
        }
        return tmpResult;
    }else{
        NSMutableString* tmp = [[NSMutableString alloc] init];
        if (self.extraObject && [self.extraObject isKindOfClass:[FriendInfo class]]) {
            [tmp appendString:((FriendInfo*)self.extraObject).showName];
            [tmp appendString:self.info];
        }else{
            [tmp appendString:self.info];
        }
        return tmp;
    }
    
}

- (BOOL) isCrowdSystemMsg
{
    NSRange range = [[self.msgType lowercaseString] rangeOfString:@"crowd"];
    LOG_GENERAL_INFO(@"crowd range:%d,%d",range.location, range.length);
    if (range.length != 0) {
        return YES;
    }
    return NO;
}

- (BOOL) isFriendSystemMsg
{
    if ([REQUEST isEqualToString: self.msgType] ||
        [REJECT isEqualToString:self.msgType] ||
        [AGREE isEqualToString:self.msgType]) {
        return YES;
    }
    return NO;
}


- (void) answerInviteByCrowd:(BOOL)isAccpt WithCallback:(void(^)(BOOL))callback
{
    if ([self isCrowdSystemMsg]) {
        [[BizlayerProxy shareInstance] answerCrowdInvite:isAccpt WithRowID:self.rowId WithSessionID:self.jid WithCrowdName:self.crowd_name WithIcon:self.icon WithCategory:self.category WithJID:self.actor_jid WithName:self.actor_name WithReason:self.reason WithNeverAccpte:NO withListener:^(NSDictionary* data){
            ResultInfo* result = [self parseCommandResusltInfo:data];
            if (result.succeed) {
                callback(YES);
                isAnswer_ = 1;
                self.isAgree = isAccpt;
                isAnswer_ = isAccpt ? 1 : 0;
            }else{
                callback(NO);
            }
        }];
    }

}

- (void) answerApplyJonCrowd:(BOOL)isApply withCallback:(void (^)(BOOL))callback
{
    if ([self isCrowdSystemMsg]) {
        [[BizlayerProxy shareInstance] answerApplyJonCrowd:isApply WithSessionID:self.jid actorName:self.actor_name actorJID:self.actor_jid actorIcon:self.icon actorSex:self.actor_sex actorIdentity:self.actor_identity reason:@"" WithListener:^(NSDictionary *data) {
            ResultInfo* result = [self parseCommandResusltInfo:data];
            if (result.succeed) {
                callback(YES);
            }else{
                callback(NO);
            }
        }];
    }
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
