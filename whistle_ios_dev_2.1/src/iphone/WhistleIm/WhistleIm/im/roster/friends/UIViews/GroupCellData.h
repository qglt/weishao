//
//  GroupCellData.h
//  WhistleIm
//
//  Created by 管理员 on 13-11-4.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatGroupInfo;
@interface GroupCellData : NSObject
{
    NSString * m_strGroupName;
    NSString * m_strMemberName;
    NSString * m_strGroupId;
    ChatGroupInfo * m_chatGroupInfo;
}

@property (nonatomic, strong) NSString * m_strGroupName;
@property (nonatomic, strong) NSString * m_strMemberName;
@property (nonatomic, strong) NSString * m_strGroupId;
@property (nonatomic, strong) ChatGroupInfo * m_chatGroupInfo;

@end
