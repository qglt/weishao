//
//  CrowdInfo.m
//  WhistleIm
//
//  Created by liuke on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CrowdInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"

@implementation CrowdInfo

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    LOG_NETWORK_INFO(@"crowdinfo:%@", jsonObj);
    NSLog(@"%@",jsonObj);
    self = [self init];
    if(self){
        self.icon = [jsonObj objectForKey:KEY_ICON];
        self.dismiss = [[jsonObj objectForKey:KEY_DISMISS] isEqualToString:@"false"] ? NO : YES;
        self.quit = [[jsonObj objectForKey:KEY_QUIT] isEqualToString:@"false"] ? NO : YES;
        self.v = [[jsonObj objectForKey:KEY_V] isEqualToString:@"true"] ? YES : NO;
        self.status = [(NSString*)[jsonObj objectForKey:KEY_STATUS] intValue] ;
        self.alert = [(NSString*)[jsonObj objectForKey:KEY_ALERT] intValue] ;
        self.role = [jsonObj objectForKey:KEY_ROLE];
        self.official = [@"true" isEqualToString: [jsonObj objectForKey:KEY_OFFICIAL]] ? YES : NO;
        self.active = [jsonObj objectForKey:KEY_ACTIVE];
        self.session_id = [jsonObj objectForKey:KEY_SESSION_ID];
        if ([super isNull: self.session_id]) {
            self.session_id = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:KEY_ID];
        }
        self.name = [jsonObj objectForKey:KEY_NAME];
        self.category = [(NSString*)[jsonObj objectForKey:KEY_CATEGORY] intValue] ;
        self.remark = [jsonObj objectForKey:KEY_REMARK];
        LOG_GENERAL_INFO(@"crowdinfo name:%@, icon:%@, category:%d", self.name, self.icon, self.category);
        //[JSONObjectHelper releaseJson:jsonObj];
        
        self.description = [jsonObj objectForKey:KEY_DESCRIPTION];
        self.cur_member_size = [[jsonObj objectForKey:@"cur_member_size"] integerValue];
        self.announce = [jsonObj objectForKey:@"announce"];
        self.cur_space_size = [[jsonObj objectForKey:@"max_space_size"] integerValue];
        self.auth = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_AUTH_TYPE defaultValue:-1];
        self.max_member_size = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:KEY_MAX_MEMBER_SIZE defaultValue:0];
        jsonObj = nil;
    }
    
    return self;
}

/*
 @property (nonatomic) NSInteger cur_member_size;
 @property (nonatomic) NSInteger cur_space_size;
 @property (nonatomic, strong) NSString* announce;
 @property (nonatomic, strong) NSString* description;
 */

- (BOOL) isNormal
{
    return self.status == 0;
}

- (BOOL) isFrozen
{
    return self.status == 1;
}

- (BOOL) isAdmin
{
    return [self.role isEqualToString:@"admin"];
}

- (BOOL) isSuper
{
    return [self.role isEqualToString:@"super"];
}
//0-验证，1-不验证直接加入，2-不允许加入
- (BOOL) isAllowJoin
{
    return self.auth != 2;
}

- (BOOL) isVoiceAlert
{
    return self.alert == 0;
}

- (CrowdInfo*) getUnionSetByCrowdInfo:(CrowdInfo *)crowdinfo
{
    if (crowdinfo.name) {
        self.name = crowdinfo.name;
    }
    if (crowdinfo.icon) {
        self.icon = crowdinfo.icon;
    }
    if (crowdinfo.category > 0) {
        self.category = crowdinfo.category;
    }
    if (crowdinfo.status == 0 || crowdinfo.status == 1) {
        self.status = crowdinfo.status;
    }
    if (crowdinfo.active) {
        self.active = crowdinfo.active;
    }
    if (crowdinfo.announce) {
        self.announce = crowdinfo.announce;
    }
//    [super merge:self.announce src:crowdinfo.announce];
    if (crowdinfo.description) {
        self.description = crowdinfo.description;
    }
//    [super merge:self.description src:crowdinfo.description];
    if (crowdinfo.remark) {
        self.remark = crowdinfo.remark;
    }
//    [super merge:self.remark src:crowdinfo.remark];
    if (crowdinfo.role) {
        self.role = crowdinfo.role;
    }
//    [super merge:self.role src:crowdinfo.role];
    
    self.cur_member_size = crowdinfo.cur_member_size;
    self.cur_space_size = crowdinfo.cur_space_size;
    
    return self;
}

- (UIImage *)getCrowdDefalutImageWithCategory:(NSUInteger)category
{
    // 10, 11, 12, 13, 14, 15, 16, 17
    // 课程，社团，学习，生活，兴趣，老乡，朋友，其他
    UIImage * defaultImage = nil;
    if (category == 10) {
        defaultImage = [UIImage imageNamed:@"crowd_default_course.png"];
    } else if (category == 11) {
        defaultImage = [UIImage imageNamed:@"crowd_default_mass.png"];
    } else if (category == 12) {
        defaultImage = [UIImage imageNamed:@"crowd_default_study.png"];
    } else if (category == 13) {
        defaultImage = [UIImage imageNamed:@"crowd_default_life.png"];
    } else if (category == 14) {
        defaultImage = [UIImage imageNamed:@"crowd_default_interest.png"];
    } else if (category == 15) {
        defaultImage = [UIImage imageNamed:@"crowd_default_townsman.png"];
    } else if (category == 16) {
        defaultImage = [UIImage imageNamed:@"crowd_default_friend.png"];
    } else if (category == 17) {
        defaultImage = [UIImage imageNamed:@"crowd_default_other.png"];
    } else{
        defaultImage = [UIImage imageNamed:@"crowd_default_class.png"];
    }
    return defaultImage;
}

- (UIImage* ) getCrowdIcon
{
    if (self.icon && ![@"" isEqualToString:self.icon] && [[NSFileManager defaultManager] fileExistsAtPath:self.icon]) {
        return [UIImage imageWithContentsOfFile:self.icon];
    }else{
        return [self getCrowdDefalutImageWithCategory:self.category];
    }
    return nil;
}

- (NSString*) getCrowdID
{
    return [self.session_id substringWithRange:NSMakeRange(0, [self.session_id rangeOfString:@"@"].location)];
}

- (void) removeCrowdMemberByJID:(NSString *)jid
{
    if (self.members) {
        CrowdMember* member = nil;
        for (CrowdMember* m in self.members) {
            if ([m.jid isEqualToString:jid]) {
                member = m;
                break;
            }
        }
        [self.members removeObject:member];
    }
}

- (CrowdMember*) getCrowdMember:(NSString *)jid
{
    if (self.members) {
        for (CrowdMember* m in self.members) {
            if ([m.jid isEqualToString:jid]) {
                return m;
            }
        }
        return nil;
    }else{
        return nil;
    }
}

- (BOOL) isActive
{
    return [@"true" isEqualToString:self.active];
}

- (BOOL) isHasDetailInfo
{
    return ![super isNull:self.announce];
}

- (BOOL) changeHead:(NSString *)jid head:(NSString *)head
{
    if (!(self.members)) {
        return NO;
    }
    for (CrowdMember* m in self.members) {
        if ([m.jid isEqualToString:jid]) {
            m.head = head;
            return YES;
        }
    }
    return NO;
}

- (NSString*) toString
{
    return [super toString:self];
}


@end
