//
//  FeedbackManager.h
//  WhistleIm
//
//  Created by liuke on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SendFeedbackDelegate <NSObject>

- (void) sucessed;

- (void) failure:(NSData*) data WithError: (NSError*) error;

@end

@interface FeedbackManager : NSObject
{
    __weak id<SendFeedbackDelegate> _delegate;
}

@property (weak, nonatomic) __weak  id<SendFeedbackDelegate> delegate;

- (id) init: (NSDictionary*) json;

- (void) sendContent: (NSString*) info;

@end
