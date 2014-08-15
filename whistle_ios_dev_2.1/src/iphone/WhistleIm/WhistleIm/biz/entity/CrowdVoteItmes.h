//
//  CrowdVoteItmes.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrowdVoteItmes :BaseMessageInfo
@property (nonatomic, strong) NSString *itemName;//投票选项
@property (nonatomic, assign) NSInteger iid;//选项的ID
@property (nonatomic, strong) NSString *members;

// 每一个投票项有多少人投了
@property (nonatomic, assign) NSUInteger count;
@end
