//
//  CrowdVoteInfo.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdVoteInfo.h"
#import "JSONObjectHelper.h"
#import "CrowdVoteItmes.h"
@implementation CrowdVoteInfo

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.gid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"gid"];//
        self.title = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"title"];//
        self.single = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"single" defaultValue:1];//
        self.anonymous = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"anonymous" defaultValue:0];//
        self.timesTamp = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"timestamp"];//
        self.vid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"vid"];//
        self.jid = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"jid"];//
        self.name = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"name"];//
        self.totalCount = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"count" defaultValue:0];
        self.pollMember = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"poll_member" defaultValue:0];
        self.m_arrSelfVoted = [jsonObj objectForKey:@"self_vote"];
        
        NSArray * voteItemsArr = [JSONObjectHelper getObjectArrayFromJsonObject:jsonObj forKey:@"items" withClass:[CrowdVoteItmes class]];
        if ([[NSNull null] isEqual:voteItemsArr ]) {
            self.voteItems = nil;
        }else{
            self.voteItems = voteItemsArr;
        }
    }
    return self;
}

@end
