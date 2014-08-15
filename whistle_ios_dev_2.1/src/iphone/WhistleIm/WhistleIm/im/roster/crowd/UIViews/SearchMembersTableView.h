//
//  SearchMembersTableView.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SearchMembersTableViewDelegate <NSObject>

- (void)searchFriendsTableViewScrolled;

- (void)searchCellDidSelectedWithIndexPath:(NSIndexPath *)indexPath andSelectedJidArr:(NSMutableArray *)selectedJidArr;


@end
@interface SearchMembersTableView : UIView
{
    __weak id <SearchMembersTableViewDelegate> m_delegate;
    NSUInteger m_maxLimitNum;
}

@property (nonatomic, weak) __weak id <SearchMembersTableViewDelegate> m_delegate;
@property (nonatomic, assign) NSUInteger m_maxLimitNum;

- (void)refreshTableViewWithDataArr:(NSMutableArray *)dataArr andSearchText:(NSString *)text andSelectedJidArr:(NSMutableArray *)selectedJidArr;
- (void)sendSelectedStateArr;
@end
