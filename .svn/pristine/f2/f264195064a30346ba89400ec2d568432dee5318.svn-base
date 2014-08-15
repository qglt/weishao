//
//  PersonalTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "PersonalTableViewCell.h"
#import "PersonalSettingData.h"
#import "GBPathImageView.h"
#import "SevenSwitch.h"
#import "ImUtils.h"

@interface PersonalTableViewCell ()
{
    UILabel * m_titleLabel;
    UILabel * m_contentLabel;
    CGFloat m_cellHeight;
    UIImageView * m_indicatorImageView;
    UIView * m_footerLineView;
    UIView * m_headerLineView;
    UIImageView * m_personalHeader;
    SevenSwitch * m_mySwitch;
    
    BOOL m_hasIndicator;
}

@property (nonatomic, strong) UILabel * m_titleLabel;
@property (nonatomic, strong) UILabel * m_contentLabel;
@property (nonatomic, strong) UIImageView * m_indicatorImageView;
@property (nonatomic, strong) UIView * m_footerLineView;
@property (nonatomic, strong) UIView * m_headerLineView;
@property (nonatomic, strong) UIImageView * m_personalHeader;
@property (nonatomic, strong) SevenSwitch * m_mySwitch;

@end

@implementation PersonalTableViewCell

@synthesize m_titleLabel;
@synthesize m_contentLabel;
@synthesize m_delegate;
@synthesize m_indicatorImageView;
@synthesize m_footerLineView;
@synthesize m_headerLineView;
@synthesize m_personalHeader;
@synthesize m_mySwitch;
@synthesize m_isCrowdDetailInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createTitleLabel];
        [self createContentLabel];
        [self createHeaderLine];
        [self createFooterLineWithFrame:CGRectMake(0, 0, 320, 1)];
        [self createIndicatorImageViewWithFrame:CGRectMake(0, 0, 0, 0) withImagePath:nil];
        [self createSwitchWithState:NO];
        [self createHeaderImageView];
    }
    return self;
}

- (void)createTitleLabel
{
    self.m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 0)];
    self.m_titleLabel.backgroundColor = [UIColor clearColor];
    self.m_titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.m_titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.m_titleLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.m_titleLabel];
}

- (void)createContentLabel
{
    self.m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 200, 0)];
    self.m_contentLabel.backgroundColor = [UIColor clearColor];
    self.m_contentLabel.hidden = YES;
    self.m_contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    self.m_contentLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_contentLabel.highlightedTextColor = [UIColor whiteColor];
    self.m_contentLabel.numberOfLines = 0;
    [self addSubview:self.m_contentLabel];
}

- (void)createHeaderImageView
{
    self.m_personalHeader = [[UIImageView alloc] initWithFrame:CGRectMake(255, 5, 35, 35)];
    self.m_personalHeader.backgroundColor = [UIColor clearColor];
    self.m_personalHeader.clipsToBounds = YES;
    self.m_personalHeader.image = nil;
    self.m_personalHeader.layer.cornerRadius = 35.0 / 2.0f;
    self.m_personalHeader.userInteractionEnabled = YES;
    [self addSubview:self.m_personalHeader];
}

- (void)setCellWithSettingData:(PersonalSettingData *)settingData
{
    self.m_titleLabel.text = settingData.m_title;
    [self.m_titleLabel sizeToFit];
    
    if (settingData.m_hasLabel) {
        self.m_contentLabel.text = settingData.m_content;
        self.m_contentLabel.hidden = NO;
    } else {
        self.m_contentLabel.hidden = YES;
        self.m_contentLabel.text = nil;
    }
    
    m_cellHeight = settingData.m_cellHeight;

    self.m_contentLabel.frame = CGRectMake(90, 5, 200, m_cellHeight - 10);
    
    if (settingData.m_textHeight <= 15.0f) {
        self.m_titleLabel.frame = CGRectMake(15, 0, 100, m_cellHeight);
        if (m_isCrowdDetailInfo) {
            self.m_contentLabel.textAlignment = NSTextAlignmentRight;
        } else {
            self.m_contentLabel.textAlignment = NSTextAlignmentLeft;
        }
    } else {
        self.m_titleLabel.frame = CGRectMake(15, 5, 80, 20);
        self.m_contentLabel.textAlignment = NSTextAlignmentLeft;
    }
  
    self.m_indicatorImageView.image = nil;
    self.m_indicatorImageView.highlightedImage = nil;
    if (settingData.m_hasIndicator) {
        NSString * path = @"disclosure.png"; // disclosurep.png   disclosure.png
        self.m_indicatorImageView.image = [UIImage imageNamed:path];
        self.m_indicatorImageView.highlightedImage = [UIImage imageNamed:@"disclosurep.png"];
    }
    m_hasIndicator = settingData.m_hasIndicator;
    
    if (settingData.m_hasSelected) {
        NSString * path = nil;
        if (settingData.m_isOnLine) {
            path = @"singleSelected.png";
        } else {
            path = @"singleUnselected.png";
        }
        self.m_indicatorImageView.image = [UIImage imageNamed:path];
        CGRect titleFrame = self.m_titleLabel.frame;
        titleFrame.size.width = 260.0f;
        self.m_titleLabel.frame = titleFrame;
    }
    
    if (settingData.m_hasSelected) {
        self.m_indicatorImageView.frame = CGRectMake(293, (m_cellHeight - 15) / 2.0f, 15, 15);
    } else {
        self.m_indicatorImageView.frame = CGRectMake(290, (m_cellHeight - 15) / 2.0f, 15, 15);
    }

    self.m_footerLineView.frame = CGRectMake(0, m_cellHeight - 1, 320, 1);
    
    if (settingData.m_hasHeaderLine) {
        self.m_headerLineView.hidden = NO;
    } else {
        self.m_headerLineView.hidden = YES;
    }
    
    self.m_personalHeader.image = nil;
    if (settingData.m_hasImageView) {
        self.m_personalHeader.image = settingData.m_image;
    }
   
    if (settingData.m_hasSwitch) {
        self.m_mySwitch.hidden = NO;
        self.m_mySwitch.on = settingData.m_switchState;
    } else {
        self.m_mySwitch.hidden = YES;
        self.m_mySwitch.on = settingData.m_switchState;
    }
    
    if (settingData.m_needChangeTitleFrame) {
        CGRect titleFrame = self.m_titleLabel.frame;
        titleFrame.size.width = 260.0f;
        self.m_titleLabel.frame = titleFrame;
    }
}

- (void)createHeaderLine
{
    self.m_headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    self.m_headerLineView.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
    [self addSubview:self.m_headerLineView];
}

- (void)createFooterLineWithFrame:(CGRect)frame
{
    self.m_footerLineView = [[UIView alloc] initWithFrame:frame];
    self.m_footerLineView.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
    [self addSubview:self.m_footerLineView];
}

- (void)createIndicatorImageViewWithFrame:(CGRect)frame withImagePath:(NSString *)imagePath
{
    NSLog(@"imagePath == %@", imagePath);
    self.m_indicatorImageView = [[UIImageView alloc] initWithFrame:frame];
    self.m_indicatorImageView.image = [UIImage imageNamed:imagePath];
    self.m_indicatorImageView.userInteractionEnabled = YES;
    [self addSubview:self.m_indicatorImageView];
}

- (void)createSwitchWithState:(BOOL)isOn
{
    CGFloat x = 260.0f;

    self.m_mySwitch = [[SevenSwitch alloc] initWithFrame:CGRectMake(x, 10, 50, 25)];
    self.m_mySwitch.on = isOn;
    self.m_mySwitch.knobColor = [UIColor whiteColor];
    self.m_mySwitch.activeColor = [UIColor colorWithRed:206 / 255.0f green:206 / 255.0f blue:206 / 255.0f alpha:1.00f];
    self.m_mySwitch.inactiveColor = [UIColor colorWithRed:206 / 255.0f green:206 / 255.0f blue:206 / 255.0f alpha:1.00f];
    self.m_mySwitch.onColor = [UIColor colorWithRed:51 / 255.0f green:135 / 255.0f blue:183 / 255.0f alpha:1.0f];
    self.m_mySwitch.borderColor = [UIColor clearColor];
    self.m_mySwitch.shadowColor = [UIColor clearColor];
    self.m_mySwitch.hidden = YES;
    [self.m_mySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.m_mySwitch];
}

- (void)switchChanged:(UISwitch *)mySwitch
{
    [m_delegate switchClicked:mySwitch];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
