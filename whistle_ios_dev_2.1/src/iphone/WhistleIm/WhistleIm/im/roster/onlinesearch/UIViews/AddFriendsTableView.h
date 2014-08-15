//
//  AddFriendsTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendInfo;

@protocol AddFriendsTableViewDelegate <NSObject>

- (void)didSelectedRowWithFriendInfo:(NSUInteger)index;
- (void)sendSelectedTypeToController:(NSString *)selectedType andSearchKey:(NSString *)key andMaxCounter:(NSUInteger)counter andIndex:(NSUInteger)pageIndex isCommond:(BOOL)isCommond;
- (void)pushToPersonCardViewController:(NSUInteger)index;

- (void)showNoneTextAlert;
@end

@interface AddFriendsTableView : UIView
{
    __weak id <AddFriendsTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <AddFriendsTableViewDelegate> m_delegate;


- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableData;

- (void)refreshTableData:(NSMutableArray *)tableDataArr andSelectedType:(NSString *)type;
- (void)hiddenEmptySearchResultView:(BOOL)isShow andText:(NSString *)text;

@end
