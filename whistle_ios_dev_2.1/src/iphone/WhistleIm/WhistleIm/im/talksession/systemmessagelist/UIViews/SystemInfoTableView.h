//
//  SystemInfoTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendInfo;
@class SystemMessageInfo;
@class CrowdInfo;

@protocol SystemInfoTableViewDelegate <NSObject>

- (void)pushPersonInfoToController:(FriendInfo *)friendInfo andSystemMessage:(SystemMessageInfo *)messageInfo isStranger:(BOOL)stranger;

- (void)answerRequest:(SystemMessageInfo *)messageInfo;

- (void)deleteSystemMessage:(SystemMessageInfo *)messageInfo;

- (void) pushCrowdInfoToController:(CrowdInfo* ) crowd andSystemMessage:(SystemMessageInfo *) message;

- (void)pushToAgreeToAddFriendViewController:(SystemMessageInfo *)messageInfo;

- (void)clearEditStateNoneData;

- (void)markReadSystemMessage:(SystemMessageInfo *)messageInfo;

- (void)getMoreSystemItemsWithStartIndex:(NSUInteger)startIndex andCount:(NSUInteger)count;

@end

@interface SystemInfoTableView : UIView
{
//    BOOL m_hasMore;
    NSUInteger m_totalCount;
    __weak id <SystemInfoTableViewDelegate> m_delegate;

}

//@property (nonatomic, assign) BOOL m_hasMore;
@property (nonatomic, assign) NSUInteger m_totalCount;

@property (nonatomic, assign) NSIndexPath *openedIndexPath;

@property (nonatomic, weak) __weak id <SystemInfoTableViewDelegate> m_delegate;


- (void)refreshNoticeTableView:(NSMutableDictionary *)dataDict;
- (void)editTableView:(BOOL)canEdit;
- (void)clearEditState;

@end
