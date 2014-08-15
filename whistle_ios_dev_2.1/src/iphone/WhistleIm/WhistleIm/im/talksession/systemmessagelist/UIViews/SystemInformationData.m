//
//  SystemInformationData.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemInformationData.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "SystemMessageInfo.h"
#import "RosterManager.h"
#import "SystemMsgManager.h"

#define SYSTEM_SEND_DATE @"sendDate"
#define SYSTEM_MESSAGE @"systemMessage"

@interface SystemInformationData ()
<SystemMsgDelegate>
{
    NSMutableArray * m_arrAllSectionData;
    NSArray * m_arrTotalData;
    NSMutableDictionary * m_dictTotalData;
    
    BOOL m_totalCount;
    
    BOOL m_needReverse;
}

@property (nonatomic, strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic, strong) NSArray * m_arrTotalData;
@property (nonatomic, strong) NSMutableDictionary * m_dictTotalData;

@end

@implementation SystemInformationData

@synthesize m_arrAllSectionData;
@synthesize m_arrTotalData;
@synthesize m_dictTotalData;

@synthesize m_delegate;


- (id)init
{
    self = [super init];
    if (self) {
        [self setMemory];
        [[SystemMsgManager shareInstance] addListener:self];
    }
    return self;
}

- (void)setMemory
{
    self.m_arrAllSectionData = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)clearNoticeMemory
{
    [self.m_arrAllSectionData removeAllObjects];
}

-(void)constructSystemMessageTableViewDataWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count
{
    [self getDataWithStartIndex:startIndex andCount:count];
}

- (void)sendData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_delegate sendSystemMessage:self.m_dictTotalData andTotalCount:m_totalCount];
    });
}

- (void)getDataWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count
{
    NSLog(@"get system info from startIndex  == %d, and count == %d", startIndex, count);
    [[SystemMsgManager shareInstance] getSystemMsgList:startIndex withCount:count];
}

// delete
- (void)deleteSystemMsg:(SystemMessageInfo *)messageInfo
{
    [[SystemMsgManager shareInstance] deleteSystemMsg:messageInfo withCallback:^(BOOL success) {
        
    }];
}

/**
 *  系统消息列表变更事件，消息完整后会发此事件
 *
 *  @param sysList 系统消息的集合
 */
- (void) systemMsgListChanged:(NSArray*) sysList
{
    m_needReverse = NO;
    m_totalCount = sysList.count;
    [self clearNoticeMemory];
    [self parserData:sysList];
    [self sendData];
}

/**
 *  得到系统消息成功,一般情况下是默认数据
 *
 *  @param sysList 系统消息列表
 */
- (void) getSystemMsgListFinish:(NSArray*) sysList countAll:(int) count_all
{
    m_totalCount = count_all;
    m_needReverse = YES;
    [self parserData:sysList];
    [self sendData];
}

- (void)parserData:(NSArray *)dataArr
{
    [self addSystemMessageToAllDataArr:dataArr];
}

- (void)addSystemMessageToAllDataArr:(NSArray *)copy
{
    [self.m_arrAllSectionData removeAllObjects];
    for (SystemMessageInfo *mesaageInfo in copy) {
        [self.m_arrAllSectionData addObject:mesaageInfo];
    }
    
    NSLog(@"m_arrAllSectionData === %@", self.m_arrAllSectionData);

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [dict setObject:self.m_arrAllSectionData forKey:SYSTEM_MESSAGE];
    self.m_dictTotalData = [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (void)reverseDataArr
{
    [self reversedArrayOrder:self.m_arrAllSectionData];
    
    for (NSUInteger i = 0; i < [self.m_arrAllSectionData count]; i++) {
        NSMutableArray * eachSectionArr = [self.m_arrAllSectionData objectAtIndex:i];
        [self reversedArrayOrder:eachSectionArr];
    }
}

- (void)reversedArrayOrder:(NSMutableArray *)array
{
    for (NSUInteger i = 0; i < [array count] / 2; i++) {
        [array exchangeObjectAtIndex:i withObjectAtIndex:[array count] - 1 - i];
    }
}


@end
