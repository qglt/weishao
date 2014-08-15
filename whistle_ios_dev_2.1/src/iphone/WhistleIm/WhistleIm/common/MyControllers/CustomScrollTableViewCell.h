//
//  CustomScrollTableViewCell.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "JGScrollableTableViewCell.h"
#import "RootScrollView.h"
#import "RatingControl.h"
#import "BaseAppInfo.h"
@class JGScrollableTableViewCellAccessoryButton;

@interface CustomScrollTableViewCell : JGScrollableTableViewCell
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *appType;
@property (nonatomic, strong) UILabel *organizationLabel;
@property (nonatomic, strong) UILabel *popularityLable;
@property (nonatomic, strong) RatingControl *ratingControl;
@property (nonatomic, strong) JGScrollableTableViewCellAccessoryButton *actionView;
@property (nonatomic, weak)id<RootScrollViewDelegate>scrollViewDelegate;
-(void) setupCell:(BaseAppInfo *) info;
@end
