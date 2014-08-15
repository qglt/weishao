//
//  PromptToneSetting.m
//  PromptSound
//
//  Created by 管理员 on 13-10-11.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "PromptToneSetting.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>



@interface PromptToneSetting ()
<AVAudioPlayerDelegate>
{
    AVAudioPlayer * m_audioPlayer;
    BOOL m_canPlayNext;
}

@property (nonatomic, strong) AVAudioPlayer * m_audioPlayer;
@property (nonatomic, assign) BOOL m_canPlayNext;

@end

@implementation PromptToneSetting

@synthesize m_promptType;
@synthesize m_audioPlayer;
@synthesize m_canPlayNext;

+ (id)sharedInstance
{
    static PromptToneSetting * setting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        setting = [[PromptToneSetting alloc] init];
        setting.m_canPlayNext = YES;
    });
    
    return setting;
}

- (void)playPromptToneOrShake
{
    NSLog(@"start m_canPlayNext == %d", m_canPlayNext);

    if (self.m_canPlayNext) {
        self.m_canPlayNext = NO;
        NSLog(@"play tone or shake start");
        if ([self.m_promptType isEqualToString:TONE_TYPE]) {
            NSLog(@"play tone start");
            [self playSound];
        } else if ([self.m_promptType isEqualToString:SHAKE_TYPE]) {
            NSLog(@"play shake start");
            [self playShake];
        } else if ([self.m_promptType isEqualToString:TONE_AND_SHAKE_TYPE]) {
            NSLog(@"play tone and shake start");
            [self playPromptToneAndShake];
        }
    }
}

- (void)playSound
{
    NSString * musicPath = [[NSBundle mainBundle]  pathForResource:@"msg" ofType:@"wav"];
    
    if (musicPath) {
        NSURL * musicURL = [NSURL fileURLWithPath:musicPath];
        self.m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        self.m_audioPlayer.delegate = self;
        [self.m_audioPlayer play];
    }
}

- (void)playShake
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self isShakeType]) {
        [self performSelector:@selector(prepareNextPlay) withObject:nil afterDelay:1.0f];
    }
}

- (void)playPromptToneAndShake
{
    [self playShake];
    [self playSound];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (![self isShakeType]) {
        [self performSelector:@selector(prepareNextPlay) withObject:nil afterDelay:1.0f];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (![self isShakeType]) {
        [self performSelector:@selector(prepareNextPlay) withObject:nil afterDelay:1.0f];
    }
}

- (void)prepareNextPlay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        m_canPlayNext = YES;
    });
}

- (BOOL)isShakeType
{
    BOOL result = NO;
    if ([self.m_promptType isEqualToString:SHAKE_TYPE] || [self.m_promptType isEqualToString:TONE_AND_SHAKE_TYPE]) {
        result = YES;
    }
    return result;
}

@end
