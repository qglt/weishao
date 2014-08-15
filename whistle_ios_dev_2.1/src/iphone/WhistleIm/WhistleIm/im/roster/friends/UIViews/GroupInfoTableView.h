//
//  GroupInfoTableView.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupInfoTableViewDelegate <NSObject>

- (void)leaveGroup;
- (void)changeGroupName;
- (void)addGroupMember;
- (void)showGroupRecord;

@end

@interface GroupInfoTableView : UIView
{
    __weak id <GroupInfoTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <GroupInfoTableViewDelegate> m_delegate;
- (void)refreshTableViewWithTitleArr:(NSMutableArray *)titleArr andImageArr:(NSMutableArray *)imageArr;

@end
