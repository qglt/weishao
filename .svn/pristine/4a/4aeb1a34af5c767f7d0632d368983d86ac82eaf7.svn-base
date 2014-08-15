//
//  AddCrowdTableViewCell.h
//  WhistleIm
//
//  Created by ruijie on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCrowdTableViewCellDelegate <NSObject>

- (void)addButtonPressedInAddCrowdsTableViewCell:(UIButton *)button;
- (void)cellImageButtonPressed:(UIButton *)sender;

@end

@class CrowdInfo;

@interface AddCrowdTableViewCell : UITableViewCell
{
    NSString * m_strSelectedType;
    __weak id <AddCrowdTableViewCellDelegate> m_delegate;
}
@property (nonatomic, strong) NSString * m_strSelectedType;
@property (nonatomic, weak) __weak id <AddCrowdTableViewCellDelegate> m_delegate;

- (void)setCellData:(CrowdInfo *)data;
@end
