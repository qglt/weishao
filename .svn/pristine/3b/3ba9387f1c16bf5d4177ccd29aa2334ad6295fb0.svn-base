//
//  TalkToImgCell.h
//  WhistleIm
//
//  Created by wangchao on 13-9-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConversationInfo;
@class LightAppMessageInfo;


@interface TalkToImgCell : UITableViewCell

@property (nonatomic,strong) UIImageView *imageBgView;
@property (nonatomic,strong) UIImageView *contentImg;
@property (nonatomic,strong) UIActivityIndicatorView *indicator;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *timeImage;
@property(nonatomic,strong) UIImageView * headImageview;

-(void) setupCell:(ConversationInfo *)convInfo withCallback:(void (^)(void))callback;

-(void)setupLightCell:(LightAppMessageInfo *)lightInfo withCallback:(void (^)(void))callback;

@end
