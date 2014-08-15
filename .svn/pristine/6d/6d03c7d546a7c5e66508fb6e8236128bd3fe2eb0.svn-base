//
//  FriendsAndGroupViewCell.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendsAndGroupViewCellDelegate <NSObject>

- (void)cellImageButtonPressed:(UIButton *)button;

@end



@class FriendInfo;

@interface FriendsAndGroupViewCell : UITableViewCell
{
    // 好友VS群和谈论组
    BOOL m_isGroup;
    
    // 群VS谈论组
    BOOL m_isCrowd;
    
    __weak id <FriendsAndGroupViewCellDelegate> m_delegate;
}

@property (nonatomic, assign) BOOL m_isGroup;
@property (nonatomic, assign) BOOL m_isCrowd;
@property (nonatomic, weak) __weak id <FriendsAndGroupViewCellDelegate> m_delegate;


- (void)setCellData:(FriendInfo *)friendInfo;
- (void)setCrowdAndGroupData:(id)data;
@end
