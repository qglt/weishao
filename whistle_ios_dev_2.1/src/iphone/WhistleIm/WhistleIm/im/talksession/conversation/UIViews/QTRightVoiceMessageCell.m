//
//  QTRightVoiceMessageCell.m
//  WhistleIm
//
//  Created by ruijie on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "QTRightVoiceMessageCell.h"
#import "ImUtils.h"

@interface QTRightVoiceMessageCell()
{
    UIImageView * bgImage;
    UIButton * messageButton;
    UILabel * frameTimeLabel;
    UILabel * timeLabel;
    UIImageView * timeImage;
    float timecontrol;
    int animationImageControl;
    int frameTimeControl;

    NSInteger _duration;
    long  _stdTime;
    BOOL _isPlay;
}
@property (nonatomic,strong) UIImageView * bgImage;
@property (nonatomic,strong) UIButton * messageButton;
@property (nonatomic,strong) UIImageView * animationImage;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) UILabel * frameTimeLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UIImageView * timeImage;
@end

@implementation QTRightVoiceMessageCell
@synthesize bgImage;
@synthesize messageButton;
@synthesize animationImage;
@synthesize timer;
@synthesize frameTimeLabel;
@synthesize headImageView;
@synthesize timeLabel;
@synthesize timeImage;
@synthesize superTableView;
@synthesize cellSelected;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBasicContains];
        [self createHeadImage];
        [self createMessageButton];
        [self createBackgroundImage];
        [self createTimeLabel];
        [self createFrameTimeLabel];
        [self createTimeImage];
        [self createAnimationImage];
    }
    return self;
}
-(void)changeSubViews
{
    messageButton.frame = CGRectMake(0, 0, 100 + (210 - 99) * _duration/60.0, 60);
    messageButton.center = CGPointMake(headImageView.frame.origin.x - 5 - messageButton.frame.size.width /2.0f, 10 + messageButton.frame.size.height /2.0f);
    
    bgImage.frame = CGRectMake(0, 0, messageButton.frame.size.width, messageButton.frame.size.height);
    
    timeImage.frame = CGRectMake(12, messageButton.frame.size.height - 20, 10, 10);
    
    timeLabel.text =[ImUtils formatMessageTime:[NSString stringWithFormat:@"%ld",_stdTime]];
    [timeLabel sizeToFit];
    timeLabel.frame = CGRectMake(27, messageButton.frame.size.height - 22, timeLabel.frame.size.width, timeLabel.frame.size.height);
    
    frameTimeLabel.frame = CGRectMake(0, 0, 65, 15);
    frameTimeLabel.center = CGPointMake(messageButton.frame.size.width - 12 - frameTimeLabel.frame.size.width/2.0, 12 + frameTimeLabel.frame.size.height/2.0);
    frameTimeLabel.text = [NSString stringWithFormat:@"%d s",_duration];
    animationImage.center = CGPointMake(12 + animationImage.frame.size.width/2.0f, animationImage.frame.size.height/2.0f + 12);
}
-(void)setCellDataDuration:(NSInteger)duration stdTime:(long long)stdTimed isPlay:(BOOL)isPlayed
{
    _duration = duration;
    _stdTime = stdTimed;
    _isPlay = isPlayed;
    [self changeSubViews];
}
-(void)setBasicContains
{
    cellSelected = NO;
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, 320, 30);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
-(void)createHeadImage
{
    headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 10, 40, 40)];
    headImageView.layer.cornerRadius = 20.0f;
    headImageView.layer.masksToBounds = YES;
    headImageView.userInteractionEnabled = YES;
    
    [self addSubview:headImageView];
    
    timecontrol = 0;
    animationImageControl = 0;
    frameTimeControl = 0;
}
-(void)createMessageButton
{
    messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton addTarget:self action:@selector(messageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:messageButton];
}
-(void)createBackgroundImage
{
    bgImage = [[UIImageView alloc]init];
    bgImage.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right" WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:0 topCapHeight:0];
    
    [messageButton addSubview:bgImage];
}
-(void)createTimeImage
{
    timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time"]];
    timeImage.backgroundColor = [UIColor clearColor];
    [messageButton addSubview:timeImage];
}
-(void)createTimeLabel
{
    timeLabel = [[UILabel alloc] init];
    
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textColor = [UIColor colorWithRed:237.0f/ 255.0f green:237.0f/ 255.0f blue:237.0f/ 255.0f alpha:1.0f];
    timeLabel.backgroundColor = [UIColor clearColor];
    
    [messageButton addSubview:timeLabel];
}
-(void)createFrameTimeLabel
{
    frameTimeLabel = [[UILabel alloc]init];
    frameTimeLabel.textAlignment = NSTextAlignmentRight;
    frameTimeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    frameTimeLabel.textColor = [UIColor whiteColor];
    frameTimeLabel.backgroundColor = [UIColor clearColor];
    [messageButton addSubview:frameTimeLabel];
}
-(void)createAnimationImage
{
    animationImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_qt2"]];
    [messageButton addSubview:animationImage];
}
#pragma mark - operation methods
-(void)messageButtonPressed:(UIButton *)sender
{
    cellSelected = !cellSelected;
    frameTimeLabel.text = @"0 s";
    [self.delegate voiceMessageButtonPressedAtCell:self];
}
-(void)beganAnimation
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.25f target:self selector:@selector(changeMessageButtonContaint) userInfo:nil repeats:YES];

}
-(void)stopAnimation
{
    [timer invalidate];
    frameTimeLabel.text = [NSString stringWithFormat:@"%i s", _duration];
    animationImage.image = [UIImage imageNamed:@"voice_qt2"];
    timecontrol = 0;
    animationImageControl = 0;
    frameTimeControl = 0;
    cellSelected = NO;
}
-(void)changeMessageButtonContaint
{
    timecontrol += 0.25;
    if (timecontrol > _duration) {
        [self stopAnimation];
    }else{
        if (++frameTimeControl %4 == 0) {
            frameTimeLabel.text = [NSString stringWithFormat:@"%.0f s",timecontrol];
        }
        animationImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_qt%d",animationImageControl++%3]];
    }
}
-(BOOL)getSelected
{
    return cellSelected;
}

-(void)setSelected:(BOOL)selected
{
    cellSelected = selected;
}
@end
