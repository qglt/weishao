//
//  AddFriendsInfo.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AddFriendsInfo.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "FriendInfo.h"
#import "ResultInfo.h"
#import "RosterManager.h"

@interface AddFriendsInfo ()
<RosterDelegate>
{
    BOOL m_isFriend;
}

@property (nonatomic,assign) BOOL m_isFriend;

@end

@implementation AddFriendsInfo

@synthesize m_delegate;
@synthesize m_isFriend;
@synthesize m_isCommond;


- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)sendData:(NSMutableArray *)dataArr
{
    [m_delegate sendFrindsInfoToControllerWithArr:dataArr];
    [self logFriendInfoData:dataArr];
}

- (void)logFriendInfoData:(NSMutableArray *)dataArr
{
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        
        FriendInfo * friendInfo = [dataArr objectAtIndex:i];
        NSLog(@"\n\n\n");
        NSLog(@"logFriendInfoData in AddFriendsInfo");

        NSLog(@"friendInfo.head == %@", friendInfo.head);
        NSLog(@"friendInfo.showName == %@", friendInfo.showName);
        NSLog(@"friendInfo.nickName == %@", friendInfo.nickName);
        NSLog(@"friendInfo.sexShow == %@", friendInfo.sexShow);
        NSLog(@"friendInfo.age == %@", friendInfo.age);
        NSLog(@"friendInfo.identity_show == %@", friendInfo.identity_show);
    }
}

- (void)sendNoneResultMessage:(NSString *)noneResult
{
    [m_delegate sendNoneResultMessageToController:noneResult];
}

- (void)sendErrorMessage:(NSString *)errorMessage
{
    [m_delegate sendErrorMessageToController:errorMessage];
}

- (void)getFriendsData:(NSString *)selectedType andSearchKey:(NSString *)searchText andStartIndex:(NSUInteger)startIndex andMaxCounter:(NSUInteger)counter
{
    NSLog(@"getFriendsData start in AddFriendsInfo");
    NSLog(@"selectedType === %@, searchText === %@, startIndex === %d, counter === %d", selectedType, searchText, startIndex, counter);

    OnlineSearchOptions option = SearchByName;
    if ([selectedType isEqualToString:@"name"]) {
        option = SearchByName;
    } else if ([selectedType isEqualToString:@"nick_name"]) {
        option = SearchByNickName;
    } else if ([selectedType isEqualToString:@"aid"]) {
        option = SearchByWhistleId;
    }
    
    [[RosterManager shareInstance] searchFriendsOnline:option searchText:searchText withIndex:startIndex withMax:counter withCallback:^(NSArray * friendsArr) {
        NSLog(@"friendsArr on line == %@", friendsArr);
        NSMutableArray * onlineFriendsArr = nil;
        if (friendsArr && [friendsArr count] > 0) {
            onlineFriendsArr = [NSMutableArray arrayWithArray:friendsArr];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendData:onlineFriendsArr];
            });
        } else if ([friendsArr count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * noneResult = nil;
                if (self.m_isCommond) {
                    noneResult = @"暂无推荐好友";
                } else {
                    noneResult = @"没有搜索到该用户";
                }
                [self sendNoneResultMessage:noneResult];
            });
        }
    }];
}

// 获取微友与我的关系
- (void)getRelationshipWithJid:(NSString *)jid
{
    m_isFriend = NO;
    [[RosterManager shareInstance] getRelationShip:jid WithCallback:^(enum FriendRelation relationShip) {
        if (relationShip == RelationStranger || relationShip == RelationNone) {
            m_isFriend = NO;
        } else if (relationShip == RelationContact) {
            m_isFriend = YES;
        }
        
        [self sendStrangerInfomation:m_isFriend];
    }];
}

- (void)sendStrangerInfomation:(BOOL)isFriend
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate sendStrangerOrNot:isFriend];
    });
}

@end
