//
//  FriendInfo.h
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivateUnitInfo.h"
#import "AccountManager.h"
#import "Entity.h"
#import "Constants.h"




@class VCardPrivacy;

@interface FriendInfo : Entity <Jsonable> {
}
@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) NSString *name;
@property (assign) BOOL constructMannually;
@property (nonatomic, copy) NSString* photoCredential;
@property (nonatomic, copy) NSString* zhZodiac;
@property (nonatomic, copy) NSString* college;
@property (nonatomic, copy) NSString* bloodType;
@property (nonatomic, copy) NSString* addressExtend;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* addressCity;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* username;
@property (nonatomic, copy) NSString* cellphone;
@property (nonatomic, copy) NSString* sexShow;
@property (nonatomic, copy) NSString* age;
@property (nonatomic, copy) NSString* showName;
@property (nonatomic, copy) NSString* role;
@property (nonatomic, copy) NSString* head;
@property (nonatomic, copy) NSString* information;
@property (nonatomic, copy) NSString* moodWords;
@property (nonatomic, copy) NSString* addressDistrict;
@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* hobby;
@property (nonatomic, copy) NSString* addressProvince;
@property (nonatomic, copy) NSString* friendClass;
@property (nonatomic, copy) NSString* remarkName;
@property (nonatomic, copy) NSString* lastBaseTime;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* endTime;
@property (nonatomic, copy) NSString* nativeplaceDistrict;
@property (nonatomic, copy) NSString* createTime;
@property (nonatomic, copy) NSString* webLog;
@property (nonatomic, copy) NSString* language;
@property (nonatomic, copy) NSString* lastExtendTime;
@property (nonatomic, copy) NSString* livePhoto;
@property (nonatomic, copy) NSString* nativeplace_province;
@property (nonatomic, copy) NSString* birthday;
@property (nonatomic, copy) NSString* sex;
@property (nonatomic, copy) NSString* address_postcode;
@property (nonatomic, copy) NSString* department;
@property (nonatomic, copy) NSString* address_nation;
@property (nonatomic, copy) NSString* nativeplace_nation;
@property (nonatomic, copy) NSString* creationdate;
@property (nonatomic, copy) NSString* identity;
@property (nonatomic, copy) NSString* landline;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* zodiac;
//@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* sort_string;
@property (nonatomic, copy) NSString* photo_live;
@property (nonatomic, copy) NSString* home_page;
@property (nonatomic, copy) NSString* modificationtime;
@property (nonatomic, copy) NSString* modificationdate;
@property (nonatomic, copy) NSString* remark_pinyin;
@property (nonatomic, copy) NSString* nick_pinyin;
@property (nonatomic, copy) NSString* id_card_number;
@property (nonatomic, copy) NSString* last_volatile_time;
@property (nonatomic, copy) NSString* student_number;
@property (nonatomic, copy) NSString* presence;
@property (nonatomic, copy) NSString* identity_show;
@property (nonatomic, copy) NSString* organization_id;
@property (nonatomic, copy) NSString* start_time;
@property (nonatomic, copy) NSString* nativeplace_city;
@property (nonatomic, copy) NSString* group;
@property (nonatomic, copy) NSString* aid;

@property (nonatomic, copy) NSString* affiliation;

@property (nonatomic) NSUInteger level;//当前等级
@property (nonatomic) NSUInteger exp;//当前的经验值
@property (nonatomic) NSUInteger next_exp;//到下一等级的经验值

@property (nonatomic) BOOL device_android;//我的设备安卓
@property (nonatomic) BOOL device_pc;//我的设备pc

/**
 *  判断某个属性是否是保密状态
 *
 *  @param property 属性的字符串值
 *
 *  @return 
 */
- (BOOL) isSecrecy:(NSString*) property;

//@property (nonatomic, strong) NSMutableDictionary* cachedJSONObject;

+(AccountStatus)getFriendPresenceFromString:(NSString *)presence;
+(Boolean)containsBaseInfo :(NSDictionary *) jsonObj;
-(void)reset:(NSDictionary *)jsonObj;
-(BOOL)isOnline;
-(void) clear;
-(AccountStatus)getFriendPresence;
-(void)copyWithAnotherFriend:(FriendInfo *)aFriend;
-(BOOL)isTeacher;


@end
