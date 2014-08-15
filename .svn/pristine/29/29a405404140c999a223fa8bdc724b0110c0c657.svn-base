//
//  EmoView.h
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SmileyInfo;
@protocol EmoViewDelegate <NSObject>

-(void) EmoViewTouchDown:(SmileyInfo *) smileyInfo with:(UIButton *)button;

-(void) EmoViewTouchUpInSide:(SmileyInfo *) smileyInfo with:(UIButton *)button;

-(void) EmoViewTouchUpOutSide:(SmileyInfo *) smileyInfo with:(UIButton *)button;

@end

@interface EmoView : UIView

@property(nonatomic,assign) id<EmoViewDelegate> delegate;
@property(nonatomic,strong) NSMutableArray*  data;


-(void) loadEmoViewfromData:(NSMutableArray *)data numColumns:(int)numColumns size:(CGSize)size;

@end
