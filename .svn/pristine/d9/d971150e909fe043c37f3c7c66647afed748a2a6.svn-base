//
//  BizlayerProxy.h
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BizBridge.h"
//#import "ConversationInfo.h"
//#import "RecentRecord.h"



@class BizBridge;

@interface BizlayerProxy : NSObject

@property (strong, nonatomic) BizBridge *whistleBizBridge;
@property (strong, nonatomic) NSMutableDictionary *pushMap;

SINGLETON_DEFINE(BizlayerProxy)

-(void)reset;

-(void)login:(NSString*)userName password:(NSString*)pss rememberPW:(BOOL)savePss autoLogin:(BOOL)autoLog status:(NSString*) status callback:(WhistleCommandCallbackType)listener;

-(void)getLoginHistory:(WhistleCommandCallbackType)listener;

-(void)changeUser:(WhistleCommandCallbackType)listener;

-(void)getRoster:(WhistleCommandCallbackType)listener;


-(void)getLocalRecentList:(WhistleCommandCallbackType)listener;

-(void)getUserDetailInfo:(NSString *)jid callback:(WhistleCommandCallbackType)listener; //获得用户详情

-(void)getUnreadNotices:(WhistleCommandCallbackType)listener;
-(void) closeApp:(WhistleCommandCallbackType)listener;
-(void) goOffline :(WhistleCommandCallbackType)listener;

-(void) sendMessage:(NSString *)jid withMsg:(NSString *)msg withListener:(WhistleCommandCallbackType)listener;
-(void) sendVoiceMessage:(NSString *)jid withID:(NSString *)src_id withSRC:(NSString *)src duration:(int) duration withListener:(WhistleCommandCallbackType)listener;
-(void) sendHelloMessage:(NSString *)jid withID:(NSString *)uuid withListener:(WhistleCommandCallbackType)listener;
-(void) sendVideoMessage:(NSString *)jid withID:(NSString *)src_id withSRC:(NSString *)src duration:(int) duration withListener:(WhistleCommandCallbackType)listener;
-(void) sendImageMessage:(NSString *)jid withID:(NSString *)id withSRC:(NSString *)src withListener:(WhistleCommandCallbackType)listener;
-(void) getConversationUnreadCount:(WhistleCommandCallbackType)listener;
-(void) getLightappUnreadMsg:(NSString*) appid callback:(WhistleCommandCallbackType) callback;
//-(void) getLightappUnreadCount:(NSString*) appid callback:(WhistleCommandCallbackType) callback;
-(void) getConversationUnreadMessage:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) deleteAccountFromHistory:(NSString *)userName withDeleteLocalFile:(Boolean)deleteLocalFile withListener:(WhistleCommandCallbackType)listener;
-(void) getConversationHistoryWithTargetDetail:(NSString *)jid withConvType:(NSString *)convType withBeginIndex:(int)beginIndex withCount:(int)count withListener:(WhistleCommandCallbackType)listener;
-(void) getLightappMsgHistory:(NSString*) appid index:(NSInteger) index count:(NSInteger) count callback:(WhistleCommandCallbackType) callback;
- (void) deleteLightappMessage:(NSString*) appid rowid:(NSString*) rowid callback:(WhistleCommandCallbackType) callback;
- (void) deleteLightappMessage:(NSString*) appid callback:(WhistleCommandCallbackType) callback;
-(void) getLightappMessageNotifyServer:(WhistleCommandCallbackType) callback;
-(void) getNoticeList:(int)beginIndex withCount:(int)count withListener:(WhistleCommandCallbackType)listener;
-(void) findContact:(NSString *)searchStr withListener:(WhistleCommandCallbackType)listener;
-(void) findFriendOnLine:(NSString *)type withSearchStr:(NSString *)searchStr wihtIndex:(int)index withMax:(int)max withListener:(WhistleCommandCallbackType)listener;
-(void) setBuddyRemark:(NSString *)jid withRemark:(NSString *)remark withListener:(WhistleCommandCallbackType)listener;
-(void) removeBuddy:(NSString *)jid withRemoveMeFromHisList:(Boolean)removeMeFromHisList withListener:(WhistleCommandCallbackType)listener;
-(void) addFriend:(NSString *)jid withName:(NSString *)name withMsg:(NSString *)msg withGroupName:(NSString *)group_name withListener:(WhistleCommandCallbackType)listener;
-(void) ackAddFriend:(NSString *)jid withAck:(Boolean)ack withListener:(WhistleCommandCallbackType)listener;
-(void) deleteConversationHistory:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) deleteNoticeHistory:(NSString *)noticeId withListener:(WhistleCommandCallbackType)listener;
- (void) deleteReadedNotices:(WhistleCommandCallbackType) callback;
- (void) deleteAllNotices:(WhistleCommandCallbackType) callback;
-(void) setStatus:(NSString *)status withListener:(WhistleCommandCallbackType)listener;

-(void) storeLocal:(NSString *)key withValue:(NSString *)value withListener:(WhistleCommandCallbackType)listener;
-(void) getLocal:(NSString *)key withListener:(WhistleCommandCallbackType)listener;
-(void) getRelationship:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) getUnreadNotices:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) markMessageRead:(NSString *)jid withType:(NSString *)type withListener:(WhistleCommandCallbackType)listener;
- (void) replaceMsgByRowid:(NSString*) msg rowid:(NSString*) rowid withType:(NSString *)type callback:(WhistleCommandCallbackType) callback;
-(void) updateImage:(NSString *)imgPath withimgWidth:(int)imgWidth  withimgHeight:(int)imgHeight withcropTop:(int)cropTop withcropLeft:(int)cropLeft withcropBotton:(int)cropBotton withcropRight:(int)cropRight withListener:(WhistleCommandCallbackType)listener;
-(void) getImage:(NSString *)imgid withName:(NSString *)name withListener:(WhistleCommandCallbackType)listener;
-(void) getVoice:(NSString *)voiceid withName:(NSString *)name withListener:(WhistleCommandCallbackType)listener;
-(void) removeRecentContact:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) removeRecentSystemContact:(WhistleCommandCallbackType)listener;
-(void) getNoticeDetailInfoAndMarkReaded:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;

-(void) setSystemMessageReaded:(NSString *)rowId withidList:(NSArray *)idList withListener:(WhistleCommandCallbackType)listener;
//-(void) deleteSystemMessage:(NSString *)rowId withidList:(NSArray *)idList withListener:(WhistleCommandCallbackType)listener;
-(void) deleteSystemMessage:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener;
-(void) getChatGroupSettings:(WhistleCommandCallbackType)listener;
-(void) getSystemMessage:(NSString *)rowId withbeginidx:(int)beginidx  withcount:(int)count withListener:(WhistleCommandCallbackType)listener;
-(void) deleteOneHistoryMessage:(NSString *)type withrowId:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener;
-(void) deleteAllHistoryMessage:(NSString *)type withjid:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;
-(void) getChangePasswordUri:(WhistleCommandCallbackType)listener;
-(void) canUserChangedPassword:(WhistleCommandCallbackType)listener;
-(void) getRecentAppMsg:(WhistleCommandCallbackType)listener;
-(void) getAppMsgList:(NSInteger)index count:(NSInteger) count callback:(WhistleCommandCallbackType)listener;
-(void) getAppMsgHistory:(NSString *)sid from:(int)beginIdx withCount:(int)count withListener:(WhistleCommandCallbackType)listener;
-(void) markAppMsgRead:(NSString *)sid withListener:(WhistleCommandCallbackType)listener;
-(void) deleteAppMessage:(NSString *)sid withListener:(WhistleCommandCallbackType)listener;
-(void) deleteAllAppMsg:(WhistleCommandCallbackType) callback;
-(void) deleteAllReadAppMsg:(WhistleCommandCallbackType) callback;
-(void) getFeedbackURL: (WhistleNotificationListenerType) listner;
-(void) getWhistleVersion: (WhistleNotificationListenerType) listner;
//-(void) sendUpdateRecentContactNotify:(NSString *)jid from:(ConversationType) conversationType to:(RecentContactUpdateType) recentContactUpdateType;
//系统消息设置已读
-(void) markSystemMessageRead:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener;


- (void) callback2biz:(NSString* ) callback_id withDomain:(NSString*) domain;

-(void) setLightAppReaded:(NSString *)jid withListener:(WhistleCommandCallbackType)listener;

- (void) searchCloudConfig:(NSString*) text withListener:(WhistleCommandCallbackType) listener;
- (void) getToken:(NSString*) service_id forceNew:(BOOL) force callback:(WhistleCommandCallbackType) callback;

#pragma mark -- 其他函数

/**
 *  上传图片
 *
 *  @param path     图片路径
 *  @param width    图片宽度
 *  @param height   图片高度
 *  @param left     截取面积左
 *  @param right    截取面积右
 *  @param top      截取面积上
 *  @param bottom   截取面积下
 *  @param callback 返回文件uri等
 */
- (void) doUploadImage:(NSString*) path width:(NSUInteger) width height:(NSUInteger) height crop_left:(NSUInteger) left crop_right:(NSUInteger) right crop_top:(NSUInteger) top crop_bottom:(NSUInteger) bottom callback:(WhistleCommandCallbackType) callback;

#pragma mark -- 群相关

/**
 *  是否可以创建群
 *
 *  @param callback
 */
- (void) getCreateCrowdSetting:(WhistleCommandCallbackType) callback;
/**
 *  取群列表
 *
 *  @param listener
 */
- (void) getCrowdList:(WhistleCommandCallbackType)listener;
/**
 *  创建群
 *
 *  @param name     群名
 *  @param icon     群头像
 *  @param category 群分类
 *  @param authType 群验证类型 0-验证，1-不验证直接加入，2-不允许加入
 *  @param callback
 */
- (void) createCrowd:(NSString*) name icon:(NSString *)icon category:(NSInteger)category auth:(NSInteger) authType callback:(void (^)(NSDictionary *))callback;
/**
 *  解散群
 *
 *  @param sessionID 群id
 *  @param callback
 */
- (void) dismissCrowd:(NSString*) sessionID callback:(WhistleCommandCallbackType) callback;
/**
 *  邀请好友进入群
 *
 *  @param sessionID 群id
 *  @param jid       好友jid
 *  @param callback
 */
- (void) inviteIntoCrowd:(NSString*) sessionID friend:(NSString*) jid callback:(WhistleCommandCallbackType) callback;
/**
 *  被邀请者应答管理员加入群的邀请
 *
 *  @param isAccpet     是否接收
 *  @param rowid        rowid
 *  @param session_id   群id
 *  @param crowd_name   群名称
 *  @param icon         群图标
 *  @param category     群类型
 *  @param jid          邀请者id，为actor_jid
 *  @param name         邀请者名称,为actor_name
 *  @param reason       理由
 *  @param isNeverAccpt 是否一直接收
 *  @param listener
 */
- (void) answerCrowdInvite:(BOOL)isAccpet
                 WithRowID:(NSString *)rowid
             WithSessionID:(NSString *)session_id
             WithCrowdName:(NSString*) crowd_name
                  WithIcon:(NSString*) icon
              WithCategory:(NSUInteger) category
                   WithJID:(NSString *)jid
                  WithName:(NSString*) name
                WithReason:(NSString*) reason
           WithNeverAccpte:(BOOL) isNeverAccpt
              withListener:(WhistleCommandCallbackType)listener;
/**
 *  申请加入群
 *
 *  @param sessionID 群id
 *  @param reason    申请理由
 *  @param callback
 */
- (void) applyJoinCrowd:(NSString*) sessionID reason:(NSString*) reason callback:(WhistleCommandCallbackType) callback;
/**
 *  管理员审批加入群申请
 *
 *  @param isAccpet       是否同意
 *  @param session_id     群id
 *  @param actor_name     申请人名称
 *  @param actor_jid      申请人id
 *  @param actor_icon     申请人图标
 *  @param actor_sex      申请人性别
 *  @param actor_identity 申请人标识
 *  @param reason         管理员拒绝时，填写拒绝理由；管理员同意时填写申请人的申请理由
 *  @param listener
 */
- (void) answerApplyJonCrowd:(BOOL)isAccpet WithSessionID:(NSString *)session_id actorName:(NSString*) actor_name actorJID:(NSString*) actor_jid actorIcon:(NSString*) actor_icon actorSex:(NSString*) actor_sex
               actorIdentity:(NSString*) actor_identity reason:(NSString*) reason WithListener:(WhistleCommandCallbackType)listener;
/**
 *  申请成为超级管理员
 *
 *  @param sessionID 群id
 *  @param reason    理由
 *  @param callback
 */
- (void) crowdApplySuperadmin:(NSString*) sessionID reason:(NSString*) reason callback:(WhistleCommandCallbackType) callback;
/**
 *  管理员踢成员
 *
 *  @param session_id 群id
 *  @param kickJid    被踢人的jid
 *  @param reason     踢人理由
 *  @param listener
 */
- (void) crowdMemberKickout:(NSString *)session_id withJID:(NSString *)kickJid wihtReson:(NSString *)reason withListener:(WhistleCommandCallbackType)listener;
/**
 *  转让群
 *
 *  @param sessionID 群id
 *  @param jid       接收人的jid
 *  @param callback
 */
- (void) crowdRoleDemise:(NSString*) sessionID friend:(NSString*) jid callback:(WhistleCommandCallbackType) callback;
/**
 *  超级管理员改变其他成员角色
 *
 *  @param sessionID 群id
 *  @param jid       成员jid
 *  @param role      群角色 admin/none
 *  @param callback
 */
- (void) crowdRoleChange:(NSString*) sessionID  friend:(NSString*) jid role:(NSString*) role callback:(WhistleCommandCallbackType) callback;
/**
 *  获取群成员列表
 *
 *  @param sessionId 群id
 *  @param listener
 */
- (void) getCrowdMemberList:(NSString *)sessionId withListener:(WhistleCommandCallbackType)listener;
/**
 *  修改群成员资料
 *
 *  @param sessionID 群id
 *  @param jid       成员jid
 *  @param name      成员名称
 *  @param remark    成员备注
 *  @param callback
 */
- (void) setCrowdMemberInfo:(NSString*) sessionID friend:(NSString*) jid name:(NSString*) name remark:(NSString*) remark callback:(WhistleCommandCallbackType) callback;
/**
 *  取群资料
 *
 *  @param session_id 群id
 *  @param listener
 */
- (void) getCrowdInfo:(NSString *)session_id withListener:(WhistleCommandCallbackType)listener;
/**
 *  修改群资料
 *
 *  @param sessionID   群id
 *  @param announce    公告
 *  @param description 描述
 *  @param icon        群图标
 *  @param anth_type   群验证类型
 *  @param name        群名称
 *  @param category    群分类
 *  @param callback
 */
- (void) setCrowdInfo:(NSString*) sessionID announce:(NSString*) announce description:(NSString*) description icon:(NSString*) icon authType:(int) anth_type name:(NSString*) name category:(int) category callback:(WhistleCommandCallbackType) callback;
//同上
- (void) setCrowdInfo:(NSString *)session_id wihtParams:(NSMutableDictionary *)param withListener:(WhistleCommandCallbackType)listener;
/**
 *  退出群
 *
 *  @param session_id 群id
 *  @param listener
 */
- (void) leaveCrowd:(NSString *)session_id withListener:(WhistleCommandCallbackType)listener;
/**
 *  打开群会话窗口，打开窗口后会实时接收到群成员变更信息
 *
 *  @param sessionID 群id
 *  @param callback
 */
- (void) openCrowdWindow:(NSString*) sessionID callback:(WhistleCommandCallbackType) callback;
/**
 *  关闭群会话窗口
 *
 *  @param sessionID 群id
 *  @param callback
 */
- (void) closeCrowdWindow:(NSString*) sessionID callback:(WhistleCommandCallbackType) callback;
/**
 *  设置群屏蔽消息设置
 *
 *  @param sessionID 群id
 *  @param alert     屏蔽类型 0-接收；1-接收不提示；2-屏蔽
 *  @param callback
 */
- (void) setCrowdAlert:(NSString*) sessionID alert:(int) alert callback:(WhistleCommandCallbackType) callback;
/**
 *  查找群
 *
 *  @param type      查找类型
 *  @param searchStr 关键字
 *  @param index     起始位置
 *  @param max       数量
 *  @param listener
 */
- (void) findCrowd:(NSString *)type withSearchStr:(NSString *)searchStr wihtIndex:(int)index withMax:(int)max withListener:(WhistleCommandCallbackType)listener;
/**
 *  得到群协议的url
 *
 *  @return url
 */
- (NSString*) getCrowdPolicy;

#pragma mark -- 讨论组相关
/**
 *  创建讨论组
 *
 *  @param groupName 讨论组名
 *  @param idList    讨论组成员id
 *  @param listener
 */
- (void) createChatGroup:(NSString *)groupName withidList:(NSArray *)idList callback:(WhistleCommandCallbackType) callback;
/**
 *  得到讨论组成员列表
 *
 *  @param sessionId 讨论组id
 *  @param listener
 */
- (void) getChatGroupMemberList:(NSString *) sessionId callback:(WhistleCommandCallbackType) callback;
/**
 *  讨论组增加成员
 *
 *  @param session_id 讨论组id
 *  @param buddies    增加成员jid的集合
 *  @param callback
 */
- (void) inviteBuddyIntoChatGroup:(NSString*) session_id buddies:(NSArray*) buddies callback:(WhistleCommandCallbackType) callback;
/**
 *  得到讨论组集合
 *
 *  @param callback
 */
- (void) getChatGroupList:(WhistleCommandCallbackType) callback;
/**
 *  离开讨论组
 *
 *  @param sessionId 讨论组id
 *  @param listener
 */
- (void) leaveChatGroup:(NSString *)sessionId callback:(WhistleCommandCallbackType) callback;
/**
 *  打开讨论组会话窗口
 *
 *  @param sessionId 讨论组id
 *  @param callback
 */
- (void) openChatGroupWindow:(NSString *)sessionId callback:(WhistleCommandCallbackType) callback;
/**
 *  关闭讨论组会话窗口
 *
 *  @param sessionId 讨论组id
 *  @param callback
 */
- (void) closeChatGroupWindow:(NSString *)sessionId callback:(WhistleCommandCallbackType) callback;

/**
 *  修改讨论组的名字
 *
 *  @param sessionId 讨论组id
 *  @param chatName  讨论组名字
 *  @param chatId    讨论组号，id的前缀数字
 *  @param uid       自己的uid, jid的前缀数字
 *  @param uName     自己的名字
 *  @param listener  
 */
-(void) changeChatGroupName:(NSString *)sessionId withchatName:(NSString *)chatName withchatId:(NSString *)chatId withuid:(NSString *)uid withuName:(NSString *)uName withListener:(WhistleCommandCallbackType)listener;


#pragma mark -- 轻应用相关
/**
 *  发送轻应用的声音消息
 *
 *  @param appid    应用id
 *  @param filepath 声音的绝对路径
 *  @param callback
 */
- (void) sendLightAppMessage:(NSString *)appid voice:(NSString *)filepath length:(NSUInteger) length callback:(WhistleCommandCallbackType)callback;
/**
 *  发送轻应用的文本消息
 *
 *  @param appid    应用id
 *  @param content  文本内容
 *  @param callback
 */
-(void) sendLightAppMessage:(NSString*) appid text:(NSString*) content callback:(WhistleCommandCallbackType)callback;
/**
 *  发送轻应用的图片消息
 *
 *  @param appid    应用id
 *  @param filepath 图片绝对路径
 *  @param callback
 */
-(void) sendLightAppMessage:(NSString*) appid image:(NSString*) filepath callback:(WhistleCommandCallbackType)callback;
/**
 *  发送轻应用的位置消息
 *
 *  @param appid    应用id
 *  @param x        x坐标
 *  @param y        y坐标
 *  @param scale    比例
 *  @param label    标签
 *  @param callback
 */
-(void) sendLightAppMessage:(NSString*) appid x:(double) x y:(double) y scale:(double) scale label:(NSString*) label callback:(WhistleCommandCallbackType)callback;
/**
 *  发送轻应用的链接消息
 *
 *  @param appid       应用id
 *  @param title
 *  @param description
 *  @param url
 *  @param callback
 */
-(void) sendLightAppMessage:(NSString*) appid linkTitle:(NSString*) title description:(NSString*) description url:(NSString*) url callback:(WhistleCommandCallbackType)callback;
/**
 *  发送轻应用的事件消息
 *
 *  @param appid    应用id
 *  @param event    事件
 *  @param eventKey 事件类型
 *  @param callback 
 */
-(void) sendLightAppMessage:(NSString*) appid event:(NSString*) event eventKey:(NSString*) eventKey callback:(WhistleCommandCallbackType)callback;


-(void) storeMyInfo:(NSMutableDictionary *)param withListener:(WhistleCommandCallbackType)listener;


#pragma mark -- 配置信息相关

- (NSString*) getCrowdVoteURL;
- (NSString*) getHttpRoot;
- (NSString*) getDomain;

- (NSString*) getGrowthInfoUrl;
- (NSString*) getExportUrl;

@end
