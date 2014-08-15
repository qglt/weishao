//
//  SearchFriendsTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocalSearchData;
@protocol SearchFriendsTableViewDelegate <NSObject>

- (void)didSelectFriendIndexWithID:(LocalSearchData *)searchData andType:(NSString *)type;
- (void)searchFriendsTableViewScrolled;
- (void)showCrowdAlockingAlert;
@end

@interface SearchFriendsTableView : UIView
{
    __weak id <SearchFriendsTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <SearchFriendsTableViewDelegate> m_delegate;

- (void)refreshTableViewWithDataArr:(NSMutableArray *)dataArr andSearchText:(NSString *)text;

@end
