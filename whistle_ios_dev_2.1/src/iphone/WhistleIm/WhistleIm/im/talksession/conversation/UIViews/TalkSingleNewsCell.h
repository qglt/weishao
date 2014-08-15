//
//  TalkSingleNewsCell.h
//  WhistleIm
//
//  Created by LI on 14-3-5.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LightAppMessageInfo;
@interface TalkSingleNewsCell : UITableViewCell

-(void)setupCellWith:(LightAppMessageInfo *)info;
@property(nonatomic,strong) UIImageView *background;
@end
