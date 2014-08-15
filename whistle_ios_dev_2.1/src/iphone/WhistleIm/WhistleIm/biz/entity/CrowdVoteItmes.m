//
//  CrowdVoteItmes.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdVoteItmes.h"
#import "JSONObjectHelper.h"
@implementation CrowdVoteItmes

- (id) initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [super init];
    if (self) {
        self.iid = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"iid" defaultValue:1];
        self.itemName = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"item"];
        self.members = [JSONObjectHelper getStringFromJSONObject:jsonObj forKey:@"name"];
        self.count = [JSONObjectHelper getIntFromJSONObject:jsonObj forKey:@"count" defaultValue:0];
    }
    return self;
}

@end
