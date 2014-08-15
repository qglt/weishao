//
//  AddFriendsTableViewCell.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFriendsTableViewCellDelegate <NSObject>

- (void)addButtonPressedInAddFriendsTableViewCell:(UIButton *)button;
- (void)cellImageButtonPressed:(id)sender;
@end

@class FriendInfo;

@interface AddFriendsTableViewCell : UITableViewCell
{
    NSString * m_strSelectedType;
    __weak id <AddFriendsTableViewCellDelegate> m_delegate;
}
@property (nonatomic, strong) NSString * m_strSelectedType;
@property (nonatomic, weak) __weak id <AddFriendsTableViewCellDelegate> m_delegate;

- (void)setCellData:(FriendInfo *)friendInfo;

@end
