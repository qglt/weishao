//
//  FriendsSectionInfo.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-23.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendsSectionInfoDelegate <NSObject>

- (void)sendFriendData:(NSMutableDictionary *)friendDataDict;
- (void)sendSearchData:(NSMutableArray *)searchDataArr;

@end

@interface FriendsSectionInfo : NSObject
{
    __weak id <FriendsSectionInfoDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <FriendsSectionInfoDelegate> m_delegate;
- (void)getAllFriendsSectionsAndDataDictWith:(BOOL)isRefresh;
- (void)findContactWithSeachText:(NSString *)searchText;

@end
