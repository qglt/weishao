//
//  QTTalkHUD.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-10.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import "QTTalkHUD.h"

@interface QTTalkHUD ()
{
    UIImageView * micImage;
    UIImageView * cancelImage;
    UIImageView * warnImage;
    UILabel * timeLabel;
    UILabel * textLabel;
}
@property (nonatomic,strong) UIImageView * micImage;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * textLabel;
@property (nonatomic,strong) UIImageView * cancelImage;
@property (nonatomic,strong) UIImageView * warnImage;
@end

@implementation QTTalkHUD
@synthesize micImage;
@synthesize cancelImage;
@synthesize warnImage;
@synthesize timeLabel;
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBasicStyle];
        [self createMicImage];
        [self createCanCelImage];
        [self createWarnImage];
        [self createTimeLabel];
        [self createTextLabel];
    }
    return self;
}
-(void)setBasicStyle
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.55f];
    //self.layer.masksToBounds = YES;
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 11)];
    label.center = CGPointMake(self.frame.size.width/2.0f + 25, self.frame.size.height/2.0f - label.frame.size.height / 2.0);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    label.text = @"s";
    label.tag = 10;
    [self addSubview:label];
}
-(void)createMicImage
{
    self.micImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mic_menu_qt"]];
    micImage.center = CGPointMake(self.frame.size.width / 2.0f - 22, self.frame.size.height/4.0 + 2);
    [self addSubview:micImage];
}
-(void)createCanCelImage
{
    self.cancelImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_cancel_qt"]];
    cancelImage.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 4.0 + 6);
    cancelImage.hidden = YES;
    [self addSubview:cancelImage];
}
-(void)createWarnImage
{
    self.warnImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_warn_qt"]];
    warnImage.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 4.0 + 6);
    warnImage.hidden = YES;
    [self addSubview:warnImage];
}
-(void)createTimeLabel
{
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    timeLabel.center = CGPointMake(self.frame.size.width / 2.0f+8 , self.frame.size.height/2.0f - timeLabel.frame.size.height /2.0);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"00";
    timeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self addSubview:timeLabel];
}
-(void)createTextLabel
{
    self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, self.frame.size.height / 2.0f)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height / 2.0 * 1.5);
    textLabel.text = @"上滑取消发送";
    textLabel.font =  [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self addSubview:textLabel];
}

-(void)changeTimeLabelText:(NSString *)text
{
    if ([text intValue] >= 50) {
        timeLabel.textColor = [UIColor redColor];
    }
    timeLabel.text = text;
}

-(void)warnError:(NSString *)error
{
    [self.micImage removeFromSuperview];
    [self.timeLabel removeFromSuperview];
    [self.cancelImage removeFromSuperview];
    UILabel * label = (UILabel *)[self viewWithTag:10];
    [label removeFromSuperview];
    self.warnImage.hidden = NO;
    self.textLabel.text = error;
}
-(void)willCancel
{
    self.micImage.hidden = YES;
    self.timeLabel.hidden = YES;
    self.warnImage.hidden = YES;
    UILabel * label = (UILabel *)[self viewWithTag:10];
    label.hidden = YES;
    self.cancelImage.hidden = NO;
    self.textLabel.text = @"松开取消发送";
}
-(void)reSet
{
    self.micImage.hidden = NO;
    self.timeLabel.hidden = NO;
    UILabel * label = (UILabel *)[self viewWithTag:10];
    label.hidden = NO;
    self.cancelImage.hidden = YES;
    self.warnImage.hidden = YES;
    self.textLabel.text = @"上滑取消发送";
}
@end




