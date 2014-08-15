//
//  FriendsSectionInfo.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-23.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FriendsSectionInfo.h"

#import "FriendGroupSectionInfo.h"
#import "FriendInfo.h"
#import "Whistle.h"
#import "RosterManager.h"
#import "FriendGroup.h"
#import "LocalSearchData.h"
#import "CrowdAndGroupInfo.h"
#import "GroupCellData.h"
#import "JSONObjectHelper.h"
#import "DiscussionManager.h"
#import "ChatGroupInfo.h"
#import "CrowdManager.h"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"


@interface FriendsSectionInfo ()
<RosterDelegate, DiscussionDelegate, CrowdDelegate>
{
    // 好友的所有信息
    NSMutableArray * m_arrFriendsTotalInfo;
    NSMutableArray * m_arrSearchData;
}

@property (nonatomic,strong) NSMutableArray * m_arrFriendsTotalInfo;
@property (nonatomic,strong) NSMutableArray * m_arrSearchData;

@end

@implementation FriendsSectionInfo

@synthesize m_arrFriendsTotalInfo;
@synthesize m_arrSearchData;
@synthesize m_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMemory];
        [[RosterManager shareInstance] addListener:self];
    }
    return self;
}

- (void)createAlertViewWithErrorMessage:(NSString *)errorMessage
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark -
#pragma mark - 好友数据源
- (void)getAllFriendsSectionsAndDataDictWith:(BOOL)isRefresh
{
    [[RosterManager shareInstance] getRoster:isRefresh];
}

/**
 *  好友列表更新通知
 *
 *  @param friendGroupList 好友的group集合
 */
- (void) rosterListChanged:(NSMutableArray*) friendGroupList
{
    self.m_arrFriendsTotalInfo = friendGroupList;
    [self reconsitutionFriendData];
}

/**
 *  获取好友列表成功后的事件
 */
- (void) getRosterFinish:(NSMutableArray*) friendGroupList
{
    self.m_arrFriendsTotalInfo = friendGroupList;
    [self reconsitutionFriendData];
}

/**
 *  获取好友列表失败后的事件
 */
- (void) getRosterFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createAlertViewWithErrorMessage:@"get Roster Failure"];
        [self getAllFriendsSectionsAndDataDictWith:YES];
    });
}

- (void)reconsitutionFriendData
{
    NSMutableDictionary * titleAndDataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [titleAndDataDict setObject:[self getSectionTitleArr] forKey:SECTION_TITLE];
    [titleAndDataDict setObject:[self getTotalFriendsDataArr] forKey:ALL_SECTION_DATA];
    [m_delegate sendFriendData:titleAndDataDict];
}

// 获取好友分类的section信息
- (NSMutableArray *)getSectionTitleArr
{
    NSMutableArray * sectionTitleArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSUInteger i = 0; i < [self.m_arrFriendsTotalInfo count]; i++) {
        FriendGroup * group = [self.m_arrFriendsTotalInfo objectAtIndex:i];
        FriendGroupSectionInfo * sectionInfo = [[FriendGroupSectionInfo alloc] init];
        if ([group.name isEqualToString:@"黑名单"]) {
            continue;
        }
        sectionInfo.name = group.name;
        sectionInfo.onlineCount = group.onlineCount;
        sectionInfo.totalCount = group.totalCount;
        [sectionTitleArr addObject:sectionInfo];
    }
    
//    [self logSectionInfoWithArr:sectionTitleArr];
    return sectionTitleArr;
}

// log title info
- (void)logSectionInfoWithArr:(NSMutableArray *)arr
{
    NSLog(@"section title arr count == %d", [arr count]);
    for (NSUInteger i = 0; i < [arr count]; i++) {
        FriendGroupSectionInfo * sectionInfo = [arr objectAtIndex:i];
        NSLog(@"name == %@", sectionInfo.name);
        NSLog(@"onlineCount == %d", sectionInfo.onlineCount);
        NSLog(@"totalCount == %d", sectionInfo.totalCount);
    }
}

// array in array
- (NSMutableArray *)getTotalFriendsDataArr
{
    NSMutableArray * totalFriendsArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * eachSectionFriendsArr = nil;
    for (NSUInteger i = 0; i < [self.m_arrFriendsTotalInfo count]; i++) {
        FriendGroup * group = [self.m_arrFriendsTotalInfo objectAtIndex:i];
        eachSectionFriendsArr = [NSMutableArray arrayWithArray:group.friends];
        [totalFriendsArr addObject:eachSectionFriendsArr];
    }
    return totalFriendsArr;
}

#pragma mark - 
#pragma mark - 本地好友搜索 start
- (void)findContactWithSeachText:(NSString *)searchText
{
    [[RosterManager shareInstance] getLocalSearchListWithSearchText:searchText withCallback:^(NSArray * data){
        NSArray * searchArr = [NSArray arrayWithArray:data];
        NSMutableArray * searchDataArr = [[NSMutableArray alloc] initWithCapacity:0];
        if (searchArr) {
            NSArray *resultItems = searchArr;
            for(NSDictionary *item in resultItems) {
                LocalSearchData * data = [self getLocalSearchDataWithItem:item];
                if (data != nil) {
                    [searchDataArr addObject:data];
                }
            }
            
            [self refreshSearchTableView:searchDataArr];
        }
    }];
}

- (void)setMemory
{
    self.m_arrSearchData = [[NSMutableArray alloc] initWithCapacity:0];
}

- (LocalSearchData *)getLocalSearchDataWithItem:(NSDictionary *)dict
{
    LocalSearchData * searchData = [[LocalSearchData alloc] init];
    NSString *itemType = [dict objectForKey:@"type"];
    searchData.m_type = itemType;
    if([itemType isEqualToString:@"conversation"] ){
        searchData.m_strHeaderImagePath = [dict objectForKey:@"head"];
        searchData.m_name = [dict objectForKey:@"showname"];
        searchData.m_jid = [dict objectForKey:@"jid"];
        searchData.m_friedIdentity = [dict objectForKey:@"identity_show"];
        NSLog(@"searchData.m_friedIdentity ---> %@", searchData.m_friedIdentity);
        searchData.m_sexShow = [dict objectForKey:@"sex_show"];
    } else if ([itemType isEqualToString:@"crowd_chat"]) {
        // category
        searchData.m_strHeaderImagePath = [dict objectForKey:@"icon"];
        searchData.m_name = [dict objectForKey:@"name"];
        searchData.m_jid = [dict objectForKey:@"jid"];
        searchData.m_category = [dict objectForKey:@"category"];
        
        NSString * active = [dict objectForKey:@"active"];
        if ([active isEqualToString:@"true"]) {
            searchData.m_activeCrowd = YES;
        } else {
            searchData.m_activeCrowd = NO;
        }
        
        NSString * official = [dict objectForKey:@"official"];
        if ([official isEqualToString:@"true"]) {
            searchData.m_officialCrowd = YES;
        } else {
            searchData.m_officialCrowd = NO;
        }

    } else if ([itemType isEqualToString:@"group_chat"]) {
        searchData.m_strHeaderImagePath = [dict objectForKey:@"head"];
        searchData.m_name = [dict objectForKey:@"showname"];
        searchData.m_jid = [dict objectForKey:@"jid"];
    }
    return searchData;
}

- (void)refreshSearchTableView:(NSMutableArray *)dataArr
{
    NSLog(@"FriendsSectionInfo delegate");
    self.m_arrSearchData = dataArr;
    [self addGroupMemberNamesToDataArr:self.m_arrSearchData];
}

- (void)addGroupMemberNamesToDataArr:(NSMutableArray *)dataArr
{
    BOOL hasGroup = NO;
    
    BOOL hasCrowd = NO;
    
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        LocalSearchData * data = [dataArr objectAtIndex:i];
        if ([data.m_type isEqualToString:@"group_chat"]) {
            [self getDiscussionGroupData];
            hasGroup = YES;
            break;
        }
    }
    
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        LocalSearchData * data = [dataArr objectAtIndex:i];
        if ([data.m_type isEqualToString:@"crowd_chat"]) {
            [self getCrowdData];
            hasCrowd = YES;
            break;
        }
    }
    
    if (hasGroup == NO && hasCrowd == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_delegate sendSearchData:self.m_arrSearchData];
        });
    }
}

// 获取 讨论组data
- (void)getDiscussionGroupData
{
    [[DiscussionManager shareInstance] addListener:self];
    [[DiscussionManager shareInstance] getDiscussionList];
}

/**
 *  得到讨论组信息成功
 *
 *  @param discussionList 讨论组列表
 */
- (void) getDiscussionFinish:(NSArray*) discussionList
{
    NSArray * discussionArr = [NSArray arrayWithArray:discussionList];
    NSArray * groupMemberNamesArr = [self getGroupDataArrWithType:@"membersName" withDataArr:discussionArr];

    for (NSUInteger i = 0; i < [self.m_arrSearchData count]; i++) {
        LocalSearchData * searchData = [self.m_arrSearchData objectAtIndex:i];
        if ([searchData.m_type isEqualToString:@"group_chat"]) {
            for (NSUInteger j = 0; j < [discussionArr count]; j++) {
                ChatGroupInfo * chatGroupInfo = [discussionArr objectAtIndex:j];
                if ([searchData.m_jid isEqualToString:chatGroupInfo.sessionId]) {
                    searchData.m_groupTotalName = [groupMemberNamesArr objectAtIndex:j];
                    searchData.m_chatGroupInfo = chatGroupInfo;
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate sendSearchData:self.m_arrSearchData];
    });
}

- (NSMutableArray *)getGroupDataArrWithType:(NSString *)type withDataArr:(NSArray *)dataArr
{
    NSMutableArray * dataNewArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        ChatGroupInfo * groupInfo = [dataArr objectAtIndex:i];
        if ([type isEqualToString:@"sessionId"]) {
            [dataNewArr addObject:groupInfo.sessionId];
        } else if ([type isEqualToString:@"groupName"]) {
            [dataNewArr addObject:groupInfo.groupName];
        } else if ([type isEqualToString:@"membersName"]) {
            NSString * memberNames = [self getOneGroupTotalName:groupInfo.members];
            [dataNewArr addObject:memberNames];
        }
    }
    return dataNewArr;
}

- (NSString *)getOneGroupTotalName:(NSMutableArray *)groupArr
{
    NSString * totalName = @"";
    LOG_UI_INFO(@"each group arr data == %@", groupArr);
    
    for (NSUInteger i = 0; i < [groupArr count]; i++) {
        DiscussionMemberInfo * memberInfo = [groupArr objectAtIndex:i];
        if (memberInfo) {
            NSString * memberName = memberInfo.showName;
            
            if (memberName) {
                totalName = [totalName stringByAppendingString:memberName];
                totalName = [totalName stringByAppendingString:@" "];
            } else {
                memberName = @"微哨用户";
            }
            
            if ([memberName length] <= 0) {
                memberName = @"微哨用户";
            }
        }
    }
    LOG_UI_INFO(@"each group total name str == %@", totalName);
    return totalName;
}

#pragma mark -
#pragma mark - 获取群信息
- (void)getCrowdData
{
    [[CrowdManager shareInstance] addListener:self];
    [[CrowdManager shareInstance] getCrowdList];
}

/**
 *  获取群列表成功后的事件
 */
- (void) getCrowdListFinish:(NSMutableArray*) crowdList
{
    for (NSUInteger i = 0; i < [self.m_arrSearchData count]; i++) {
        LocalSearchData * searchData = [self.m_arrSearchData objectAtIndex:i];
        if ([searchData.m_type isEqualToString:@"crowd_chat"]) {
            for (NSUInteger j = 0; j < [crowdList count]; j++) {
                CrowdInfo * crowdInfo = [crowdList objectAtIndex:j];
                if ([searchData.m_jid isEqualToString:crowdInfo.session_id]) {
                    searchData.m_crowdInfo = crowdInfo;
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate sendSearchData:self.m_arrSearchData];
    });
}

@end
