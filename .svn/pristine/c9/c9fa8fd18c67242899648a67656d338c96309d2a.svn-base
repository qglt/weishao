//
//  CrowdVoteInfo.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "BaseMessageInfo.h"

@interface CrowdVoteInfo : BaseMessageInfo
@property (nonatomic, strong) NSString *gid;//群ID
@property (nonatomic, strong) NSString *title;//投票标题
@property (nonatomic, assign) NSInteger single;//是否为单选模式
@property (nonatomic, assign) NSInteger anonymous;//是否为匿名投票
@property (nonatomic, strong) NSString *timesTamp;//投票创建时间
@property (nonatomic, strong) NSString *vid;//投票的id
@property (nonatomic, strong) NSString *jid;//创建人的jid
@property (nonatomic, strong) NSString *name;//创建人的姓名
@property (nonatomic, assign) NSInteger totalCount;//总票数
@property (nonatomic, assign) NSInteger pollMember;//参与投票的总人数

@property (nonatomic, strong) id extraInfo;//创建人的friendinfo信息

@property (nonatomic, strong) NSArray *voteItems;//投票项为json数组，且至少为2个，装CrowdVoteItmes对象

// 已经投过票的数据，iid
@property (nonatomic, strong) NSMutableArray * m_arrSelfVoted;
@end
