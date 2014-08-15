//
//  Roster.m
//  Whistle
//
//  Created by chao.wang on 13-1-17.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "Roster.h"
#import "FriendGroup.h"
#import "FriendInfo.h"
#import "JSONObjectHelper.h"

static NSString *KEY_BUDDY_LIST = @"buddy_list";
static NSString *KEY_MY_INFO = @"my_info";

@implementation Roster

- (id)init
{
    if(self = [super init]){
//        
//        self.groupList = [[NSArray alloc] init];
    }
    
    return self;
    
}
- (id)initFromJsonObject:(NSDictionary *)jsonObj {
    if (self = [self init]) {
        @autoreleasepool {
        
        self.myInitInfo = [[FriendInfo alloc] initFromJsonObject:[jsonObj objectForKey:KEY_MY_INFO]];
        self.groupList = [[NSMutableArray alloc] initWithArray:[JSONObjectHelper getObjectArrayFromJSONArray:[jsonObj objectForKey:KEY_BUDDY_LIST] withClass:[FriendGroup class]]];
        NSLog(@"get group list count %d",[self.groupList count]);
        [self sortByOnline];
            //[JSONObjectHelper releaseJson:jsonObj];
            jsonObj = nil;
        }
    }
    return self;
}


-(BOOL)groupExists:(NSString *)groupName
{
    for (FriendGroup *group  in self.groupList) {
        if ([group.name isEqualToString:groupName]) {
            return YES;
        }
    }
    
    return NO;
}

-(FriendGroup *)getGroup:(NSString *)groupName
{
    for (FriendGroup *group  in self.groupList) {
        if ([group.name isEqualToString:groupName]) {
            return group;
        }
    }
    
    return nil;

}

- (BOOL) isExistFriend:(FriendInfo*) f
{
    for (FriendGroup* fg in self.groupList) {
        if ([fg isExist:f]) {
            return YES;
        }
    }
    return NO;
}

-(void)addFriend:(FriendInfo *)newFriend
{
    FriendGroup *group = [self getGroup:newFriend.group];
    for (FriendGroup* g in self.groupList) {
        if ([g.name isEqualToString:@"陌生人"]) {
            group = g;
            break;
        }
    }
    if ( [self isExistFriend:newFriend] && [group.name isEqualToString:newFriend.group]) {
        return;
    }

    
    if(!group){
        group = [[FriendGroup alloc] init];
        group.name = newFriend.group;
        group.totalCount = 0;
        group.onlineCount = 0;
    }
    [group.friends addObject:newFriend];
    group.totalCount ++;
}

- (void) removeFriend:(NSString *)jid
{
    for (FriendGroup* fg in self.groupList) {
        if ([fg removeFriendByJid:jid]) {
            return;
        }
    }
}

- (FriendInfo*) getFriendInfo:(NSString *)jid
{
    if ([self.myInitInfo.jid isEqualToString:jid]) {
        return self.myInitInfo;
    }
    for (FriendGroup* g in self.groupList) {
        FriendInfo* info = [g getFriendInfo:jid];
        if (info) {
            return info;
        }
    }
    return nil;
}

- (void) sortByOnline
{
    for (FriendGroup* f in self.groupList) {
        [f sortByOnline];
    }
}

- (void) clear
{
    for (FriendGroup* f in self.groupList) {
        [f clear];
    }
    
    [self.groupList removeAllObjects];
 
}

- (NSString*) toString
{
    return [super toString:self];
}

@end
