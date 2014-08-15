//
//  FeedbackView.h
//  WhistleIm
//
//  Created by liuke on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackView : UIScrollView

- (enum EMOTION) getEmotion;

- (NSString*) getContent;

- (void) endEditing;

@end
