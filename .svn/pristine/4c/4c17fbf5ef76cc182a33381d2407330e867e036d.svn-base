//
//  CrowdVoteHelper.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-22.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CrowdVoteInfo;

@protocol CrowdVoteHelperDelegate  <NSObject>

- (void)sendVoteData:(CrowdVoteInfo *)voteInfo;

@end

@interface CrowdVoteHelper : NSObject
{
    __weak id <CrowdVoteHelperDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CrowdVoteHelperDelegate> m_delegate;
- (void)getCrowdVoteDataWithGid:(NSString *)gid;

- (void)voteMySelectedWithJid:(NSString *)jid voteId:(int)vid iids:(NSString *)iids name:(NSString *)name;
@end
