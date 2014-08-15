//
//  NetworkBrokenView.h
//  WhistleIm
//
//  Created by liuke on 13-10-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NetworkBrokenDelegate <NSObject>

- (void) setShowNetworkBrokenTip: (BOOL) isShow;

@end

@interface NetworkBrokenView : UIView

//SINGLETON_DEFINE(NetworkBrokenView)
- (void) addListener:(id) listner;
//得到view的宽度
- (CGFloat) getWidth;
//得到view的高度
- (CGFloat) getHeight;

+ (NetworkBrokenView*) createView;


@end
