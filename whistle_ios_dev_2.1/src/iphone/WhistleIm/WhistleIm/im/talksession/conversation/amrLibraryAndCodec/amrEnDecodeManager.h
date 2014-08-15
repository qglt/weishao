//
//  amrEnDecodeManager.h
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-13.
//  Copyright (c) 佛历2557年 ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol RecordSoundManagerDelegate <NSObject>

-(void)changeMicImageAccoerdingPeakpower:(double)peakPower;
-(void)loopPlay;

-(void)error:(NSString *)error;

-(void)ended;

-(void)changeHUDTimeLabelText:(NSString *)time;

@end

@interface amrEnDecodeManager : NSObject

@property (nonatomic,weak)id<RecordSoundManagerDelegate>delegate;
+(amrEnDecodeManager *)sharedManager;

-(void)startRecord;
-(void)stopRecord:(void(^)(NSDictionary *dict))callBack;
-(void)cancelRecord;

-(void)startPlay:(NSString *)src;
-(void)stopPlay;

-(void)deleteFile:(NSString *)filePath;
@end
