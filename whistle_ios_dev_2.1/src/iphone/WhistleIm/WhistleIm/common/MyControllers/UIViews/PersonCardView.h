//
//  PersonCardView.h
//  WhistleIm
//
//  Created by 管理员 on 13-12-9.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PersonCardViewDelegate <NSObject>

@optional
- (void)showDetailInfo;
- (void)changeRemark;
- (void)showTalkRecord;
- (void)deleteFriend;
- (void)callUp;
- (void)sendMessage;
- (void)talkingWithFriend;
- (void)addFriend;

- (void)showPhoneList;

@end

@class FriendInfo;
@interface PersonCardView : UIView
{
    BOOL m_isStranger;
    FriendInfo * m_friendInfo;
    __weak id <PersonCardViewDelegate> m_delegate;
}

@property (nonatomic, strong) FriendInfo * m_friendInfo;
@property (nonatomic, assign) BOOL m_isStranger;


@property (nonatomic, weak) __weak id <PersonCardViewDelegate> m_delegate;

- (void)createSubViewsWithFriendInfo:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData;
//- (void)resetSubViewsWithFriendInfo:(FriendInfo *)friendInfo;
- (void)refreshViews:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData;

@end
