//
//  QTLeftVoiceMessageCell.h
//  WhistleIm
//
//  Created by ruijie on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTVoiceMessageCellDelegate <NSObject>

-(void)voiceMessageButtonPressedAtCell:(id)cell;

@end

@interface QTLeftVoiceMessageCell : UITableViewCell
{
    UIImageView * headImageView;
    UITableView * superTableView;
    BOOL cellSelected;
}
@property (nonatomic,weak) id<QTVoiceMessageCellDelegate>delegate;
@property (nonatomic,strong) ConversationInfo * inputObject;
@property (nonatomic,strong) UIImageView * headImageView;
@property (nonatomic,strong) UITableView * superTableView;

-(void)changeSubViews;
-(void)beganAnimation;
-(void)stopAnimation;

-(void)setSelected:(BOOL)selected;
-(BOOL)getSelected;

-(void)setCellDataDuration:(NSInteger)duration stdTime:(long long)stdTimed isPlay:(BOOL)isPlayed;

@end
