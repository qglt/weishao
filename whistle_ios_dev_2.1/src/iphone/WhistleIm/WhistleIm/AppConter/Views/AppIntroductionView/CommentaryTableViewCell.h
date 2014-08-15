//
//  CommentaryTableViewCell.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppInfo.h"
@interface CommentaryTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *organizationLable;
@property (nonatomic, strong) UILabel *commentLable;
@property (nonatomic, strong) UILabel *creatTimeLabel;
@property (nonatomic, strong) UIImageView *img;
- (void) setCellData:(AppCommentItem *)item;

@end
