//
//  GrowdVoteTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "GrowdVoteTableViewCell.h"
#import "VoteCellInfo.h"
#import "VotePercentageInfo.h"
#import "CustomProgressView.h"
#import "ImUtils.h"

@interface GrowdVoteTableViewCell ()
{
    UILabel * m_contentLabel;
    UIImageView * m_indicatorImageView;
    UIView * m_footerLineView;
    UIView * m_headerLineView;
    CustomProgressView * m_percentageProgressView;
    UILabel * m_percentageLabel;
}

@property (nonatomic, strong) UILabel * m_contentLabel;
@property (nonatomic, strong) UIImageView * m_indicatorImageView;
@property (nonatomic, strong) UIView * m_footerLineView;
@property (nonatomic, strong) UIView * m_headerLineView;
@property (nonatomic, strong) CustomProgressView * m_percentageProgressView;
@property (nonatomic, strong) UILabel * m_percentageLabel;

@end

@implementation GrowdVoteTableViewCell

@synthesize m_contentLabel;
@synthesize m_indicatorImageView;
@synthesize m_footerLineView;
@synthesize m_headerLineView;
@synthesize m_percentageProgressView;
@synthesize m_percentageLabel;

@synthesize m_isShowVoteRatio;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self createContentLabel];
        [self createIndicatorImageView];
        [self createFooterLine];
        [self createHeaderLine];
        [self createProgressView];
        [self createVotePercentageLabel];
    }
    return self;
}

- (void)createContentLabel
{
    self.m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 220, 45)];
    self.m_contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.m_contentLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_contentLabel.backgroundColor = [UIColor clearColor];
    self.m_contentLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_contentLabel];
}

- (void)createIndicatorImageView
{
    self.m_indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320 - 30 ,15, 15, 15)];
    self.m_indicatorImageView.userInteractionEnabled = YES;
    [self addSubview:self.m_indicatorImageView];
}

- (void)createFooterLine
{
    self.m_footerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    self.m_footerLineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self addSubview:self.m_footerLineView];
}

- (void)createHeaderLine
{
    self.m_headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    self.m_headerLineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.m_headerLineView.hidden = YES;
    [self addSubview:self.m_headerLineView];
}

- (void)setCellDataWithInfo:(id)cellData
{
    if (self.m_isShowVoteRatio) {
        [self showVoteResultWith:cellData];
    } else {
        [self showVoteItemsWith:cellData];
    }
}

- (void)showVoteItemsWith:(VoteCellInfo *)cellInfo
{
    self.m_contentLabel.text = cellInfo.m_content;
    
    if (cellInfo.m_hasHeaderLine) {
        self.m_headerLineView.hidden = NO;
    } else {
        self.m_headerLineView.hidden = YES;
    }
    
    NSString * imagePath = nil;
    if (cellInfo.m_isSingle) {
        if (cellInfo.m_isSelectedState) {
            imagePath = @"singleSelected.png";
        } else {
            imagePath = @"singleUnselected.png";
        }
    } else {
        if (cellInfo.m_isSelectedState) {
            imagePath = @"moreSelected.png";
        } else {
            imagePath = @"moreUnselected.png";
        }
    }
    self.m_indicatorImageView.image = [UIImage imageNamed:imagePath];
}

- (void)showVoteResultWith:(VotePercentageInfo *)percentageInfo
{
    self.m_contentLabel.text = percentageInfo.m_itemName;
    CGRect contentFrame = self.m_contentLabel.frame;
    contentFrame.size.height = 33;
    self.m_contentLabel.frame = contentFrame;
    
    self.m_percentageProgressView.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    self.m_percentageProgressView.progress = percentageInfo.m_progress;
    [UIView commitAnimations];
    
    self.m_percentageLabel.hidden = NO;
    self.m_percentageLabel.text = percentageInfo.m_percentageStr;
    CGSize percentageSize = [percentageInfo.m_percentageStr sizeWithFont:self.m_percentageLabel.font constrainedToSize:CGSizeMake(170, 10000)  lineBreakMode:NSLineBreakByWordWrapping];
    CGRect percentageFrame = self.m_percentageLabel.frame;
    percentageFrame.origin.x = 320 - 15 - percentageSize.width;
    percentageFrame.size.width = percentageSize.width;
    percentageFrame.size.height = percentageSize.height;
    self.m_percentageLabel.frame = percentageFrame;
    
    if (percentageInfo.m_isMySelected) {
        NSString * imagePath = @"moreSelected.png";
        self.m_indicatorImageView.image = [UIImage imageNamed:imagePath];
        CGRect frame= self.m_indicatorImageView.frame;
        frame.origin.y = 10.0f;
        self.m_indicatorImageView.frame = frame;
    } else {
        self.m_indicatorImageView.hidden = YES;
    }
}

- (void)showHeaderLine:(BOOL)show
{
    self.m_headerLineView.hidden = !show;
}

- (void)createProgressView
{
    self.m_percentageProgressView = [[CustomProgressView alloc] initWithFrame:CGRectMake(15, 33, 220, 2)];
    self.m_percentageProgressView.hidden = YES;
    self.m_percentageProgressView.progress = 0.0f;
    [self addSubview:self.m_percentageProgressView];
}

- (void)createVotePercentageLabel
{
    self.m_percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 0, 0)];
    self.m_percentageLabel.backgroundColor = [UIColor clearColor];
    self.m_percentageLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    self.m_percentageLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_percentageLabel.hidden = YES;
    [self addSubview:self.m_percentageLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
