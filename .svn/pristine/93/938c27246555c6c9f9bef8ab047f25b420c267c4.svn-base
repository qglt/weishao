//
//  SystemInfoTableViewCell.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JGScrollableTableViewCell.h"
@class SystemMessageInfo;
@class FriendInfo;
@class JGScrollableTableViewCellAccessoryButton;

@protocol SystemInfoTableViewCellDelegate <NSObject>

- (void)pushToPersonInfo:(FriendInfo *)friendInfo andSystemMsg:(SystemMessageInfo *)messageInfo isStranger:(BOOL)stranger;
- (void)markReadInSystemInfoTableViewCell:(SystemMessageInfo *)messageInfo;

@end

@interface SystemInfoTableViewCell : JGScrollableTableViewCell
{
    __weak id <SystemInfoTableViewCellDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <SystemInfoTableViewCellDelegate> m_delegate;

@property (nonatomic,strong)  JGScrollableTableViewCellAccessoryButton *actionView;

- (void)setCellData:(SystemMessageInfo *)messageInfo;
@end
