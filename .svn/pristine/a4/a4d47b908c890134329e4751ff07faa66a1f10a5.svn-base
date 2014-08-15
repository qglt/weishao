//
//  CommentaryView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootScrollView.h"
#import "CommentaryTableViewCell.h"

@class BaseAppInfo;
@interface CommentaryView : UITableView<UITableViewDataSource,UITableViewDelegate,RootScrollViewDelegate>
{
    NSIndexPath *_indexPath;
}
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, weak)id<RootScrollViewDelegate>scrollViewDelegate;
@property (nonatomic, strong) UILabel *scrorcLabel;
@property (nonatomic, strong) UILabel *fiveStarLabel;
@property (nonatomic, strong) UILabel *fourStarLabel;
@property (nonatomic, strong) UILabel *threeStarLabel;
@property (nonatomic, strong) UILabel *twoStarLabel;
@property (nonatomic, strong) UILabel *oneStarLabel;
@property (nonatomic, strong) UIProgressView *fiveStarView;
@property (nonatomic, strong) UIProgressView *fourStarView;
@property (nonatomic, strong) UIProgressView *threeStarView;
@property (nonatomic, strong) UIProgressView *twoStarView;
@property (nonatomic, strong) UIProgressView *oneStarView;
@property (nonatomic, strong) CommentaryTableViewCell *cell;

@property (nonatomic, strong) NSMutableArray *infoArray;

@end



