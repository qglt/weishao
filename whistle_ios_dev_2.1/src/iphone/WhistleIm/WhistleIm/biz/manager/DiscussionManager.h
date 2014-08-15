//
//  DisscussionManager.h
//  WhistleIm
//
//  Created by wangchao on 13-8-12.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BizBridge.h"
#import "Manager.h"


@class FriendInfo;
@class ChatGroupInfo;
@class RosterManager;
@protocol DiscussionListChangedListener;
@protocol DiscussionMemberChangedListener;

@protocol DiscussionDelegate <NSObject>

@optional
/**
 *  讨论组列表信息变更
 *
 *  @param discussionList 讨论组列表
 */
- (void) discussionListChanged:(NSArray*) discussionList;
/**
 *  讨论组成员信息变更
 *
 *  @param discussionList 讨论组列表
 */
- (void) discussionMemberChanged:(ChatGroupInfo *) discussion;

/**
 *  得到讨论组信息成功
 *
 *  @param discussionList 讨论组列表
 */
- (void) getDiscussionFinish:(NSArray*) discussionList;

/**
 *  得到讨论组列表失败
 */
- (void) getDiscussionFailure;

/**
 *  讨论组被销毁
 *
 *  @param info 被销毁讨论组的对象
 */
- (void) discussionBeDistroy:(ChatGroupInfo*) info;

/**
 *  创建讨论组成功
 *
 *  @param info 讨论组信息
 */
- (void) createDiscussionFinish:(ChatGroupInfo *)info;


@end

@interface DiscussionManager : Manager
SINGLETON_DEFINE(DiscussionManager)

- (void) getDiscussionList;

- (BOOL) checkDisscusionIsDistroy:(NSString*) jid;

- (ChatGroupInfo*) getDiscussion:(NSString*) jid;
/**
 *  创建讨论组
 *
 *  @param groupName 讨论组名
 *  @param list      好友jid集合
 */
- (void) createChatGroup:(NSString*) groupName friends:(NSArray*) list callback:(void(^)(BOOL)) callback;
/**
 *  获取讨论组成员列表，以discussionMemberChanged协议输出结果
 *
 *  @param session_id 讨论组id
 */
- (void) getDiscussionMember:(NSString*) session_id callback:(void(^)(ChatGroupInfo*)) callback;
/**
 *  将好友添加到讨论组
 *
 *  @param session_id    讨论组id
 *  @param friendJidList 好友的jid集合
 */
- (void) inviteIntoDiscussion:(NSString*) session_id friend:(NSArray*) friendJidList callback:(void(^)(BOOL)) callback;
/**
 *  退出讨论组
 *
 *  @param session_id 讨论组id
 */
- (void) leaveDiscussion:(NSString*) session_id callback:(void(^)(BOOL)) callback;
/**
 *  修改讨论组名字
 *
 *  @param session_id 讨论组id
 *  @param name       修改的讨论组名字
 */
- (void) setDiscussionName:(NSString*) session_id name:(NSString*) name callback:(void(^)(BOOL)) callback;

@end
