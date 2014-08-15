//
//  VotePercentageInfo.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VotePercentageInfo : NSObject
{
    NSString * m_itemName;
    CGFloat m_progress;
    NSString * m_percentageStr;
    BOOL m_isMySelected;
}

@property (nonatomic, strong) NSString * m_itemName;
@property (nonatomic, assign) CGFloat m_progress;
@property (nonatomic, strong) NSString * m_percentageStr;
@property (nonatomic, assign) BOOL m_isMySelected;

@end
