//
//  PersonalTableViewCell.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersonalSettingData;

@protocol PersonalTableViewCellDelegate <NSObject>

- (void)switchClicked:(id)sender;

@end

@interface PersonalTableViewCell : UITableViewCell
{
    __weak id <PersonalTableViewCellDelegate> m_delegate;
    BOOL m_isCrowdDetailInfo;
}

@property (nonatomic, weak) __weak id <PersonalTableViewCellDelegate> m_delegate;
@property (nonatomic, assign) BOOL m_isCrowdDetailInfo;
//- (void)setCellTitle:(NSString *)title andContent:(NSString *)content withCellHeight:(CGFloat)height hasHeaderLine:(BOOL)hasHeaderLine hasSwitch:(BOOL)hasSwitch andSwithState:(BOOL)isOn;

- (void)setCellWithSettingData:(PersonalSettingData *)settingData;

@end
