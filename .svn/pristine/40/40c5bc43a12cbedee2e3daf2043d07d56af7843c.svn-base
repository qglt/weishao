//
//  AddFriendsInfo.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddFriendsInfoDelegate <NSObject>

- (void)sendFrindsInfoToControllerWithArr:(NSMutableArray *)dataArr;

// 没有查找到
- (void)sendNoneResultMessageToController:(NSString *)noneResult;
- (void)sendStrangerOrNot:(BOOL)isFriend;

// 出错
- (void)sendErrorMessageToController:(NSString *)errorMsg;
@end

@interface AddFriendsInfo : NSObject
{
    __weak id <AddFriendsInfoDelegate> m_delegate;
    BOOL m_isCommond;
}

@property (nonatomic, weak) __weak id <AddFriendsInfoDelegate> m_delegate;
@property (nonatomic, assign) BOOL m_isCommond;


- (void)getFriendsData:(NSString *)selectedType andSearchKey:(NSString *)searchText andStartIndex:(NSUInteger)startIndex andMaxCounter:(NSUInteger)counter;
- (void)getRelationshipWithJid:(NSString *)jid;
@end
