//
//  SystemInformationData.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SystemMessageInfo;

@protocol SystemInformationDataDelegate <NSObject>

- (void)sendSystemMessage:(NSMutableDictionary *)dataDict andTotalCount:(NSUInteger)totalCount;


@end


@interface SystemInformationData : NSObject
{
    __weak id <SystemInformationDataDelegate> m_delegate;
}
@property (nonatomic, weak) __weak id <SystemInformationDataDelegate> m_delegate;

-(void)constructSystemMessageTableViewDataWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count;
- (void)deleteSystemMsg:(SystemMessageInfo *)messageInfo;
@end
