//
//  LocalRecentListManager.h
//  WhistleIm
//
//  Created by wangchao on 13-8-8.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BizlayerProxy.h"
#import "Manager.h"
#import "RecentRecord.h"




@protocol LocalRecentListDelegate <NSObject>


@optional
- (void) localRecentListChanged:(NSMutableArray*) list;

- (void) getLocalRecentListFinish:(NSMutableArray*) list;

- (void) getLocalRecentListFailure;

- (void) updateRecentListUnReadCount:(NSUInteger) count;

- (void) updateRecentRecord:(RecentRecord*) rec;

@end


@interface LocalRecentListManager : Manager
{
    
}

SINGLETON_DEFINE(LocalRecentListManager)

- (void) getRecentList;

- (void) removeRecentContact:(NSString*) jid withCallback:(void(^)(BOOL)) callback;

- (void) removeRecentSystemContact:(void(^)(BOOL)) callback;

@end
