//
//  RectentItemCell.h
//  WhistleIm
//
//  Created by wangchao on 13-8-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGScrollableTableViewCell.h"

@class RecentRecord;
@class JGScrollableTableViewCellAccessoryButton;

@interface RecentItemCell : JGScrollableTableViewCell;

@property (nonatomic,strong)  UIImageView *headView;

@property (nonatomic,strong)  UIImageView *unreadBg;

@property (nonatomic,strong)  UILabel *nameLabel;

@property (nonatomic,strong)  UILabel *contentLabel;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong)  UILabel *unreadLabel;

@property (nonatomic,strong)  UIImageView *stateImg;

@property (nonatomic,strong)  UILabel *stateLabel;

@property (nonatomic,strong)  UIImageView *identityImg;

@property (nonatomic,strong)  UIImageView *crowdHotImg;

@property (nonatomic,strong)  UIImageView *crowdOfficialImg;

@property (nonatomic,strong)  UIButton    *headBtn;

@property (nonatomic,strong)  UIButton    *unreadBtn;

@property (nonatomic,strong)  JGScrollableTableViewCellAccessoryButton *actionView;

-(void) setupCell:(RecentRecord *) record;

@end
