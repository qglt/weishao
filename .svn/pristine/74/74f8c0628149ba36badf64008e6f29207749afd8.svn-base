//
//  FriendInfo.m
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//



#import "FriendInfo.h"
#import "JSONObjectHelper.h"
#import "Constants.h"
//#import "ImUtil.h"

@implementation FriendInfo

@synthesize sexShow;
@synthesize showName;
@synthesize head;
@synthesize remarkName;
@synthesize age;
@synthesize cellphone;
@synthesize landline;
@synthesize organization_id;
@synthesize title;
@synthesize student_number;
@synthesize birthday;
@synthesize username;
@synthesize zodiac;
@synthesize zhZodiac;
@synthesize bloodType;
@synthesize hobby;
@synthesize email;
@synthesize webLog;
@synthesize home_page;
@synthesize addressExtend;
@synthesize address_postcode;
@synthesize information;
@synthesize identity;
@synthesize moodWords;

-(id)init
{
    if(self = [super init]){
        //self.cachedJSONObject = [[NSMutableDictionary alloc] initWithCapacity:15];
        self.constructMannually = YES;
    }
    
    return self;
}

-(id)initFromJsonObject :(NSDictionary *)json
{
    if(self = [self init]){
        [self reset:json];
        self.constructMannually = NO;
        //[JSONObjectHelper releaseJson:json];
        json = nil;
        self.level = 0;
        self.exp = 0;
        self.next_exp = 0;
    }
    
    return self;
}

#define FRIENDCOPY(a) copy.a = self.a


-(id)copyWithZone:(NSZone *)zone
{
    FriendInfo *copy = [[[self class] allocWithZone:zone] init];
    FRIENDCOPY( jid);
    FRIENDCOPY( photoCredential);
    FRIENDCOPY( zhZodiac);
    FRIENDCOPY( college);
    FRIENDCOPY( bloodType);
    FRIENDCOPY( addressExtend);
    FRIENDCOPY( type);
    FRIENDCOPY( addressCity);
    FRIENDCOPY( nickName);
    FRIENDCOPY( username);
    FRIENDCOPY( cellphone);
    FRIENDCOPY( sexShow);
    FRIENDCOPY( age);
    FRIENDCOPY( showName);
    FRIENDCOPY( role);
    FRIENDCOPY( head);
    FRIENDCOPY( information);
    FRIENDCOPY( moodWords);
    FRIENDCOPY( addressDistrict);
    FRIENDCOPY( status);
    FRIENDCOPY( hobby);
    FRIENDCOPY( addressProvince);
    FRIENDCOPY( friendClass);
    FRIENDCOPY( remarkName);
    FRIENDCOPY( lastBaseTime);
    FRIENDCOPY( email);
    FRIENDCOPY( endTime);
    FRIENDCOPY( nativeplaceDistrict);
    FRIENDCOPY( createTime);
    FRIENDCOPY( webLog);
    FRIENDCOPY( language);
    FRIENDCOPY( lastExtendTime);
    FRIENDCOPY( livePhoto);
    FRIENDCOPY( nativeplace_province);
    FRIENDCOPY( birthday);
    FRIENDCOPY( sex);
    FRIENDCOPY( address_postcode);
    FRIENDCOPY( department);
    FRIENDCOPY( address_nation);
    FRIENDCOPY( nativeplace_nation);
    FRIENDCOPY( creationdate);
    FRIENDCOPY( identity);
    FRIENDCOPY( landline);
    FRIENDCOPY( title);
    FRIENDCOPY( zodiac);
    FRIENDCOPY( name);
    FRIENDCOPY( sort_string);
    FRIENDCOPY( photo_live);
    FRIENDCOPY( home_page);
    FRIENDCOPY( modificationtime);
    FRIENDCOPY( modificationdate);
    FRIENDCOPY( remark_pinyin);
    FRIENDCOPY( nick_pinyin);
    FRIENDCOPY( id_card_number);
    FRIENDCOPY( last_volatile_time);
    FRIENDCOPY( student_number);
    FRIENDCOPY( presence);
    FRIENDCOPY( identity_show);
    FRIENDCOPY( organization_id);
    FRIENDCOPY( start_time);
    FRIENDCOPY( nativeplace_city);
    FRIENDCOPY( group);
    FRIENDCOPY( aid);
    
    FRIENDCOPY( affiliation);
    
    return copy;
}

#define FCOPY(a) self.a = aFriend.a

-(void)copyWithAnotherFriend:(FriendInfo *)aFriend
{
    FCOPY( jid);
    FCOPY( photoCredential);
    FCOPY( zhZodiac);
    FCOPY( college);
    FCOPY( bloodType);
    FCOPY( addressExtend);
    FCOPY( type);
    FCOPY( addressCity);
    FCOPY( nickName);
    FCOPY( username);
    FCOPY( cellphone);
    FCOPY( sexShow);
    FCOPY( age);
    FCOPY( showName);
    FCOPY( role);
    FCOPY( head);
    FCOPY( information);
    FCOPY( moodWords);
    FCOPY( addressDistrict);
    FCOPY( status);
    FCOPY( hobby);
    FCOPY( addressProvince);
    FCOPY( friendClass);
    FCOPY( remarkName);
    FCOPY( lastBaseTime);
    FCOPY( email);
    FCOPY( endTime);
    FCOPY( nativeplaceDistrict);
    FCOPY( createTime);
    FCOPY( webLog);
    FCOPY( language);
    FCOPY( lastExtendTime);
    FCOPY( livePhoto);
    FCOPY( nativeplace_province);
    FCOPY( birthday);
    FCOPY( sex);
    FCOPY( address_postcode);
    FCOPY( department);
    FCOPY( address_nation);
    FCOPY( nativeplace_nation);
    FCOPY( creationdate);
    FCOPY( identity);
    FCOPY( landline);
    FCOPY( title);
    FCOPY( zodiac);
    FCOPY( name);
    FCOPY( sort_string);
    FCOPY( photo_live);
    FCOPY( home_page);
    FCOPY( modificationtime);
    FCOPY( modificationdate);
    FCOPY( remark_pinyin);
    FCOPY( nick_pinyin);
    FCOPY( id_card_number);
    FCOPY( last_volatile_time);
    FCOPY( student_number);
    FCOPY( presence);
    FCOPY( identity_show);
    FCOPY( organization_id);
    FCOPY( start_time);
    FCOPY( nativeplace_city);
    FCOPY( group);
    FCOPY( aid);
    
    FCOPY( affiliation);
    
}

-(int)getJSONChildrenCount: (NSDictionary *)jsonObj
{
    return [jsonObj count];
}

-(NSString *)getString:(NSDictionary *)json withKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    if([json objectForKey:key] != nil){
        return [json objectForKey:key];//[JSONObjectHelper getStringFromJSONObject:json forKey:key];
    }
    
    return defaultValue;
}

-(NSString *)getStringFromNumber:(NSDictionary *)json withKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
//    NSNumber *value = [json objectForKey:key];
//    static NSNumberFormatter *numberFormatter = nil;
//    
//    if(numberFormatter == nil){
//        numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        [numberFormatter setMaximumFractionDigits:3];
//    }
//
//    if(value != nil){
//        return [NSString stringWithFormat:@"%@",[numberFormatter stringFromNumber:value]];
//    }else{
//        return defaultValue;
//    }
    static NSRegularExpression *regularexpression  = nil;
    
    if (!regularexpression) {
        regularexpression = [[NSRegularExpression alloc] initWithPattern:@"[0-9]"
                                       options:NSRegularExpressionCaseInsensitive
                                       error:nil];
    
    }
    
    @autoreleasepool {
        
    
        id value = [json objectForKey:key];
        if (value) {
            NSString* ret = [NSString stringWithFormat:@"%@", value];
            NSArray *arr = [regularexpression matchesInString:ret options:NSMatchingReportProgress range:NSMakeRange(0, ret.length)];
            if (arr && [arr count] > 0) {
                return ret;
            }else{
                return @"0";
            }
        }
        return @"0";
    }
}

-(void)mergeJSONObject:(NSDictionary *)newJsonObj
{
    
//    @autoreleasepool {
//        
//    
//    [self.cachedJSONObject removeAllObjects];
//    
//    NSEnumerator *it =  [newJsonObj keyEnumerator];
//    NSString *key = [it nextObject];
//    NSString *value = nil;
//    while(key != nil){
//        value = [newJsonObj objectForKey:key];
//        [self.cachedJSONObject setValue:value forKey:key];
//        key = [it nextObject];
//    }
//    }
    
}

#define SETWITHDEFAULT(a,b) self.a = [self getString:jsonObj withKey:b defaultValue:[self a]]

-(void)reset:(NSDictionary *)jsonObj
{
    @autoreleasepool {
        
//    self.photoCredential = [self getString:jsonObj withKey:KEY_PHOTO_CREDENTIAL defaultValue:self.photoCredential];
    self.photoCredential = [self getString:jsonObj withKey:@"head" defaultValue:self.photoCredential];
    
        NSDictionary* device = [JSONObjectHelper getJSONFromJSON:jsonObj forKey:KEY_DEVICE];
        self.device_android = [[device objectForKey:KEY_ANDROID] boolValue];
        self.device_pc = [[device objectForKey:KEY_PC] boolValue];
    
    self.zhZodiac = [self getString:jsonObj withKey:KEY_ZH_ZODIAC defaultValue:self.zhZodiac];
    
    self.college = [self getString:jsonObj withKey:KEY_COLLEGE defaultValue:self.college];
    
    self.bloodType = [self getString:jsonObj withKey:KEY_BLOODTYPE defaultValue:self.bloodType];
    
    self.addressExtend = [self getString:jsonObj withKey:KEY_ADDRESS_EXTEND defaultValue:self.addressExtend];
    
    self.type = [self getString:jsonObj withKey:IM_KEY_TYPE defaultValue:self.type];
    
    self.addressCity = [self getString:jsonObj withKey:KEY_ADDRESS_CITY defaultValue:self.addressCity];
    
    self.nickName = [self getString:jsonObj withKey:KEY_NICK_NAME defaultValue:self.nickName];
    
    self.username = [self getString:jsonObj withKey:KEY_USERNAME defaultValue:self.username];
    
    self.cellphone = [self getString:jsonObj withKey:KEY_CELLPHONE defaultValue:self.cellphone];
    
    self.sexShow = [self getString:jsonObj withKey:KEY_SEX_SHOW defaultValue:self.sexShow];
    
//    self.age = [self getStringFromNumber:jsonObj withKey:KEY_AGE defaultValue:self.age];
        self.age = [self getAge:jsonObj];//[self getStringFromNumber:jsonObj withKey:KEY_AGE defaultValue:nil];

    
//    self.showName = [self getString:jsonObj withKey:KEY_SHOWNAME defaultValue:self.showName];
    self.showName = [self getString:jsonObj withKey:@"showname" defaultValue:self.showName];
//    self.moodWords = [self getString:jsonObj withKey:@"mood_words" defaultValue:self.moodWords];
    
    SETWITHDEFAULT(role,KEY_ROLE);
    
    SETWITHDEFAULT(jid,IM_KEY_JID);
    
    if(self.jid == nil){
        NSLog(@"friendInfo jid is null! ");
    }
    
    SETWITHDEFAULT(head,KEY_HEAD);
    SETWITHDEFAULT(information,KEY_INFORMATION);
    SETWITHDEFAULT(moodWords,KEY_MOOD_WORDS);
    SETWITHDEFAULT(addressDistrict,KEY_ADDRESS_DISTRICT);
    SETWITHDEFAULT(status,IM_KEY_STATUS);
    
    SETWITHDEFAULT(hobby,KEY_HOBBY);
    SETWITHDEFAULT(addressProvince,KEY_ADDRESS_PROVINCE);
    SETWITHDEFAULT(friendClass,KEY_CLASS);
    SETWITHDEFAULT(remarkName,KEY_REMARK_NAME);
    SETWITHDEFAULT(lastBaseTime,KEY_LAST_BASE_TIME);
    SETWITHDEFAULT(email,KEY_EMAIL);
    SETWITHDEFAULT(endTime,KEY_END_TIME);
    SETWITHDEFAULT(nativeplaceDistrict,KEY_NATIVEPLACE_DISTRICT);
    SETWITHDEFAULT(createTime,KEY_CREATE_TIME);
    SETWITHDEFAULT(webLog,KEY_WEBLOG);
    SETWITHDEFAULT(language,KEY_LANGUAGE);
    SETWITHDEFAULT(lastExtendTime,KEY_LAST_EXTEND_TIME);
    SETWITHDEFAULT(livePhoto,KEY_LIVE_PHOTO);
    SETWITHDEFAULT(nativeplace_province,KEY_nativeplace_province);
    SETWITHDEFAULT(birthday,KEY_birthday);
    SETWITHDEFAULT(address_postcode,KEY_address_postcode);
    SETWITHDEFAULT(department,KEY_department);
    SETWITHDEFAULT(address_nation,KEY_address_nation);
    SETWITHDEFAULT(nativeplace_nation,KEY_nativeplace_nation);
    SETWITHDEFAULT(creationdate,KEY_creationdate);
    
    SETWITHDEFAULT(identity,KEY_identity);
    SETWITHDEFAULT(landline,KEY_landline);
    SETWITHDEFAULT(title,KEY_title);
    SETWITHDEFAULT(zodiac,KEY_zodiac);
    SETWITHDEFAULT(name,KEY_name);
    SETWITHDEFAULT(sort_string,KEY_sort_string);
    SETWITHDEFAULT(photo_live,KEY_photo_live);
    SETWITHDEFAULT(home_page,KEY_home_page);
    SETWITHDEFAULT(modificationtime,KEY_modificationtime);
    SETWITHDEFAULT(modificationdate,KEY_modificationdate);
    SETWITHDEFAULT(remark_pinyin,KEY_remark_pinyin);
    SETWITHDEFAULT(nick_pinyin,KEY_nick_pinyin);
    SETWITHDEFAULT(id_card_number,KEY_id_card_number);

    SETWITHDEFAULT(last_volatile_time,KEY_last_volatile_time);
    SETWITHDEFAULT(student_number,KEY_student_number);
    
    //self.lastPresense = self.presence;
    
    SETWITHDEFAULT(presence,KEY_presence);
    SETWITHDEFAULT(identity_show,KEY_identity_show);
    SETWITHDEFAULT(organization_id,KEY_organization);
    SETWITHDEFAULT(start_time,KEY_start_time);
    SETWITHDEFAULT(nativeplace_city,KEY_nativeplace_city);
    SETWITHDEFAULT(group,KEY_group);
    SETWITHDEFAULT(aid,KEY_aid);
    SETWITHDEFAULT(affiliation,KEY_AFFILIATION);
    }
}

-(void)updatePresence :(NSString*) newPresence
{
    //self.lastPresense = self.presence;
    self.presence = newPresence;
}

-(BOOL)isOnline
{
    //NSLog(@"presence is %@",self.presence);
    if(![self.presence isEqualToString:@"Offline"] && ![@"Invisible" isEqualToString:self.presence]){
        return YES;
    }
    return NO;
}

#define CLEAR(a)  self.a = nil
-(void)clear
{
    @autoreleasepool {
    
    /*
    
    if(self.cachedJSONObject){
        [self.cachedJSONObject removeAllObjects];
    }
    self.cachedJSONObject = nil;
    */    
        CLEAR( jid);
        CLEAR( photoCredential);
        CLEAR( zhZodiac);
        CLEAR( college);
        CLEAR( bloodType);
        CLEAR( addressExtend);
        CLEAR( type);
        CLEAR( addressCity);
        CLEAR( nickName);
        CLEAR( username);
        CLEAR( cellphone);
        CLEAR( sexShow);
        CLEAR( age);
        CLEAR( showName);
        CLEAR( role);
        CLEAR( head);
        CLEAR( information);
        CLEAR( moodWords);
        CLEAR( addressDistrict);
        CLEAR( status);
        CLEAR( hobby);
        CLEAR( addressProvince);
        CLEAR( friendClass);
        CLEAR( remarkName);
        CLEAR( lastBaseTime);
        CLEAR( email);
        CLEAR( endTime);
        CLEAR( nativeplaceDistrict);
        CLEAR( createTime);
        CLEAR( webLog);
        CLEAR( language);
        CLEAR( lastExtendTime);
        CLEAR( livePhoto);
        CLEAR( nativeplace_province);
        CLEAR( birthday);
        CLEAR( sex);
        CLEAR( address_postcode);
        CLEAR( department);
        CLEAR( address_nation);
        CLEAR( nativeplace_nation);
        CLEAR( creationdate);
        CLEAR( identity);
        CLEAR( landline);
        CLEAR( title);
        CLEAR( zodiac);
        CLEAR( name);
        CLEAR( sort_string);
        CLEAR( photo_live);
        CLEAR( home_page);
        CLEAR( modificationtime);
        CLEAR( modificationdate);
        CLEAR( remark_pinyin);
        CLEAR( nick_pinyin);
        CLEAR( id_card_number);
        CLEAR( last_volatile_time);
        CLEAR( student_number);
        CLEAR( presence);
        CLEAR( identity_show);
        CLEAR( organization_id);
        CLEAR( start_time);
        CLEAR( nativeplace_city);
        CLEAR( group);
        CLEAR( aid);
        
        CLEAR( affiliation);
        
    }
}

- (NSString*) getAge:(NSDictionary*) dic
{
    static NSRegularExpression *regularexpression  = nil;
    
    if (!regularexpression) {
        regularexpression = [[NSRegularExpression alloc] initWithPattern:@"[0-9]"
                                                                 options:NSRegularExpressionCaseInsensitive
                                                                   error:nil];
    }
    
    id value = [dic objectForKey:KEY_AGE];
    
    if (value) {
        NSString* ret = [NSString stringWithFormat:@"%@", value];
        NSArray *arr = [regularexpression matchesInString:ret options:NSMatchingReportProgress range:NSMakeRange(0, ret.length)];
        if (arr && [arr count] > 0) {
            return ret;
        }else{
            return nil;
        }
    }
    return nil;
}

-(AccountStatus)getFriendPresence
{
    if ([self.presence isEqualToString:PRESENCE_ONLINE]) {
        return Online;
    }else if ([self.presence isEqualToString:PRESENCE_AWAY]) {
        return Away;
    }else if ([self.presence isEqualToString:PRESENCE_BUSY]) {
        return Busy;
    }else if ([self.presence isEqualToString:PRESENCE_OFFLINE]) {
        return Offline;
    }else if ([self.presence isEqualToString:PRESENCE_ANDROID]) {
        return Android;
    }else if ([self.presence isEqualToString:PRESENCE_IOS]) {
        return Ios;
    }else if ([self.presence isEqualToString:PRESENCE_INVISIBLE]) {
        return Invisible;
    }
    return AccountLogout;
}

+(Boolean)containsBaseInfo :(NSDictionary *) jsonObj{
    NSArray *baseKeys = [NSArray arrayWithObjects:KEY_MOOD_WORDS, KEY_student_number, KEY_presence, KEY_identity, KEY_sex, KEY_SHOWNAME, KEY_HEAD, nil];

    for (int i=0;i<[baseKeys count];i++) {
        if ([jsonObj objectForKey:[baseKeys objectAtIndex:i]]!=nil) {
            return YES;
        }
    }
    return NO;
}

+(AccountStatus)getFriendPresenceFromString:(NSString *)presence
{
    if ([presence isEqualToString:PRESENCE_ONLINE]) {
        return Online;
    }else if ([presence isEqualToString:PRESENCE_AWAY]) {
        return Away;
    }else if ([presence isEqualToString:PRESENCE_BUSY]) {
        return Busy;
    }else if ([presence isEqualToString:PRESENCE_OFFLINE]) {
        return Offline;
    }else if ([presence isEqualToString:PRESENCE_ANDROID]) {
        return Android;
    }else if ([presence isEqualToString:PRESENCE_IOS]) {
        return Ios;
    }else if ([presence isEqualToString:PRESENCE_INVISIBLE]) {
        return Invisible;
    }
    return AccountLogout;
 
}
- (BOOL) isTeacher
{
    if([self.identity isEqualToString:IDENT_TEACHER]){
        return YES;
    }
    return NO;
}

- (NSString*) toString
{
    return [super toString:self];
}

- (NSDictionary*) encode
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tmp addEntriesFromDictionary:[super encode]];
    [tmp addEntriesFromDictionary:[self encode:self classType:[FriendInfo class]]];
    return tmp;
}

@end
