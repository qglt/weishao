//
//  AddCrowdsInfo.h
//  WhistleIm
//
//  Created by ruijie on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol addCrowdInfoDelegate <NSObject>

- (void)sendCrowdsInfoToControllerWithArr:(NSMutableArray *)dataArr;

// 没有查找到
- (void)sendNoneResultMessageToController:(NSString *)noneResult;
- (void)sendStrangeOrNot:(BOOL)isMine;

// 出错
- (void)sendErrorMessageToController:(NSString *)errorMsg;
@end

@interface AddCrowdsInfo : NSObject
{
    __weak id <addCrowdInfoDelegate> m_delegate;
    BOOL m_isCommond;
}

@property (nonatomic, weak) __weak id <addCrowdInfoDelegate> m_delegate;
@property (nonatomic, assign) BOOL m_isCommond;

- (void)getCrowdsData:(NSString *)selectedType andSearchKey:(NSString *)searchText andStartIndex:(NSUInteger)startIndex andMaxCounter:(NSUInteger)counter;
- (void)getRelationshipWithJid:(NSString *)jid;

@end
