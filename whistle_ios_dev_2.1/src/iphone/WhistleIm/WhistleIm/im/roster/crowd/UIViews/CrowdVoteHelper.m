//
//  CrowdVoteHelper.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-22.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdVoteHelper.h"
#import "CrowdManager.h"
#import "CrowdVoteInfo.h"
#import "CrowdVoteItmes.h"

@interface CrowdVoteHelper ()
{
    CrowdVoteInfo * m_crowdVoteInfo;
}

@property (nonatomic, strong) CrowdVoteInfo * m_crowdVoteInfo;
@end

@implementation CrowdVoteHelper
@synthesize m_delegate;
@synthesize m_crowdVoteInfo;

// 群列表信息
- (void)getCrowdVoteDataWithGid:(NSString *)gid
{
    NSLog(@"gid == %@", gid);
    [[CrowdManager shareInstance] voteList:gid callback:^(NSArray * voteDataArr) {
        NSLog(@"vote list arr == %@", voteDataArr);
        [self logDataWithArr:voteDataArr];
    }];
}

- (void)logDataWithArr:(NSArray *)voteData
{
    for (NSUInteger i = 0; i < [voteData count]; i++) {
        self.m_crowdVoteInfo = [voteData objectAtIndex:i];
        NSLog(@"%@", self.m_crowdVoteInfo);
        
        NSLog(@"vote crowd gid == %@", self.m_crowdVoteInfo.gid);
        NSLog(@"voteTitle == %@", self.m_crowdVoteInfo.title);
        NSLog(@"single == %d", self.m_crowdVoteInfo.single);
        NSLog(@"anonymous == %d", self.m_crowdVoteInfo.anonymous);
        NSLog(@"timesTamp == %@", self.m_crowdVoteInfo.timesTamp);
        
        NSLog(@"vid == %@", self.m_crowdVoteInfo.vid);
        NSLog(@"vote person jid == %@", self.m_crowdVoteInfo.jid);
        NSLog(@"name == %@", self.m_crowdVoteInfo.name);
        NSLog(@"totalCount == %d", self.m_crowdVoteInfo.totalCount);
        NSLog(@"voteItems == %@", self.m_crowdVoteInfo.voteItems);
    }
}

// 提交自己所选择的票
- (void)voteMySelectedWithJid:(NSString *)jid voteId:(int)vid iids:(NSString *)iids name:(NSString *)name
{
    NSLog(@"vote my card");
    [[CrowdManager shareInstance] startVote:jid voteId:vid iids:iids name:name callback:^(CrowdVoteInfo * voteInfo) {
        self.m_crowdVoteInfo = voteInfo;
        NSLog(@"%@", self.m_crowdVoteInfo);
        
        NSLog(@"vote crowd gid == %@", self.m_crowdVoteInfo.gid);
        NSLog(@"voteTitle == %@", self.m_crowdVoteInfo.title);
        NSLog(@"single == %d", self.m_crowdVoteInfo.single);
        NSLog(@"anonymous == %d", self.m_crowdVoteInfo.anonymous);
        NSLog(@"timesTamp == %@", self.m_crowdVoteInfo.timesTamp);
        
        NSLog(@"vid == %@", self.m_crowdVoteInfo.vid);
        NSLog(@"vote person jid == %@", self.m_crowdVoteInfo.jid);
        NSLog(@"name == %@", self.m_crowdVoteInfo.name);
        NSLog(@"totalCount == %d", self.m_crowdVoteInfo.totalCount);
        NSLog(@"voteItems == %@", self.m_crowdVoteInfo.voteItems);
        NSLog(@"m_arrSelfVoted in crowdVoteHelper == %@", self.m_crowdVoteInfo.m_arrSelfVoted);

        for (NSUInteger i = 0; i < [self.m_crowdVoteInfo.voteItems count]; i++) {
            CrowdVoteItmes * voteItems = [self.m_crowdVoteInfo.voteItems objectAtIndex:i];
            NSLog(@"itemName == %@", voteItems.itemName);
            NSLog(@"iid == %d", voteItems.iid);
            NSLog(@"members == %@", voteItems.members);
            NSLog(@"count == %d", voteItems.count);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_delegate sendVoteData:self.m_crowdVoteInfo];
        });
    }];
}
@end
