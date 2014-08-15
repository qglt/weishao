//
//  PersonCardInfo.h
//  WhistleIm
//
//  Created by 管理员 on 13-11-19.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FriendInfo;

@protocol PersonCardInfoDelegate <NSObject>

- (void)sendFriendInfo:(FriendInfo *)friendInfo;
- (void)deleteFriendSuccess;
- (void)friendInfoUpdate:(FriendInfo *)friendInfo;

@end

@interface PersonCardInfo : NSObject
{
    __weak id <PersonCardInfoDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <PersonCardInfoDelegate> m_delegate;

- (void)getUserDetailInfoWithJid:(NSString *)jid;
- (void)getRelationshipWithJid:(NSString *)jid;
- (void)deleteFriendWithFriendInfo:(FriendInfo *)friendInfo;
@end
