//
//  FriendGroup.m
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "FriendGroup.h"
#import "JSONObjectHelper.h"
#import "FriendInfo.h"

#define KEY_NAME  @"name"
#define KEY_ONLINE_COUNT  @"headOnline"
#define KEY_TOTAL_COUNT  @"headCount"
#define KEY_SUB_LIST  @"sublist"

/*
 @property (copy, nonatomic) NSString *rid;
 @property (copy, nonatomic) NSString *name;
 @property (assign, nonatomic) int onlineCount;
 @property (assign, nonatomic) int totalCount;
 @property (strong, nonatomic) NSMutableArray *friends;
 @property (assign, nonatomic) Boolean canbeDeleted;
 @property (assign) Boolean canbeRenamed;

 */
@implementation FriendGroup

@synthesize rid;
@synthesize name;
@synthesize onlineCount;
@synthesize totalCount;
@synthesize friends;
@synthesize canbeDeleted;
@synthesize canbeRenamed;

- (id)initFromJsonObject:(NSDictionary *)jsonObj {
    if (self = [super init]) {
        self.name = [jsonObj objectForKey:KEY_NAME];
        id tempObj = [jsonObj objectForKey:KEY_ONLINE_COUNT];
        if (tempObj && [tempObj isKindOfClass:[NSNumber class]]) {
            self.onlineCount = ((NSNumber *) tempObj).intValue;
        }
        else {
            self.onlineCount = 0;
        }
        tempObj = [jsonObj objectForKey:KEY_TOTAL_COUNT];
        if (tempObj && [tempObj isKindOfClass:[NSNumber class]]) {
            self.totalCount = ((NSNumber *) tempObj).intValue;
        }
        else {
            self.totalCount = 0;
        }
        @autoreleasepool {
            
        
        NSArray *arr = [jsonObj objectForKey:KEY_SUB_LIST];
        if (arr) {
            self.friends = [NSMutableArray arrayWithArray:[JSONObjectHelper getObjectArrayFromJSONArray:arr withClass:[FriendInfo class]]];
        }
        }
        //[JSONObjectHelper releaseJson:jsonObj];
        jsonObj = nil;
    }
    return self;
}

- (void) refrashOnlineAndSort
{
    self.onlineCount = 0;
    for (FriendInfo* info in [self friends]) {
        if ([info isOnline]) {
            self.onlineCount ++;
        }
    }
    [self sortByOnline];
}


- (void) sortByOnline
{
    NSComparator friendSorter = ^NSComparisonResult(id obj1, id obj2) {
        
        FriendInfo *f1 = obj1;
        FriendInfo *f2 = obj2;
        if ([f1 isOnline] == [f2 isOnline]) {
            return NSOrderedSame;
        }
        return [f1 isOnline] ? NSOrderedAscending : NSOrderedDescending; //[f1 getFriendPresence] > [f2 getFriendPresence] ? NSOrderedAscending : NSOrderedDescending;
    };
    
    [self.friends sortUsingComparator:friendSorter];
}

- (BOOL) isExist:(FriendInfo *)friendInfo
{
    for (FriendInfo* f in self.friends) {
        if ([f.jid isEqualToString:friendInfo.jid]) {
            return YES;
        }
    }
    return NO;
}

- (FriendInfo*) getFriendInfo:(NSString *)jid
{
    for (FriendInfo* info in friends) {
        if ([info.jid isEqualToString:jid]) {
            return info;
        }
    }
    return nil;
}

- (void) clear
{
    [self.friends removeAllObjects];
}

- (BOOL) removeFriendByJid:(NSString *)jid
{
    for (FriendInfo* f in friends) {
        if ([f.jid isEqualToString:jid]) {
            [friends removeObject:f];
            self.totalCount --;
            [self refrashOnlineAndSort];
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
