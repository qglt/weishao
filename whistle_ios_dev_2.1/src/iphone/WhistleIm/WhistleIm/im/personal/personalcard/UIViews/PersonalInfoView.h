//
//  PersonalInfoView.h
//  WhistleIm
//
//  Created by 管理员 on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PersonalInfoViewDelegate <NSObject>

@optional
- (void)nickButtonPressed:(UIButton *)button;
- (void)photoButtonPressed:(UIButton *)button;
- (void)moodwordsButtonPressed:(UIButton *)button;
- (void)detailInfoButtonPressed:(UIButton *)button;
- (void)cellDidSelected:(NSIndexPath *)indexPath;
@end

@interface PersonalInfoView : UIView
{
    __weak id <PersonalInfoViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <PersonalInfoViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableDataArr;
- (void)refreshViews:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData;
@end
