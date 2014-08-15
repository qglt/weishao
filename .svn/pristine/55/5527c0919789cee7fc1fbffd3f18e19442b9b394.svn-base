//
//  AddmemberInfo.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddmemberInfoDelegate <NSObject>

- (void)sendFriendData:(NSMutableDictionary *)friendDataDict;
- (void)sendSearchData:(NSMutableArray *)searchDataArr;

@end

@interface AddmemberInfo : NSObject
{
    __weak id <AddmemberInfoDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <AddmemberInfoDelegate> m_delegate;
- (void)getAllFriendsSectionsAndDataDict;
- (void)findContactWithSeachText:(NSString *)searchText;

@end
