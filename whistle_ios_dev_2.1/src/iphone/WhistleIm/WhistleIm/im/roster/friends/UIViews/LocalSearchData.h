//
//  LocalSearchData.h
//  WhistleIm
//
//  Created by 管理员 on 13-11-5.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FriendInfo;
@class ChatGroupInfo;
@class CrowdInfo;
@interface LocalSearchData : NSObject
{
    NSString * m_strHeaderImagePath; // 好友，群，讨论组, 要展示的头像
    NSString * m_name; // 好友，群，讨论组, 要展示的名称
    NSString * m_jid; // 好友，群，讨论组, jid
    NSString * m_type; // 好友或群或讨论组，类型区别字段
    NSString * m_friedIdentity; // 区分好友的老师或者学生身份
    NSString * m_groupTotalName; // 讨论组所有成员名字
    NSString * m_sexShow; // 好友 性别
    NSString * m_category; // 群类别
    
    BOOL m_officialCrowd;
    BOOL m_activeCrowd;
    
    ChatGroupInfo * m_chatGroupInfo;
    CrowdInfo * m_crowdInfo;
}

@property (nonatomic, strong) NSString * m_strHeaderImagePath;
@property (nonatomic, strong) NSString * m_name;
@property (nonatomic, strong) NSString * m_jid;
@property (nonatomic, strong) NSString * m_type;
@property (nonatomic, strong) NSString * m_friedIdentity;
@property (nonatomic, strong) NSString * m_groupTotalName;
@property (nonatomic, strong) NSString * m_sexShow;
@property (nonatomic, strong) NSString * m_category;
@property (nonatomic, assign) BOOL m_officialCrowd;
@property (nonatomic, assign) BOOL m_activeCrowd;

@property (nonatomic, strong) ChatGroupInfo * m_chatGroupInfo;
@property (nonatomic, strong) CrowdInfo * m_crowdInfo;


@end
