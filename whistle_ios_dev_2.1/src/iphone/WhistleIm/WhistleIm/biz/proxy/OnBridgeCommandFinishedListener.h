//
//  OnBridgeCommandFinishedListener.h
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol OnBridgeCommandFinishedListener <NSObject>

- (void)onCommandFinished:(NSDictionary *)resultJSON;

@end
