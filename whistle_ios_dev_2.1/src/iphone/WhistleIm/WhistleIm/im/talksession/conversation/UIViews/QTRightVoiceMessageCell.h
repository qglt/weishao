//
//  QTRightVoiceMessageCell.h
//  WhistleIm
//
//  Created by ruijie on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTVoiceMessageCellDelegate <NSObject>

-(void)voiceMessageButtonPressedAtCell:(id)cell;

@end

@interface QTRightVoiceMessageCell : UITableViewCell
{
    UIImageView * headImageView;
    UITableView * superTableView;
    BOOL cellSelected;
}
@property (nonatomic,assign) BOOL cellSelected;
@property (nonatomic,weak) id<QTVoiceMessageCellDelegate>delegate;
@property (nonatomic,strong) UIImageView * headImageView;
@property (nonatomic,strong) UITableView *superTableView;

-(void)beganAnimation;
-(void)stopAnimation;
-(void)changeSubViews;
-(BOOL)getSelected;

-(void)setSelected:(BOOL)selected;
-(void)setCellDataDuration:(NSInteger)duration stdTime:(long long)stdTimed isPlay:(BOOL)isPlayed;

@end
