//
//  TalkFromImgCell.h
//  WhistleIm
//
//  Created by wangchao on 13-9-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConversationInfo;

@interface TalkFromImgCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UIImageView *imageBgView;
@property (nonatomic,strong) UIImageView *contentImg;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *timeImage;

-(void) setupCell:(ConversationInfo *)layoutInfo withCallback:(void (^)(void))callback;

@end
