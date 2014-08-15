//
//  NoticeTableViewCell.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@class ChatRecordForNotice;
@class RecentAppMessageInfo;
@class NoticeTableViewCell;

typedef enum {
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight
} SWCellState;

@protocol NoticeTableViewCellDelegate <NSObject>

@optional
- (void)swippableTableViewCell:(NoticeTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swippableTableViewCell:(NoticeTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swippableTableViewCell:(NoticeTableViewCell *)cell scrollingToState:(SWCellState)state;

@end


@interface NoticeTableViewCell : UITableViewCell
{
    BOOL m_isNotice;
}

@property (nonatomic, assign) BOOL m_isNotice;

@property (nonatomic, strong) NSArray *leftUtilityButtons;
@property (nonatomic, strong) NSArray *rightUtilityButtons;
@property (nonatomic) id <NoticeTableViewCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons;

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;

- (void)setCellNoticeData:(ChatRecordForNotice *)notice;
- (void)setCellNotificationData:(RecentAppMessageInfo *)notification;
- (void)changeFrame:(BOOL)isEdit;

@end

@interface NSMutableArray (SWUtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title;
- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon;

@end




