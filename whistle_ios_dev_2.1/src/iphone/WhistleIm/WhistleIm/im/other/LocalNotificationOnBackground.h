//
//  LocalNotificationOnBackground.h
//  WhistleIm
//
//  Created by liuke on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface LocalNotificationOnBackground : NSObject

SINGLETON_DEFINE(LocalNotificationOnBackground)
- (void) registerListener;

@end
