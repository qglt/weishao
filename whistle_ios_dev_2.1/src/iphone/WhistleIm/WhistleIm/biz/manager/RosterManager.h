//
//  RosterManager.h
//  Whistle
//
//  Created by wangchao on 13-3-5.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Roster.h"
#import "FriendInfo.h"
#import "BizlayerProxy.h"
#import "Manager.h"

enum FriendRelation{
    RelationError,
    RelationContact,
    RelationNone,
    RelationStranger
};

typedef enum _SearchOptions {
	SearchByName,
    SearchByNickName,
    SearchByWhistleId,
} OnlineSearchOptions;


@protocol RosterDelegate <NSObject>

@optional

/**
 *  好友列表更新通知
 *
 *  @param friendGroupList 好友的group集合
 */
- (void) rosterListChanged:(NSMutableArray*) friendGroupList;

/**
 *  获取好友列表成功后的事件
 */
- (void) getRosterFinish:(NSMutableArray*) friendGroupList;

/**
 *  获取好友列表失败后的事件
 */
- (void) getRosterFailure;
/**
 *  好友信息更新后
 *
 *  @param friend 变化后的好友信息
 */
- (void) updateFriendInfo:(FriendInfo*) friend;

- (void) updateMyInfo:(FriendInfo *) my;

@end


@interface RosterManager : Manager{
}


SINGLETON_DEFINE(RosterManager)


-(void) removeBuddy : (FriendInfo *)rosterItem withCallback:(void(^)(BOOL)) callback;

- (void) setBuddyRemark:(FriendInfo*) friend withRemark:(NSString *)remark withListener:(void(^)(BOOL)) callback;

/**
 *  添加好友，callback成功和失败
 *
 *  @param friend 好友的信息
 *  @param msg    添加的额外信息
 */
- (void) addBuddy:(FriendInfo*) friend withMsg:(NSString*) msg withCallback:(void(^)(BOOL)) callback;

- (void) addBuddyWithJid:(NSString *) jid withMsg:(NSString *)msg withCallback:(void (^)(BOOL))callback;

- (void) ackFriendInvite:(NSString*) jid isAgree:(BOOL)isAgree withCallback:(void (^)(BOOL))callback;

- (void) getMyself;

/**
 *  通过jid得到好友信息
 *
 *  @param jid  好友的jid
 *  @param flag 是否包含非好友的信息
 */
-(void)getFriendInfoByJid:(NSString *)jid checkStrange:(BOOL)flag WithCallback: (void(^)(FriendInfo*)) callback;

/**
 *  获取好友信息，包括陌生人信息
 *
 *  @param jid      好友的jid
 *  @param flag     是否需要陌生人的实时信息
 *  @param callback callback好友信息
 */
- (void) getFriendInfoByJid:(NSString *)jid needRealtime:(BOOL)flag WithCallback:(void (^)(FriendInfo *))callback;

/**
 *  得到和其他人的关系
 *
 *  @param jid 其他人的jid
 */
- (void) getRelationShip: (NSString*) jid WithCallback:(void(^)(enum FriendRelation)) callback;

/**
 *  手动获取roster
 *
 *  @param isForceRefrash YES 为强制刷新
 */
- (void) getRoster:(BOOL) isForceRefrash;

- (NSString *)getShownameByIdentity:(FriendInfo *)rosterInfo;

- (void) getUserDetailInfo:(NSString*) jid withCallback:(void(^)(FriendInfo*)) callback;

- (void) getLocalSearchListWithSearchText:(NSString *)text withCallback:(void(^)(NSArray*)) callback;

- (void) storeMyNickName: (NSString*) nick withCallback:(void(^)(BOOL)) callback;

- (void) storeMyMoodWord: (NSString*) mood withCallback:(void(^)(BOOL)) callback;

- (void) storeMyPic: (NSString*) imagePath withCallback:(void(^)(BOOL)) callback;

- (void) searchFriendsOnline:(OnlineSearchOptions) type searchText: (NSString*) text withIndex:(int) index withMax:(int) max withCallback:(void(^)(NSArray*)) callback;

- (FriendInfo*) mySelf;

@end
