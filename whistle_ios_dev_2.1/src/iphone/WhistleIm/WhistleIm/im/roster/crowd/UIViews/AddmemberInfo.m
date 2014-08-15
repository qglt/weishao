//
//  AddmemberInfo.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddmemberInfo.h"
#import "FriendInfo.h"
#import "Whistle.h"
#import "RosterManager.h"
#import "FriendGroup.h"
#import "LocalSearchData.h"
#import "CrowdAndGroupInfo.h"
#import "GroupCellData.h"
#import "JSONObjectHelper.h"
#import "FriendGroupSectionInfo.h"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"

@interface AddmemberInfo ()
<RosterDelegate>

{
    // 好友的所有信息
    NSMutableArray * m_arrFriendsTotalInfo;
    NSMutableArray * m_arrSearchData;
}
@property (nonatomic,strong) NSMutableArray * m_arrFriendsTotalInfo;
@property (nonatomic,strong) NSMutableArray * m_arrSearchData;
@end



@implementation AddmemberInfo

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

- (void)setMemory
{
    self.m_arrSearchData = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)createAlertViewWithErrorMessage:(NSString *)errorMessage
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark -
#pragma mark - 好友数据源
- (void)getAllFriendsSectionsAndDataDict
{
    [[RosterManager shareInstance] getRoster:NO];
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
        [self getAllFriendsSectionsAndDataDict];
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
        
//        NSLog(@"add member friend group name == %@", group.name);
//        if ([group.name isEqualToString:@"黑名单"] || [group.name isEqualToString:@"陌生人"]) {
//            continue;
//        }
        sectionInfo.name = group.name;
        sectionInfo.onlineCount = group.onlineCount;
        sectionInfo.totalCount = group.totalCount;
        [sectionTitleArr addObject:sectionInfo];
    }
    
    //    [self logSectionInfoWithArr:sectionTitleArr];
    
    NSLog(@"sectionTitleArr == %@", sectionTitleArr);
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
        
//        NSLog(@"add member friend group name == %@", group.name);
//        if ([group.name isEqualToString:@"黑名单"] || [group.name isEqualToString:@"陌生人"]) {
//            continue;
//        }
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

- (LocalSearchData *)getLocalSearchDataWithItem:(NSDictionary *)dict
{
    NSString *itemType = [dict objectForKey:@"type"];
    
    if([itemType isEqualToString:@"conversation"] ){
        LocalSearchData * searchData = [[LocalSearchData alloc] init];
        searchData.m_strHeaderImagePath = [dict objectForKey:@"head"];
        searchData.m_name = [dict objectForKey:@"showname"];
        searchData.m_jid = [dict objectForKey:@"jid"];
        searchData.m_friedIdentity = [dict objectForKey:@"identity_show"];
        NSLog(@"searchData.m_friedIdentity ---> %@", searchData.m_friedIdentity);
        searchData.m_sexShow = [dict objectForKey:@"sex_show"];
        return searchData;
    } else {
        return nil;
    }
}

- (void)refreshSearchTableView:(NSMutableArray *)dataArr
{
    NSLog(@"FriendsSectionInfo delegate");
    self.m_arrSearchData = dataArr;
    dispatch_async(dispatch_get_main_queue(), ^{
         [m_delegate sendSearchData:self.m_arrSearchData];
    });
}

@end
