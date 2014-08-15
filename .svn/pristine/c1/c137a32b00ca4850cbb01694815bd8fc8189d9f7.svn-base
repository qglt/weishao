//
//  CrowdManager.h
//  WhistleIm
//
//  Created by liuke on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrowdInfo.h"
#import "Manager.h"
#import "FriendInfo.h"
#import "CrowdVoteInfo.h"
@class CrowdVoteInfo;

@protocol CrowdDelegate <NSObject>

@optional
/**
 *  群列表发生变更,crowd_list是CrowdInfo对象数组
 *
 *  @param crowd_list 群列表变更后的CrowdInfo集合
 */
- (void) crowdListChanged: (NSMutableArray*) crowd_list;

/**
 *  获取群列表成功后的事件
 */
- (void) getCrowdListFinish:(NSMutableArray*) crowdList;

/**
 *  获取群列表失败后的事件
 */
- (void) getCrowdListFailure;
/**
 *  获取群成员信息成功后的事件
 *
 *  @param crowd_list 群列表，其中每个群中的成员信息已经填充
 */
- (void) getCrowdMemberFinish:(NSArray*) crowd_list;

/**
 *   获取群成员信息失败后的事件
 */
- (void) getCrowdMemberFailure;
/**
 *  得到群成员列表更新
 *
 *  @param members 群成员列表
 */
- (void) getCrowdMemberChanged:(NSArray*) members;

/**
 *  群被解散后的通知
 *
 *  @param info 被解散群的对象
 */
- (void) crowdBeDismiss:(CrowdInfo*) info;

/**
 *  群被冻结
 *
 *  @param info 被冻结群的对象
 */
- (void) crowdBeFrozen:(CrowdInfo*) info;

/**
 *  群成员信息变更
 *
 *  @param info 群
 */
- (void) crowdMemberChanged:(CrowdInfo*) info;

@end



@interface CrowdManager : Manager
{
    
}
SINGLETON_DEFINE(CrowdManager)

/**
 *  原则上不需要手动调用，在register4Biz中已经调用。只是在获取通知失败后再手动调用该方法
 */
- (void) getCrowdList;

- (UIImage*) getCrowdIcon:(NSString*) jid;

- (void) getCrowdDetailInfoBySessionID: (NSString*) session_id WithCallback: (void(^)(CrowdInfo*)) callback;

//- (void) getCrowdMember:(NSString*) crowd_id withFriendJid:(NSString*) friend_id withCallback:(void (^)(FriendInfo*))callback;

- (BOOL) isCrowdBeDismissOrFrozen:(NSString* ) crowd_jid;

- (CrowdInfo*) getCrowdInfo:(NSString*) jid;
/**
 *  创建群,callback返回参数分别为：是否创建成功、群的session_id、理由
 *
 *  @param name      群名称
 *  @param icon      群图标
 *  @param category  群描述
 *  @param auth_type 群验证类型 0-验证；1-不验证直接加入；2-不允许加入
 */
- (void) createCrowd:(NSString*) name icon:(NSString*) icon category:(NSInteger) category
            authType:(int) auth_type
            callback:(void(^)(BOOL isSuccess, NSString* sessionID, NSString* reason)) callback;
/**
 *  解散群
 *
 *  @param sessionID 群id
 */
- (void) dismissCrowd:(NSString*) sessionID callback:(void(^)(BOOL)) callback;
/**
 *  邀请好友加入群
 *
 *  @param sessionID 群id
 *  @param jid       好友id
 */
- (void) inviteIntoCrowd:(NSString*) sessionID friend:(NSString*) jid callback:(void(^)(BOOL isSucess)) callback;
/**
 *  申请加入群
 *
 *  @param sessionID 群sessionID
 *  @param reason    理由
 */
- (void) applyJoinCrowd:(NSString*) sessionID reason:(NSString*) reason callback:(void(^)(BOOL isSuccess)) callback;

- (void) crowdApplySuperadmin:(NSString*) sessionID reason:(NSString*) reason callback:(void(^)(BOOL)) callback;
/**
 *  从群中踢出成员
 *
 *  @param session_id 群id
 *  @param kickJid    成员的jid
 *  @param reason
 */
- (void) crowdMemberKickout:(NSString *)session_id friend:(NSString *)kickJid reson:(NSString *)reason callback:(void(^)(BOOL isSuceess)) callback;

/**
 *  转让群
 *
 *  @param sessionID 群id
 *  @param jid       接收人的jid
 *  @param callback
 */
- (void) crowdRoleDemise:(NSString*) sessionID friend:(NSString*) jid callback:(void(^)(BOOL isSuceess)) callback;
/**
 *  超级管理员改变其他成员角色为管理员
 *
 *  @param sessionID 群id
 *  @param jid       成员jid
 *  @param callback
 */
- (void) crowdRoleChangeAdmin:(NSString*) sessionID  friend:(NSString*) jid callback:(void(^)(BOOL isSuceess)) callback;

/**
 *  超级管理员改变其他成员角色为普通成员
 *
 *  @param sessionID 群id
 *  @param jid       成员jid
 *  @param callback
 */
- (void) crowdRoleChangeNone:(NSString*) sessionID  friend:(NSString*) jid callback:(void(^)(BOOL isSuceess)) callback;

//- (void) getCrowdInfo;
/**
 *  修改群资料，不需要修改的字段设置为nil，category设置为-1
 *
 *  @param session_id  群sessionid，必填
 *  @param name        群名
 *  @param annouce
 *  @param description
 *  @param icon
 *  @param category    不需要修改时，传-1
 */
- (void) setCrowdInfo:(NSString*) session_id name:(NSString*) name annouce:(NSString*) annouce description:(NSString*) description icon:(NSString*) icon category:(NSInteger) category callback:(void(^)(BOOL)) callback;
/**
 *  得到某个群的所有成员
 *
 *  @param sessionID 群id
 */
- (void) getCrowdMembers:(NSString*) sessionID callback:(void(^)(NSArray*)) callback;
/**
 *  是否可以创建群，callback参数分别是：调用是否成功、是否可以创建、可创建群的数量、理由
 */
- (void) getCreateCrowdSetting:(void(^)(BOOL, BOOL, NSUInteger, NSString*)) callback;

/**
 *  修改群成员显示名称
 *
 *  @param session_id 群id
 *  @param jid        群成员jid
 *  @param name       群成员显示名称
 */
- (void) setCrowdMemberName:(NSString*) session_id member:(NSString*) jid name:(NSString*) name callback:(void(^)(BOOL)) callback;

/**
 *  修改群公告
 *
 *  @param session_id 群id
 *  @param announce   公告
 */
- (void) setCrowdAnnounce:(NSString*) session_id announce:(NSString*) announce callback:(void(^)(BOOL)) callback;
/**
 *  修改群描述
 *
 *  @param session_id 群id
 *  @param description   描述
 */
- (void) setCrowdDescription:(NSString*) session_id description:(NSString*) description callback:(void(^)(BOOL)) callback;
/**
 *  修改群图标
 *
 *  @param session_id 群id
 *  @param icon   群图标
 */
- (void) setCrowdIcon:(NSString*) session_id icon:(NSString*) icon callback:(void(^)(BOOL)) callback;

/**
 *  修改群验证类型
 *
 *  @param session_id 群id
 *  @param auth 0-验证，1-不验证直接加入，2-不允许加入
 */
- (void) setCrowdAnthType:(NSString*) session_id auth:(NSUInteger) auth_type callback:(void(^)(BOOL)) callback;
/**
 *  修改群名称
 *
 *  @param session_id 群id
 *  @param name       群名称
 */
- (void) setCrowdName:(NSString*) session_id name:(NSString*) name callback:(void(^)(BOOL)) callback;
/**
 *  修改群类型
 *
 *  @param session_id 群id
 *  @param category   群类型
 */
- (void) setCrowdCatagory:(NSString*) session_id category:(NSUInteger) category callback:(void(^)(BOOL)) callback;
/**
 *  修改群备注
 *
 *  @param session_id 群id
 *  @param remark     群备注
 */
- (void) setCrowdRemark:(NSString*) session_id remark:(NSString*) remark callback:(void(^)(BOOL)) callback;


- (void) leaveCrowd:(NSString*) session_id callback:(void(^)(BOOL)) callback;
/**
 *  接收群信息
 *
 *  @param session 群id
 */
- (void) setCrowdAlert_Recv:(NSString*) session callback:(void(^)(BOOL)) callback;
/**
 *  接收群信息但不提示
 *
 *  @param session 群id
 */
- (void) setCrowdAlert_Recv_NO_Tint:(NSString*) session callback:(void(^)(BOOL)) callback;
/**
 *  屏蔽群信息
 *
 *  @param session 群id
 */
- (void) setCrowdAlert_Reject:(NSString*) session callback:(void(^)(BOOL)) callback;

/**
 *  查找群
 *
 *  @param type      查找类型
 *  @param searchStr 关键字
 *  @param index     起始位置
 *  @param max       数量
 *  @param listener
 */
- (void) findCrowd:(NSString *)type text:(NSString *) text index:(int)index count:(int) count callback:(void(^)(NSArray*)) callback;
/**
 *  得到群的用户协议地址
 *
 *  @return 
 */
- (void) getCrowdPolicy:(void(^)(NSString* content)) callback;

/**
 *群投票
 */
//给选择的项投票
- (void) startVote:(NSString *)jid voteId:(int)vid iids:(NSString *)iids name:(NSString *)name callback:(void(^)(CrowdVoteInfo *))callback;
//群投票列表
- (void) voteList:(NSString *)gid callback:(void(^)(NSArray *))callback;
//群投票详细信息
- (void)voteDetail:(NSString *)gid voteId:(int)vid jid:(NSString *)jid callback:(void(^)(CrowdVoteInfo *))callback;
//删除投票
- (void)deleteVote:(NSString *)gid vid:(int)vid jid:(NSString *)jid;
#pragma mark - 群投票详细信息
//- (void)voteDetail:(NSString *)gid voteId:(int)vid jid:(NSString *)jid callback:(void(^)(CrowdVoteInfo *))callback;

@end
