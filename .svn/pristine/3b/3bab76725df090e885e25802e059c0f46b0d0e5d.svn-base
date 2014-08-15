//
//  CrowdAndGroupInfo.m
//  WhistleIm
//
//  Created by 管理员 on 13-11-4.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CrowdAndGroupInfo.h"
#import "Whistle.h"
#import "ChatGroupInfo.h"
#import "GroupCellData.h"
#import "FriendInfo.h"
#import "CrowdManager.h"
#import "DiscussionManager.h"
#import "RosterManager.h"
#import "ChatGroupInfo.h"
#import "DiscussionMemberInfo.h"


@interface CrowdAndGroupInfo ()
<DiscussionDelegate, CrowdDelegate>

{
    NSMutableArray * m_arrGroupTitle;
    NSMutableArray * m_arrMemberName;
    NSMutableArray * m_arrGroupId;
    
    NSMutableDictionary * m_dictDiscussion;
    NSMutableDictionary * m_dictMember;
    
    
    NSMutableArray * m_arrCrowdData;
    
    CrowdManager * m_crowdManager;
    
    
    // new memory start
    NSMutableArray * m_arrDiscussion;
}

@property (nonatomic, strong) NSMutableArray * m_arrGroupTitle;
@property (nonatomic, strong) NSMutableArray * m_arrMemberName;
@property (nonatomic, strong) NSMutableArray * m_arrGroupId;
@property (nonatomic, strong) NSMutableArray * m_arrCrowdData;


@property (nonatomic, strong) NSMutableDictionary * m_dictDiscussion;
@property (nonatomic, strong) NSMutableDictionary * m_dictMember;
@property (nonatomic, strong) CrowdManager * m_crowdManager;
@property (nonatomic, strong) NSMutableArray * m_arrDiscussion;




@end
@implementation CrowdAndGroupInfo

@synthesize m_arrGroupTitle;
@synthesize m_arrMemberName;
@synthesize m_arrGroupId;
@synthesize m_arrCrowdData;
@synthesize m_dictDiscussion;
@synthesize m_dictMember;
@synthesize m_crowdManager;

@synthesize m_delegate;

@synthesize m_arrDiscussion;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMemory];
        [[CrowdManager shareInstance] addListener:self];
        [[DiscussionManager shareInstance] addListener:self];
    }
    return self;
}

- (void)setMemory
{
    self.m_arrGroupTitle = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrMemberName = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrGroupId = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)createAlertViewWithErrorMessage:(NSString *)errorMessage
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


#pragma mark -
#pragma mark - 获取讨论组数据
- (void)getDisccussionData
{
    [[DiscussionManager shareInstance] getDiscussionList];
}

/**
 *  讨论组列表信息变更
 *
 *  @param discussionList 讨论组列表
 */
- (void) discussionListChanged:(NSArray*) discussionList
{
    self.m_arrDiscussion = (NSMutableArray *)discussionList;
    [self reconsitutionGroupData];
}
/**
 *  讨论组成员信息变更
 *
 *  @param discussionList 讨论组列表
 */
- (void) discussionMemberChanged:(NSArray *)discussionList
{
//    self.m_arrDiscussion = (NSMutableArray *)discussionList;
//    [self reconsitutionGroupData];
}

/**
 *  得到讨论组信息成功
 *
 *  @param discussionList 讨论组列表
 */
- (void) getDiscussionFinish:(NSArray*) discussionList
{
    self.m_arrDiscussion = (NSMutableArray *)discussionList;
    [self reconsitutionGroupData];
}

/**
 *  得到讨论组列表失败
 */
- (void) getDiscussionFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createAlertViewWithErrorMessage:@"get Discussion Failure"];
        [self getDisccussionData];
    });
}

- (void)reconsitutionGroupData
{
    [self setMemory];
    self.m_arrGroupId = [self getGroupDataArrWithType:@"sessionId"];
    self.m_arrGroupTitle = [self getGroupDataArrWithType:@"groupName"];
    self.m_arrMemberName = [self getGroupDataArrWithType:@"membersName"];
    NSMutableArray * totalCellDataArr = [self getGroupCellData];
    [self sendData:totalCellDataArr];
}

- (NSMutableArray *)getGroupDataArrWithType:(NSString *)type
{
    NSMutableArray * dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [self.m_arrDiscussion count]; i++) {
        ChatGroupInfo * groupInfo = [self.m_arrDiscussion objectAtIndex:i];
        if ([type isEqualToString:@"sessionId"]) {
            [dataArr addObject:groupInfo.sessionId];
        } else if ([type isEqualToString:@"groupName"]) {
            [dataArr addObject:groupInfo.groupName];
        } else if ([type isEqualToString:@"membersName"]) {
            NSString * memberNames = [self getOneGroupTotalName:groupInfo.members];
            [dataArr addObject:memberNames];
        }
    }
    return dataArr;
}

- (void)sendData:(NSMutableArray *)dataArr
{
    LOG_UI_INFO(@"send group data");
    NSLog(@"sendData -- dataArr == %@", dataArr);
    for (NSUInteger i= 0; i < [dataArr count]; i++) {
        GroupCellData * cellData = [dataArr objectAtIndex:i];
        NSLog(@"m_strGroupId == %@", cellData.m_strGroupId);
        NSLog(@"m_strGroupName == %@", cellData.m_strGroupName);
        NSLog(@"m_strMemberName == %@", cellData.m_strMemberName);
    }
    if (m_delegate) {
        [m_delegate sendGroupAllData:dataArr];
    }
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

- (NSMutableArray *)getGroupCellData
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [self.m_arrGroupId count]; i++) {
        GroupCellData * cellData = [[GroupCellData alloc] init];
        cellData.m_strGroupId = [self.m_arrGroupId objectAtIndex:i];
        
        if ([self.m_arrGroupTitle count] > i) {
            cellData.m_strGroupName = [self.m_arrGroupTitle objectAtIndex:i];
        }
        if ([self.m_arrMemberName count] > i) {
            cellData.m_strMemberName = [self.m_arrMemberName objectAtIndex:i];
        }
        
        ChatGroupInfo * groupInfo = [self.m_arrDiscussion objectAtIndex:i];
        cellData.m_chatGroupInfo = groupInfo;

        [array addObject:cellData];
    }
    return array;
}


#pragma mark -
#pragma mark - 获取群信息
- (void)getCrowdData
{
    [[CrowdManager shareInstance] getCrowdList];
}

/**
 *  群列表发生变更,crowd_list是CrowdInfo对象数组
 *
 *  @param crowd_list 群列表变更后的CrowdInfo集合
 */
- (void) crowdListChanged: (NSMutableArray*) crowd_list
{
    [self sendCrowdData:crowd_list];
}

/**
 *  获取群列表成功后的事件
 */
- (void) getCrowdListFinish:(NSMutableArray*) crowdList
{
    [self sendCrowdData:crowdList];
}

/**
 *  获取群列表失败后的事件
 */
- (void) getCrowdListFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createAlertViewWithErrorMessage:@"get Crowd Failure"];
        [self getCrowdData];
    });
}

- (void)sendCrowdData:(NSMutableArray *)dataArr
{
    NSLog(@"sendCrowdData");
    [self logCrowdData:dataArr];
    [m_delegate sendCrowdAllData:dataArr];
}

- (void)logCrowdData:(NSMutableArray *)dataArr
{
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        CrowdInfo * info = [dataArr objectAtIndex:i];
        NSLog(@"icon === %@, name == %@  category == %d, official == %d", info.icon, info.name, info.category, info.official);
    }
}

@end
