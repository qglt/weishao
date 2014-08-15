//
//  NoticeTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticeTableViewCell.h"
#import "ChatRecordForNotice.h"
#import "NoticeInfo.h"
#import "RecentAppMessageInfo.h"
#import "ImageUtil.h"
#import "MessageManager.h"

#define IMPORTANT @"important"
#define NORMAL @"normal"

#define kUtilityButtonsWidthMax 260
#define kUtilityButtonWidthDefault 50

static NSString * const kTableViewCellContentView = @"UITableViewCellContentView";


#pragma mark - SWUtilityButtonView

@interface SWUtilityButtonView : UIView

@property (nonatomic, strong) NSArray *utilityButtons;
@property (nonatomic) CGFloat utilityButtonWidth;
@property (nonatomic, weak) NoticeTableViewCell *parentCell;
@property (nonatomic) SEL utilityButtonSelector;

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(NoticeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector;

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(NoticeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector;

@end
@implementation SWUtilityButtonView

#pragma mark - SWUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(NoticeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    self = [super init];
    
    if (self) {
        self.utilityButtons = utilityButtons;
        self.utilityButtonWidth = [self calculateUtilityButtonWidth];
        self.parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(NoticeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.utilityButtons = utilityButtons;
        self.utilityButtonWidth = [self calculateUtilityButtonWidth];
        self.parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
    }
    
    return self;
}

#pragma mark Populating utility buttons

- (CGFloat)calculateUtilityButtonWidth {
    CGFloat buttonWidth = kUtilityButtonWidthDefault;
    if (buttonWidth * _utilityButtons.count > kUtilityButtonsWidthMax) {
        CGFloat buffer = (buttonWidth * _utilityButtons.count) - kUtilityButtonsWidthMax;
        buttonWidth -= (buffer / _utilityButtons.count);
    }
    return buttonWidth;
}

- (CGFloat)utilityButtonsWidth {
    return (_utilityButtons.count * _utilityButtonWidth);
}

- (void)populateUtilityButtons {
    NSUInteger utilityButtonsCounter = 0;
    for (UIButton *utilityButton in _utilityButtons) {
        CGFloat utilityButtonXCord = 0;
        if (utilityButtonsCounter >= 1) utilityButtonXCord = _utilityButtonWidth * utilityButtonsCounter;
        
        [utilityButton setFrame:CGRectMake(utilityButtonXCord, 0, _utilityButtonWidth, CGRectGetHeight(self.bounds))];
        [utilityButton setTag:utilityButtonsCounter];
        [utilityButton addTarget:_parentCell action:_utilityButtonSelector forControlEvents:UIControlEventTouchDown];
        
        [self addSubview: utilityButton];
        utilityButtonsCounter++;
    }
}

@end

@interface NoticeTableViewCell ()<UIScrollViewDelegate>
{
    SWCellState _cellState; // The state of the cell within the scroll view, can be left, right or middle
    
    UIImageView * m_headerImageView;
    UIImageView * m_identityImageView;
    UIImageView * m_newNoticeImageView;
    
    UILabel * m_noticeNameLabel;
    UILabel * m_noticeContentLabel;
    UILabel * m_timeLabel;
    
    ChatRecordForNotice * m_notice;
    RecentAppMessageInfo * m_messageInfo;
    UIView * separateLine;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;
@property (nonatomic, strong) UIImageView * m_newNoticeImageView;

@property (nonatomic, strong) UILabel * m_noticeNameLabel;
@property (nonatomic, strong) UILabel * m_noticeContentLabel;
@property (nonatomic, strong) UILabel * m_timeLabel;
@property (nonatomic, strong) ChatRecordForNotice * m_notice;
@property (nonatomic, strong) RecentAppMessageInfo * m_messageInfo;

// Scroll view to be added to UITableViewCell
@property (nonatomic, weak) UIScrollView *cellScrollView;

// The cell's height
@property (nonatomic) CGFloat height;

// Views that live in the scroll view
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewLeft;
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewRight;

// Used for row height and selection
@property (nonatomic, weak) UITableView *containingTableView;

@end

@implementation NoticeTableViewCell

@synthesize m_headerImageView;
@synthesize m_identityImageView;
@synthesize m_newNoticeImageView;

@synthesize m_noticeNameLabel;
@synthesize m_noticeContentLabel;
@synthesize m_timeLabel;

@synthesize m_isNotice;
@synthesize m_notice;
@synthesize m_messageInfo;

#pragma mark Initializers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.rightUtilityButtons = rightUtilityButtons;
        self.leftUtilityButtons = leftUtilityButtons;
        self.height = containingTableView.rowHeight;
        self.containingTableView = containingTableView;
        self.highlighted = NO;
        [self initializer];
        
        [self createFriendHeaderImageView];
        [self createNoticeNameLabel];
        [self createNoticeContentLabel];
        [self createTimeLabel];
        [self createNewNoticeImageView];
        [self createSeparateLine];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializer];
        
        [self createFriendHeaderImageView];
        [self createNoticeNameLabel];
        [self createNoticeContentLabel];
        [self createTimeLabel];
        [self createNewNoticeImageView];
        [self createSeparateLine];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializer];
        
        [self createFriendHeaderImageView];
        [self createNoticeNameLabel];
        [self createNoticeContentLabel];
        [self createTimeLabel];
        [self createNewNoticeImageView];
        [self createSeparateLine];
    }
    
    return self;
}
- (void)initializer {
    // Set up scroll view that will host our cell content
    UIScrollView *cellScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height)];
    cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    cellScrollView.contentOffset = [self scrollViewContentOffset];
    cellScrollView.delegate = self;
    cellScrollView.showsHorizontalScrollIndicator = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPressed:)];
    [cellScrollView addGestureRecognizer:tapGestureRecognizer];
    
    self.cellScrollView = cellScrollView;
    
    // Set up the views that will hold the utility buttons
    SWUtilityButtonView *scrollViewButtonViewLeft = [[SWUtilityButtonView alloc] initWithUtilityButtons:_leftUtilityButtons parentCell:self utilityButtonSelector:@selector(leftUtilityButtonHandler:)];
    [scrollViewButtonViewLeft setFrame:CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height)];
    self.scrollViewButtonViewLeft = scrollViewButtonViewLeft;
    [self.cellScrollView addSubview:scrollViewButtonViewLeft];
    
    SWUtilityButtonView *scrollViewButtonViewRight = [[SWUtilityButtonView alloc] initWithUtilityButtons:_rightUtilityButtons parentCell:self utilityButtonSelector:@selector(rightUtilityButtonHandler:)];
    [scrollViewButtonViewRight setFrame:CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height)];
    self.scrollViewButtonViewRight = scrollViewButtonViewRight;
    [self.cellScrollView addSubview:scrollViewButtonViewRight];
    
    // Populate the button views with utility buttons
    [scrollViewButtonViewLeft populateUtilityButtons];
    [scrollViewButtonViewRight populateUtilityButtons];
    
    // Create the content view that will live in our scroll view
    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height)];
    scrollViewContentView.backgroundColor = [UIColor whiteColor];
    [self.cellScrollView addSubview:scrollViewContentView];
    self.scrollViewContentView = scrollViewContentView;
    
    // Add the cell scroll view to the cell
    UIView *contentViewParent = self;
    if (![NSStringFromClass([[self.subviews objectAtIndex:0] class]) isEqualToString:kTableViewCellContentView]) {
        // iOS 7
        contentViewParent = [self.subviews objectAtIndex:0];
    }
    NSArray *cellSubviews = [contentViewParent subviews];
    [self insertSubview:cellScrollView atIndex:0];
    for (UIView *subview in cellSubviews) {
        [self.scrollViewContentView addSubview:subview];
    }
}

#pragma mark Selection

- (void)scrollViewPressed:(id)sender {
    if(_cellState == kCellStateCenter) {
        // Selection hack
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
            NSIndexPath *cellIndexPath = [_containingTableView indexPathForCell:self];
            [self.containingTableView.delegate tableView:_containingTableView didSelectRowAtIndexPath:cellIndexPath];
        }
        // Highlight hack
        if (!self.highlighted) {
            self.scrollViewButtonViewLeft.hidden = YES;
            self.scrollViewButtonViewRight.hidden = YES;
            NSTimer *endHighlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(timerEndCellHighlight:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:endHighlightTimer forMode:NSRunLoopCommonModes];
            [self setHighlighted:YES];
        }
    } else {
        // Scroll back to center
        [self hideUtilityButtonsAnimated:YES];
    }
}

- (void)timerEndCellHighlight:(id)sender {
    if (self.highlighted) {
        self.scrollViewButtonViewLeft.hidden = NO;
        self.scrollViewButtonViewRight.hidden = NO;
        [self setHighlighted:NO];
    }
}

#pragma mark UITableViewCell overrides

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.scrollViewContentView.backgroundColor = backgroundColor;
}

#pragma mark - Utility buttons handling

- (void)rightUtilityButtonHandler:(id)sender {
    UIButton *utilityButton = (UIButton *)sender;
    NSInteger utilityButtonTag = [utilityButton tag];
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:didTriggerRightUtilityButtonWithIndex:)]) {
        [_delegate swippableTableViewCell:self didTriggerRightUtilityButtonWithIndex:utilityButtonTag];
    }
}

- (void)leftUtilityButtonHandler:(id)sender {
    UIButton *utilityButton = (UIButton *)sender;
    NSInteger utilityButtonTag = [utilityButton tag];
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:didTriggerLeftUtilityButtonWithIndex:)]) {
        [_delegate swippableTableViewCell:self didTriggerLeftUtilityButtonWithIndex:utilityButtonTag];
    }
}

- (void)hideUtilityButtonsAnimated:(BOOL)animated {
    // Scroll back to center
    [self.cellScrollView setContentOffset:CGPointMake([self leftUtilityButtonsWidth], 0) animated:animated];
    _cellState = kCellStateCenter;
    
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:scrollingToState:)]) {
        [_delegate swippableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}


#pragma mark - Overriden methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cellScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _height);
    self.cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self utilityButtonsPadding], _height);
    self.cellScrollView.contentOffset = CGPointMake([self leftUtilityButtonsWidth], 0);
    self.scrollViewButtonViewLeft.frame = CGRectMake([self leftUtilityButtonsWidth], 0, [self leftUtilityButtonsWidth], _height);
    self.scrollViewButtonViewRight.frame = CGRectMake(CGRectGetWidth(self.bounds), 0, [self rightUtilityButtonsWidth], _height);
    self.scrollViewContentView.frame = CGRectMake([self leftUtilityButtonsWidth], 0, CGRectGetWidth(self.bounds), _height);
}

#pragma mark - Setup helpers

- (CGFloat)leftUtilityButtonsWidth {
    return [_scrollViewButtonViewLeft utilityButtonsWidth];
}

- (CGFloat)rightUtilityButtonsWidth {
    return [_scrollViewButtonViewRight utilityButtonsWidth];
}

- (CGFloat)utilityButtonsPadding {
    return ([_scrollViewButtonViewLeft utilityButtonsWidth] + [_scrollViewButtonViewRight utilityButtonsWidth]);
}

- (CGPoint)scrollViewContentOffset {
    return CGPointMake([_scrollViewButtonViewLeft utilityButtonsWidth], 0);
}

#pragma mark UIScrollView helpers

- (void)scrollToRight:(inout CGPoint *)targetContentOffset{
    targetContentOffset->x = [self utilityButtonsPadding];
    _cellState = kCellStateRight;
    
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:scrollingToState:)]) {
        [_delegate swippableTableViewCell:self scrollingToState:kCellStateRight];
    }
}

- (void)scrollToCenter:(inout CGPoint *)targetContentOffset {
    targetContentOffset->x = [self leftUtilityButtonsWidth];
    _cellState = kCellStateCenter;
    
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:scrollingToState:)]) {
        [_delegate swippableTableViewCell:self scrollingToState:kCellStateCenter];
    }
}

- (void)scrollToLeft:(inout CGPoint *)targetContentOffset{
    targetContentOffset->x = 0;
    _cellState = kCellStateLeft;
    
    if ([_delegate respondsToSelector:@selector(swippableTableViewCell:scrollingToState:)]) {
        [_delegate swippableTableViewCell:self scrollingToState:kCellStateLeft];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    switch (_cellState) {
        case kCellStateCenter:
            if (velocity.x >= 0.5f) {
                [self scrollToRight:targetContentOffset];
            } else if (velocity.x <= -0.5f) {
                [self scrollToLeft:targetContentOffset];
            } else {
                CGFloat rightThreshold = [self utilityButtonsPadding] - ([self rightUtilityButtonsWidth] / 2);
                CGFloat leftThreshold = [self leftUtilityButtonsWidth] / 2;
                if (targetContentOffset->x > rightThreshold)
                    [self scrollToRight:targetContentOffset];
                else if (targetContentOffset->x < leftThreshold)
                    [self scrollToLeft:targetContentOffset];
                else
                    [self scrollToCenter:targetContentOffset];
            }
            break;
        case kCellStateLeft:
            if (velocity.x >= 0.5f) {
                [self scrollToCenter:targetContentOffset];
            } else if (velocity.x <= -0.5f) {
                // No-op
            } else {
                if (targetContentOffset->x >= ([self utilityButtonsPadding] - [self rightUtilityButtonsWidth] / 2))
                    [self scrollToRight:targetContentOffset];
                else if (targetContentOffset->x > [self leftUtilityButtonsWidth] / 2)
                    [self scrollToCenter:targetContentOffset];
                else
                    [self scrollToLeft:targetContentOffset];
            }
            break;
        case kCellStateRight:
            if (velocity.x >= 0.5f) {
                // No-op
            } else if (velocity.x <= -0.5f) {
                [self scrollToCenter:targetContentOffset];
            } else {
                if (targetContentOffset->x <= [self leftUtilityButtonsWidth] / 2)
                    [self scrollToLeft:targetContentOffset];
                else if (targetContentOffset->x < ([self utilityButtonsPadding] - [self rightUtilityButtonsWidth] / 2))
                    [self scrollToCenter:targetContentOffset];
                else
                    [self scrollToRight:targetContentOffset];
            }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > [self leftUtilityButtonsWidth]) {
        // Expose the right button view
        self.scrollViewButtonViewRight.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - [self rightUtilityButtonsWidth]), 0.0f, [self rightUtilityButtonsWidth], _height);
    } else {
        // Expose the left button view
        self.scrollViewButtonViewLeft.frame = CGRectMake(scrollView.contentOffset.x, 0.0f, [self leftUtilityButtonsWidth], _height);
    }
}

#pragma mark - create subView methods

- (void)createFriendHeaderImageView
{
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.50, 30, 30)];
    self.m_headerImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.m_headerImageView];
}

- (void)createNoticeNameLabel
{
    self.m_noticeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, 205, 14)];////////////////////
    self.m_noticeNameLabel.textAlignment = NSTextAlignmentLeft;
    self.m_noticeNameLabel.font = [UIFont systemFontOfSize:15.0f];
    self.m_noticeNameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.m_noticeNameLabel];
}

- (void)createNoticeContentLabel
{
    self.m_noticeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 205, 11)];
    self.m_noticeContentLabel.textAlignment = NSTextAlignmentLeft;
    self.m_noticeContentLabel.textColor = [UIColor colorWithRed:143.0f/ 255.0f green:143.0f/ 255.0f blue:143.0f/ 255.0f alpha:1.0f];
    self.m_noticeContentLabel.font = [UIFont systemFontOfSize:11.0];
    self.m_noticeContentLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.m_noticeContentLabel];
}

- (void)createTimeLabel
{
    self.m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(278, 0, 40, 22)];
    self.m_timeLabel.textAlignment = NSTextAlignmentLeft;
    self.m_timeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.m_timeLabel.textColor = [UIColor colorWithRed:143.0f/ 255.0f green:143.0f/ 255.0f blue:143.0f/ 255.0f alpha:1.0f];
    self.m_timeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.m_timeLabel];
}

- (void)createNewNoticeImageView
{
    self.m_newNoticeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 27, 10, 10)];
    self.m_newNoticeImageView.image = [UIImage imageNamed:@"unreadRedIndicator.png"];
    [self.contentView addSubview:self.m_newNoticeImageView];
}

- (void)createSeparateLine
{
    separateLine = [[UIView alloc]initWithFrame:CGRectMake(0, 45, 320, 1)];
    separateLine.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    [self addSubview:separateLine];
}

- (void)setCellNoticeData:(ChatRecordForNotice *)notice
{
    self.m_notice = notice;
    self.m_noticeNameLabel.text = notice.noticeInfo.title;

    self.m_noticeContentLabel.text = [notice.noticeInfo.body stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

    self.m_timeLabel.text = [notice.noticeInfo.publishTime substringWithRange:NSMakeRange(11, 5)];
    
    // normalnotice.png  importantnotice.png
    if ([notice.priority isEqualToString:IMPORTANT]) {
        self.m_headerImageView.image = [UIImage imageNamed:@"notice1.png"];
    } else if ([notice.priority isEqualToString:NORMAL]) {
        self.m_headerImageView.image = [UIImage imageNamed:@"notice2.png"];
    }
    self.m_newNoticeImageView.hidden = notice.isRead;
}

- (void)setCellNotificationData:(RecentAppMessageInfo *)notification
{
    self.m_messageInfo = notification;
    self.m_noticeNameLabel.text = notification.serviceInfo.name;
    self.m_noticeContentLabel.text = [notification.message.body stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    self.m_timeLabel.text = [notification.message.sendTime substringWithRange:NSMakeRange(11, 5)];
    self.m_newNoticeImageView.hidden = notification.isRead;
    self.m_headerImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@%@",[[MessageManager shareInstance] getMainFolder],VCARD,notification.serviceInfo.icon]];
}


- (void)changeFrame:(BOOL)isEdit
{
    if (isEdit) {
        if (m_isNotice) {
            if (self.m_notice.isRead) {
                [self changeSubViewsFrame];
            } else {
               [self resetSubViewsFrame];
            }
        } else {
            if (self.m_messageInfo.isRead) {
                [self changeSubViewsFrame];
            } else {
               [self resetSubViewsFrame];
            }
        }
    } else {
        [self resetSubViewsFrame];
    }
}

- (void)changeSubViewsFrame
{
    self.m_noticeNameLabel.frame = CGRectMake(55, 8, 205 - 38, 14);
    self.m_timeLabel.frame = CGRectMake(278 - 38, 0, 40, 22);
    self.m_newNoticeImageView.frame = CGRectMake(300 - 38, 27, 10, 10);
    self.m_noticeContentLabel.frame = CGRectMake(55, 22, 205 + 12, 14);
}

- (void)resetSubViewsFrame
{
    self.m_noticeNameLabel.frame = CGRectMake(55, 8, 205, 14);
    self.m_timeLabel.frame = CGRectMake(278, 0, 40, 23);
    self.m_newNoticeImageView.frame = CGRectMake(300, 27, 10, 10);
    self.m_noticeContentLabel.frame = CGRectMake(55, 22, 205, 14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation NSMutableArray (SWUtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    [self addObject:button];
}

@end