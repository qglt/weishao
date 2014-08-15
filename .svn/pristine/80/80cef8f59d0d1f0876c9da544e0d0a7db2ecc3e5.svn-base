//
//  amrEnDecodeManager.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-13.
//  Copyright (c) 佛历2557年 ruijie. All rights reserved.
//

#import "amrEnDecodeManager.h"
#import "amrFileCodec.h"
@interface amrEnDecodeManager ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    NSInteger RecordTimeCounter;
}
@property (nonatomic,strong)NSString* PCMFilePath;
@property (nonatomic,strong)NSString* amrFilePath;

@property (nonatomic,strong)AVAudioPlayer * audioPlayer;
@property (nonatomic,strong)AVAudioRecorder * recorder;
@property (nonatomic,strong)AVAudioSession * audioSession;

@property (nonatomic,strong)NSMutableDictionary* historySoundMessage;
@property (nonatomic,strong)NSString* LocalSoundPath;

@property (nonatomic,strong)NSTimer * timer;


@end

amrEnDecodeManager * manager = nil;
@implementation amrEnDecodeManager

@synthesize PCMFilePath;
@synthesize amrFilePath;
@synthesize audioPlayer;
@synthesize recorder;
@synthesize audioSession;
@synthesize historySoundMessage;
@synthesize LocalSoundPath;
@synthesize timer;

+(amrEnDecodeManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[amrEnDecodeManager alloc]init];
    });
    return manager;
}

-(id)init
{
    if (self = [super init]) {
        audioSession = [AVAudioSession sharedInstance];
    }
    return self;
}

#pragma mark - record methods
-(void)startRecord
{
    RecordTimeCounter = 0;
    self.PCMFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]];
    self.amrFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"amr"]];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
    
    NSError *sessionError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if (sessionError) {
        NSLog(@"AVAudioSession setCategory error = %@",sessionError.localizedDescription);
        sessionError = nil;
    }
    [audioSession setActive:YES error: &sessionError];
    if (sessionError) {
        NSLog(@"AVAudioSession setCategory error = %@",sessionError.localizedDescription);
    }
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init] ;
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSURL* tmpFile = [NSURL fileURLWithPath:PCMFilePath];
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:tmpFile settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
    
    [recorder prepareToRecord];
    [recorder record];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}
-(void)updateMeters
{
    if (recorder) {
        [recorder updateMeters];
    }

    RecordTimeCounter ++;
    if (RecordTimeCounter % 20 == 0) {
        [self sendRecordTimeToController:RecordTimeCounter / 20];
    }

    float peakPower = [recorder averagePowerForChannel:0];
    double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    [self.delegate changeMicImageAccoerdingPeakpower:peakPowerForChannel];
}
-(void)sendRecordTimeToController:(NSInteger)recordTime
{
    NSLog(@"%--------------------------d",recordTime);
    NSString * timeString;
    if (recordTime < 10) {
        timeString = [NSString stringWithFormat:@"0%d",recordTime];
        [self.delegate changeHUDTimeLabelText:timeString];
    }else if(recordTime <60){
        timeString = [NSString stringWithFormat:@"%d",recordTime];
        [self.delegate changeHUDTimeLabelText:timeString];
    }else{
        timeString = @"录音时间过长";
        [self.delegate error:timeString];
        [self.delegate ended];
        [timer invalidate];
        RecordTimeCounter = 0;
    }
}
-(void)stopRecord:(void (^)(NSDictionary *))callBack
{
    [recorder stop];
    [timer invalidate];
    if (RecordTimeCounter < 20) {
        [self.delegate error:@"录音时间太短"];
    }else{
        NSData* tmpPCMData = [NSData dataWithContentsOfFile:self.PCMFilePath];
        [self encodePCMToAMRFormat:tmpPCMData];
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:amrFilePath,@"filePath",[NSNumber numberWithInteger:RecordTimeCounter / 20],@"recordTime", nil];
        callBack(dict);
    }
    [self deleteFile:PCMFilePath];
    RecordTimeCounter = 0;
    recorder = nil;
    timer = nil;
    callBack(nil);
}
-(void)cancelRecord
{
    [recorder stop];
    [timer invalidate];
    [self deleteFile:PCMFilePath];
}
-(void)deleteFile:(NSString *)filePath
{
    NSError * error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"Error: %@!",error.userInfo);
    }
}

#pragma mark - play method
-(void)startPlay:(NSString *)src
{
    [self decodeAMRToPCMWithSrc:src andCallBack:^(NSData *data) {
        NSError *sessionError = nil;
        [audioSession setActive:YES error: &sessionError];
        if (sessionError) {
            NSLog(@"AVAudioSession setCategory error = %@",sessionError.localizedDescription);
        }

        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        
        if (!self.audioPlayer) {
            
            NSLog(@"Error: %@",error.localizedDescription);
        }
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;//kAudioSessionOverrideAudioRoute_None

        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,sizeof(audioRouteOverride),&audioRouteOverride);
        self.audioPlayer.delegate = self; // 设置代理
        self.audioPlayer.numberOfLoops = 0;// 不循环播放
        [self.audioPlayer prepareToPlay];// 准备播放
        [self.audioPlayer play];// 开始播放
    }];
}
-(void)stopPlay
{
    NSError * sessionError = nil;
    [audioSession setActive:NO error:&sessionError];
    if (sessionError) {
        NSLog(@"AVAudioSession setCategory error = %@",sessionError.localizedDescription);
    }
    [audioPlayer stop];
}
#pragma mark - Data coding methods
-(void)encodePCMToAMRFormat:(NSData*)data
{
    NSData* tmpAMRData = EncodeWAVEToAMR(data, 1, 16);
    [tmpAMRData writeToFile:amrFilePath atomically:YES];
}

-(void)decodeAMRToPCMWithSrc:(NSString *)src andCallBack:(void (^)(NSData * data))callBack
{
    NSData* tmpAMRData = [NSData dataWithContentsOfFile:src];
    
    NSData* tmpPCMData = DecodeAMRToWAVE(tmpAMRData);
    
    callBack(tmpPCMData);
}
#pragma mark - AVAudioRecorderDelegate Methods - 
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSError * sessionError = nil;
    [audioSession setActive:NO error:&sessionError];
    if (sessionError) {
        NSLog(@"AVAudioSession setCategory error = %@",sessionError.localizedDescription);
    }
}
#pragma mark - AVAudioPlayer delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSError * sessionError = nil;
    [audioSession setActive:NO error:&sessionError];
    if (sessionError) {
        NSLog(@"%s : AVAudioSession setCategory error = %@",__FUNCTION__,sessionError.localizedDescription);
    }
    if (flag) {
        [self.delegate loopPlay];
    }
}
@end



