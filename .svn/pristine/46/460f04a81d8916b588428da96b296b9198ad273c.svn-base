//
//  ReceivedNewInfo.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceivedNewInfoDelegate <NSObject>

- (void)hiddenOrShowRedSpotIndicatorWithIndex:(NSUInteger)index andIsHidden:(BOOL)hidden;

@end

@interface ReceivedNewInfo : NSObject
{
    __weak id <ReceivedNewInfoDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <ReceivedNewInfoDelegate> m_delegate;
@end
