//
//  VoteListTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "VoteListTableViewCell.h"
#import "ImUtils.h"

@interface VoteListTableViewCell ()
{
    UILabel * m_voteNameLabel;
    UIView * m_footerLineView;
    UIView * m_headerLineView;
}

@property (nonatomic, strong) UILabel * m_voteNameLabel;
@property (nonatomic, strong) UIView * m_footerLineView;
@property (nonatomic, strong) UIView * m_headerLineView;
@end

@implementation VoteListTableViewCell

@synthesize m_voteNameLabel;
@synthesize m_footerLineView;
@synthesize m_headerLineView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createVotePercentageLabel];
        [self createHeaderLine];
        [self createFooterLine];
    }
    return self;
}

- (void)createVotePercentageLabel
{
    self.m_voteNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 0)];
    self.m_voteNameLabel.backgroundColor = [UIColor clearColor];
    self.m_voteNameLabel.numberOfLines = 0;
    self.m_voteNameLabel.highlightedTextColor = [UIColor whiteColor];
    self.m_voteNameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.m_voteNameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.m_voteNameLabel];
}

- (void)createFooterLine
{
    self.m_footerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5f)];
    self.m_footerLineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];;
    self.m_footerLineView.hidden = YES;
    [self addSubview:self.m_footerLineView];
}

- (void)createHeaderLine
{
    self.m_headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5f)];
    self.m_headerLineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];;
    [self addSubview:self.m_headerLineView];
}

- (void)setCellData:(NSString *)voteName andHeight:(CGFloat)cellHeight
{
    CGRect frame = self.m_voteNameLabel.frame;
    frame.size.height = cellHeight - 30;
    self.m_voteNameLabel.frame = frame;
    self.m_voteNameLabel.text = voteName;
    
    self.m_footerLineView.hidden = NO;
    frame = self.m_footerLineView.frame;
    frame.origin.y = cellHeight - 0.5f;
    self.m_footerLineView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
