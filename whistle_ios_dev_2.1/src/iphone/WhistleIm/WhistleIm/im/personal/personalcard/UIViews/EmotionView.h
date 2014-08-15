//
//  EmotionView.h
//  WhistleIm
//
//  Created by liuke on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

enum EMOTION {Perfact, Good, Normal, Bad, Sick};

@interface EmotionView : UIView

- (UIView*) createEmotionItem: (enum EMOTION) e WithRect: (CGRect) rect;

- (enum EMOTION) getEmotion;

@end
