//
//  VoteCellInfo.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteCellInfo : NSObject
{
    NSString * m_content;
    BOOL m_isSingle;
    BOOL m_isSelectedState;
    BOOL m_hasHeaderLine;
    

}

@property (nonatomic, strong) NSString * m_content;
@property (nonatomic, assign) BOOL m_isSingle;
@property (nonatomic, assign) BOOL m_isSelectedState;
@property (nonatomic, assign) BOOL m_hasHeaderLine;
@property (nonatomic, assign) CGFloat m_percentage;
@property (nonatomic, strong) NSString * m_percentageStr;

@end
