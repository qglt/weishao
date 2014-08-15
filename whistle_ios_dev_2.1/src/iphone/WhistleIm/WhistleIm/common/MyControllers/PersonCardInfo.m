//
//  PersonCardInfo.m
//  WhistleIm
//
//  Created by 管理员 on 13-11-19.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PersonCardInfo.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "FriendInfo.h"
#import "RosterManager.h"


@interface PersonCardInfo ()
<RosterDelegate>
{
    BOOL m_isStranger;
}

@end

@implementation PersonCardInfo

@synthesize m_delegate;

- (id)init
{
    self = [super init];
    if (self) {
        [[RosterManager shareInstance] addListener:self];
    }
    return self;
}

//获得用户详情
- (void)getUserDetailInfoWithJid:(NSString *)jid
{
    [[RosterManager shareInstance] getUserDetailInfo:jid withCallback:^(FriendInfo * friend) {
        [self sendFriendDetailInfo:friend];
    }];
}

//获得用户详情 回调
- (void)sendFriendDetailInfo:(FriendInfo *)friendInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate sendFriendInfo:friendInfo];
    });
}

// 获取微友与我的关系
- (void)getRelationshipWithJid:(NSString *)jid
{
    m_isStranger = NO;
    [[RosterManager shareInstance] getRelationShip:jid WithCallback:^(enum FriendRelation relationShip) {
        if (relationShip == RelationStranger || relationShip == RelationNone) {
            m_isStranger = YES;
        } else if (relationShip == RelationContact) {
            m_isStranger = NO;
        }
        
        [self sendStrangerInfomation:m_isStranger];
    }];
}

// 获取微友与我的关系 回调
- (void)sendStrangerInfomation:(BOOL)isStranger
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)deleteFriendWithFriendInfo:(FriendInfo *)friendInfo
{
    [[RosterManager shareInstance] removeBuddy:friendInfo withCallback:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_delegate deleteFriendSuccess];
            });
        }
    }];
}


/**
 *  好友信息更新后
 *
 *  @param friend 变化后的好友信息
 */
- (void) updateFriendInfo:(FriendInfo*) friend
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate friendInfoUpdate:friend];
    });
}

@end
