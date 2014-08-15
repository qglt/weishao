//
//  QTVoicePanel.h
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-10.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTVoicePanelDelegate <NSObject>

-(void)start;

-(void)recordWillCancel;

-(void)cancel;

-(void)end;

-(void)resetHUD;

@end

@interface QTVoicePanel : UIView

@property (nonatomic,weak) id <QTVoicePanelDelegate>delegate;
-(void)changeBgImageAccordingPeakPower:(float)peakPower;

@end
