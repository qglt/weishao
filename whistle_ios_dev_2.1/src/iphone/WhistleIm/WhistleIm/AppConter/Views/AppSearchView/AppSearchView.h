//
//  AppSearchView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-2-19.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSearchBar.h"
@class BaseAppInfo;
@protocol AppSearchViewDelegate <NSObject>

- (void)searchApp:(NSString *)searchString;
- (void)pushDetail:(BaseAppInfo *)info;
- (void)pushTalk:(BaseAppInfo *)info;
@end

@interface AppSearchView : UIView<JGScrollableTableViewCellDelegate>
@property (nonatomic, strong) CustomSearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) id<AppSearchViewDelegate>appSearchDelegate;
@property (nonatomic, weak) id<CustomSearchBarDelegate>searchDelegate;

- (void)pickUpCellWithCell:(CustomScrollTableViewCell *)cell;
@end
