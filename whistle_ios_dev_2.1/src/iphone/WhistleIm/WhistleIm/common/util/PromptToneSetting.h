//
//  PromptToneSetting.h
//  PromptSound
//
//  Created by 管理员 on 13-10-11.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TONE_TYPE @"tone"
#define SHAKE_TYPE @"shake"
#define TONE_AND_SHAKE_TYPE @"toneAndShake"

@interface PromptToneSetting : NSObject
{
    NSString * m_promptType;
}

@property (nonatomic, strong) NSString * m_promptType;

+ (id)sharedInstance;
- (void)playPromptToneOrShake;

@end
