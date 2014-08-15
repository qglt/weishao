//
//  FriendsAndGroupView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendInfo;
@class GroupCellData;
@class CrowdInfo;

@protocol FriendsAndGroupViewDelegate <NSObject>

@optional

- (void)searchBarTextDidChanged:(NSString *)text;
- (void)didSelectRowAtIndexPath:(FriendInfo*)friendInfo;
- (void)didSelectRowAtIndexPathWithGroupJid:(GroupCellData *)groupCellData;
- (void)didSelectRowAtIndexPathWithCrowdInfo:(CrowdInfo *)crowdInfo;
- (void)cancelButtonPressed;
- (void)cellButtonPressedInFriendsAndGroupView:(NSIndexPath *)indexPath;

- (void)pushToCrowdListViewController;
- (void)pushToGroupListViewController;

- (void)pullDownToReloadData;

- (void)showNoneTextAlert;

@end

@interface FriendsAndGroupView : UIView
{
    __weak id <FriendsAndGroupViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <FriendsAndGroupViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame andIsGroup:(BOOL)isGroup withDataDict:(NSMutableDictionary *)dict;
- (void)closeKeyBoard;
- (void)clearSearchBarText;
- (void)pullDownReloadDataFinished;
- (void)refreshTableView:(NSMutableDictionary *)dictData;
- (void)hiddenDeleteBtn;
@end
