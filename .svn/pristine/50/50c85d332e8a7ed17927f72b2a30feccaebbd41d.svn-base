//
//  AddMembersTableView.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddMembersTableView <NSObject>

- (void)cancelButtonPressed;
- (void)searchBarTextDidChanged:(NSString *)text;

// 传递选中的jid
- (void)friendCellDidSelectedWithIndexPath:(NSIndexPath *)indexPath andSelectedJidArr:(NSMutableArray *)selectedJidArr;

- (void)showNoneTextAlert;

@end

@interface AddMembersTableView : UIView
{
    __weak id <AddMembersTableView> m_delegate;
    NSUInteger m_maxLimitNum;
}

@property (nonatomic, weak) __weak id <AddMembersTableView> m_delegate;
@property (nonatomic, assign) NSUInteger m_maxLimitNum;

- (id)initWithFrame:(CGRect)frame withDataDict:(NSMutableDictionary *)dict;

// 刷新
- (void)refreshTableView:(NSMutableDictionary *)dictData andSelectedJidArr:(NSMutableArray *)selectedJidArr;

- (void)resignFirstResponderForSearchBar;
@end
