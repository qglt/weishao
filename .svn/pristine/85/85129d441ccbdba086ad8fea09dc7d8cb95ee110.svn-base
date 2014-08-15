//
//  QTVoicePanel.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-10.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import "QTVoicePanel.h"

@interface QTVoicePanel ()

@property (nonatomic,strong) NSTimer * timer;

@end

@implementation QTVoicePanel

@synthesize timer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBasicContanis];
    }
    return self;
}

-(void)setBasicContanis
{
    self.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];

    UIView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voicePanel_bg_qt"]];
    bgImage.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    bgImage.tag = 1;
    [self addSubview:bgImage];
    
    UIImageView * micImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mic_voicePanel"]];
    micImage.center = bgImage.center;
    [self addSubview:micImage];
}

-(void)changeBgImageAccordingPeakPower:(float)peakPower
{
    UIImageView * bgImage = (UIImageView *)[self viewWithTag:1];
    if (peakPower<=0.01) {
        bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt"];
    }else if (peakPower > 0.01 && peakPower < 0.03) {
        bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt1"];
    }else if (peakPower > 0.03 && peakPower < 0.05){
        bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt2"];
    }else if (peakPower > 0.05 && peakPower < 0.07){
        bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt3"];
    }else{
        bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt4"];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImageView * bgImage = (UIImageView *)[self viewWithTag:1];
    bgImage.image = [UIImage imageNamed:@"voicePanel_bgp_qt"];
    
    [self.delegate start];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[[touches allObjects] lastObject] locationInView:self];
    
    if (p.y<=-50) {
        [self.delegate cancel];
    }else{
        [self.delegate end];
    }
    UIImageView * bgImage = (UIImageView *)[self viewWithTag:1];
    bgImage.image = [UIImage imageNamed:@"voicePanel_bg_qt"];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[[touches allObjects] lastObject] locationInView:self];
    if (p.y <= -50) {
        [self.delegate recordWillCancel];
    }else{
        [self.delegate resetHUD];
    }
}

@end
