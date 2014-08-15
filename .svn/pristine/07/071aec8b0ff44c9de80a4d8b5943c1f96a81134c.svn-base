//
//  QTLeftVoiceMessageCell.m
//  WhistleIm
//
//  Created by ruijie on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "QTLeftVoiceMessageCell.h"
#import "ImUtils.h"

@interface QTLeftVoiceMessageCell()
{
    UIImageView * bgImage;
    UIButton * messageButton;
    UILabel *frameTimeLabel;
    UILabel * timeLabel;
    UIImageView * timeImage;
    UIImageView * unReadFlag;
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
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UIImageView * timeImage;
@property (nonatomic,strong) UIImageView * unReadFlag;
@end

@implementation QTLeftVoiceMessageCell

@synthesize bgImage;
@synthesize messageButton;
@synthesize headImageView;
@synthesize timer;
@synthesize animationImage;
@synthesize timeLabel;
@synthesize timeImage;
@synthesize superTableView;
@synthesize unReadFlag;

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
        [self createUnReadFlag];
    }
    return self;
}
-(void)changeSubViews
{
    messageButton.frame = CGRectMake(headImageView.frame.origin.x + headImageView.frame.size.width + 5, 10, 99 + (210 - 99) * _duration/60, 60);
    bgImage.frame = CGRectMake(0, 0, messageButton.frame.size.width, messageButton.frame.size.height);
    
    timeImage.frame = CGRectMake(messageButton.frame.size.width - 25 - timeLabel.frame.size.width - 5, messageButton.frame.size.height - 20, 10, 10);
    
    timeLabel.text = [ImUtils formatMessageTime:[NSString stringWithFormat:@"%ld",_stdTime]];
    [timeLabel sizeToFit];
    timeLabel.frame = CGRectMake(messageButton.frame.size.width - 15 - timeLabel.frame.size.width, messageButton.frame.size.height - 22, timeLabel.frame.size.width, timeLabel.frame.size.height);
    
    frameTimeLabel.text = [NSString stringWithFormat:@"%i s",_duration];
    
    animationImage.center = CGPointMake(messageButton.frame.size.width - 12 - animationImage.frame.size.width/2.0f, animationImage.frame.size.height/2.0f + 12);
    
    unReadFlag.center = CGPointMake(messageButton.frame.origin.x + messageButton.frame.size.width + 10, messageButton.center.y);
    
    unReadFlag.hidden = _isPlay;
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
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, 320, 30);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    cellSelected = NO;
    timecontrol = 0;
    animationImageControl = 0;
    frameTimeControl = 0;
}
-(void)createHeadImage
{
    headImageView =[[UIImageView alloc] initWithFrame:CGRectMake(10,10, 40, 40)];
    headImageView.layer.cornerRadius = 20.0f;
    headImageView.layer.masksToBounds = YES;
    headImageView.userInteractionEnabled = YES;
    
    [self addSubview:headImageView];
}
-(void)createMessageButton
{
    messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageButton.backgroundColor = [UIColor clearColor];
    [messageButton addTarget:self action:@selector(messageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:messageButton];
}
-(void)createBackgroundImage
{
    bgImage = [[UIImageView alloc]init];
    bgImage.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left" WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:0 topCapHeight:0];
    [messageButton addSubview:bgImage];
}
-(void)createTimeImage
{
    timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time_left"]];
    timeImage.backgroundColor = [UIColor clearColor];
    timeImage.frame = CGRectMake(messageButton.frame.size.width - 25, messageButton.frame.size.height - 20, 10, 10);
    [messageButton addSubview:timeImage];
}
-(void)createTimeLabel
{
    timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textColor = [UIColor colorWithRed:80.0f/ 255.0f green:80.0f/ 255.0f blue:80.0f/ 255.0f alpha:1.0f];
    timeLabel.backgroundColor = [UIColor clearColor];
    [messageButton addSubview:timeLabel];
}
-(void)createFrameTimeLabel
{
    frameTimeLabel = [[UILabel alloc]init];
    frameTimeLabel.backgroundColor = [UIColor clearColor];
    frameTimeLabel.frame = CGRectMake(12, 12, 65, 15);
    frameTimeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    timeLabel.textColor = [UIColor colorWithRed:80.0f/ 255.0f green:80.0f/ 255.0f blue:80.0f/ 255.0f alpha:1.0f];
    [messageButton addSubview:frameTimeLabel];
}
-(void)createAnimationImage
{
    animationImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_left_qt2"]];
    [messageButton addSubview:animationImage];
}
- (void)createUnReadFlag
{
    unReadFlag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    unReadFlag.image = [UIImage imageNamed:@"unreadRedIndicator.png"];
    [self addSubview:unReadFlag];
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
    unReadFlag.hidden = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:.25f target:self selector:@selector(changeMessageButtonContaint) userInfo:nil repeats:YES];
}
-(void)stopAnimation
{
    [timer invalidate];
    frameTimeLabel.text = [NSString stringWithFormat:@"%i s", _duration];
    animationImage.image = [UIImage imageNamed:@"voice_left_qt2"];
    cellSelected = NO;
    timecontrol = 0;
    animationImageControl = 0;
    frameTimeControl = 0;
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
        animationImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_left_qt%d",animationImageControl++%3]];
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
