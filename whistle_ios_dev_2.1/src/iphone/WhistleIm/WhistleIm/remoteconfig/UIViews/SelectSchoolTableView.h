//
//  SelectSchoolTableView.h
//  test
//
//  Created by 移动组 on 13-12-11.
//  Copyright (c) 2013年 曾長歡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteConfigInfo.h"
@protocol selectViewDelegate <NSObject>

@optional
- (void)confirmSchool:(NSString *)str;
- (void)sendConfirmSchool:(RemoteConfigInfo *)info;

@end
@interface SelectSchoolTableView : UIView

@property (nonatomic, weak)id <selectViewDelegate>selectViewDelegate;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *keyArray;
@property (assign, nonatomic) BOOL isSearching;
@end
