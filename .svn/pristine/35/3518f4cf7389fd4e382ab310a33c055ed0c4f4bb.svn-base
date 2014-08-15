//
//  SettingTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingTableViewDelegate <NSObject>

- (void)AboutButtonPressed:(UIButton *)button;
- (void)feedBackButtonPressed:(UIButton *)button;
- (void)changeAccountButtonPressed:(UIButton *)button;
- (void)removeAppList;

- (void)switchClicked:(id)sender;

@end

@interface SettingTableView : UIView
{
    __weak id <SettingTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <SettingTableViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame withDataArr:(NSMutableArray *)dataArr;

@end
