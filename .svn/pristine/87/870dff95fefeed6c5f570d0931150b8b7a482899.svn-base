//
//  AddCrowdTableViewCell.m
//  WhistleIm
//
//  Created by ruijie on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddCrowdTableViewCell.h"
#import "CrowdInfo.h"
#import "ImUtils.h"

#define IMGBTN_TAG 1000
#define ADDBTN_TAG 2000

@interface AddCrowdTableViewCell ()
{
    CrowdInfo * cellData;
    UIImageView * m_officialImageView;
    UIImageView * m_activeImageView;
    UIImageView * m_headerImageView;
}
@property (nonatomic,strong) CrowdInfo * cellData;
@property (nonatomic,strong) UIButton * imageButton;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * IdLabel;
@property (nonatomic,strong) UIButton * AddButton;
@property (nonatomic,strong) UIImageView * m_officialImageView;
@property (nonatomic,strong) UIImageView * m_activeImageView;
@property (nonatomic,strong) UIImageView * m_headerImageView;


@end

@implementation AddCrowdTableViewCell
@synthesize m_delegate;
@synthesize cellData;
@synthesize m_strSelectedType;
@synthesize m_activeImageView;
@synthesize m_officialImageView;
@synthesize m_headerImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBasicCondition];
        [self createImageViewButton];
        [self createOfficialImageView];
        [self createActiveImageView];
        [self createFriendHeaderImageView];
        [self createCrowdNameLabel];
        [self createCrowdIdLabel];
        [self createAddButton];
        [self addLine];
    }
    return self;
}
-(void)setBasicCondition
{
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)createOfficialImageView
{
    self.m_officialImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 6, 15, 15)];
    self.m_officialImageView.image = [UIImage imageNamed:@"officialCrowd.png"];
    self.m_officialImageView.hidden = YES;
    self.m_officialImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_officialImageView];
}

- (void)createActiveImageView
{
    self.m_activeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60 + 15 + 1, 6, 15, 15)];
    self.m_activeImageView.image = [UIImage imageNamed:@"activeCrowd.png"];
    self.m_activeImageView.backgroundColor = [UIColor clearColor];
    self.m_activeImageView.hidden = YES;
    [self addSubview:self.m_activeImageView];
}

-(void)addLine
{
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:225.0f / 255.0f green:225.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f];
    [self addSubview:line];
}

-(void)createCrowdNameLabel
{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 6, 320 - 60 - 45, 15)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self.nameLabel setFont:font];
    self.nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.nameLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_nameLabel];
}

-(void)createCrowdIdLabel
{
    self.IdLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 24, 320 - 60 - 45, 12)];
    self.IdLabel.backgroundColor = [UIColor clearColor];
    UIFont * si_font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self.IdLabel setFont:si_font];
    self.IdLabel.highlightedTextColor = [UIColor whiteColor];
    self.IdLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    [self.contentView addSubview:_IdLabel];
}

-(void)createAddButton
{
    self.AddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _AddButton.frame = CGRectMake(self.frame.size.width - 49, 0, 49, 45);
    _AddButton.tag = ADDBTN_TAG;
    [_AddButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_AddButton setBackgroundImage:[UIImage imageNamed:@"onlineSearch_add"] forState:UIControlStateNormal];
    [_AddButton setBackgroundImage:[UIImage imageNamed:@"onlineSearch_add_P"] forState:UIControlStateHighlighted];
    _AddButton.autoresizesSubviews = YES;
    _AddButton.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_AddButton];
}

- (void)createImageViewButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, 45, 45);
    button.tag = IMGBTN_TAG;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)createFriendHeaderImageView
{
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 35, 35)];
    self.m_headerImageView.backgroundColor = [UIColor orangeColor];
    self.m_headerImageView.layer.cornerRadius = 35 / 2.0f;
    self.m_headerImageView.layer.masksToBounds = YES;
    [self addSubview:self.m_headerImageView];
}

-(void)buttonPressed:(UIButton *)sender
{
    if (sender.tag == ADDBTN_TAG) {
        [m_delegate addButtonPressedInAddCrowdsTableViewCell:sender];
    }else{
        [m_delegate cellImageButtonPressed:sender];
    }
}

- (void)setCellData:(CrowdInfo *)data
{
    cellData = data;
    [self changeCondition];
}

-(void)changeCondition
{
    self.m_headerImageView.image = [cellData getCrowdIcon];
    _nameLabel.text = cellData.name;
    _IdLabel.text = [@"群号：" stringByAppendingString:[cellData getCrowdID]];
    
    [self clearImageView];
    [self changeFrameForCrowd:cellData];
}

- (void)clearImageView
{
    self.m_activeImageView.hidden = YES;
    self.m_officialImageView.hidden = YES;
    self.m_officialImageView.image = nil;
    self.m_activeImageView.image = nil;
    if (cellData.official) {
        self.m_officialImageView.hidden = NO;
        self.m_officialImageView.image = [UIImage imageNamed:@"officialCrowd.png"];
    }
    
    if ([cellData isActive]) {
        self.m_activeImageView.hidden = NO;
        self.m_activeImageView.image = [UIImage imageNamed:@"activeCrowd.png"];
    }
}

- (void)changeFrameForCrowd:(CrowdInfo *)crowdInfo
{
    self.m_activeImageView.frame = CGRectMake(60 + 15 + 1, 6, 15, 15);
    if (crowdInfo.official && ![crowdInfo isActive]) {
        CGRect frame = self.nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.size.width = 320 - 60 - 45 - 15 - 2;
        self.nameLabel.frame = frame;
    } else if (crowdInfo.official && [crowdInfo isActive]) {
        CGRect frame = self.nameLabel.frame;
        frame.origin.x = 60 + 15 + 1 + 15 + 2;
        frame.size.width = 320 - 60 - 45 - 15 - 1 - 15 - 2;
        self.nameLabel.frame = frame;
    } else if (!crowdInfo.official && [crowdInfo isActive]) {
        self.m_activeImageView.frame = CGRectMake(60, 6, 15, 15);
        CGRect frame = self.nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.size.width = 320 - 60 - 45 - 15 - 2;
        self.nameLabel.frame = frame;
    } else if (!crowdInfo.official && ![crowdInfo isActive]) {
        self.nameLabel.frame = CGRectMake(60, 6, 320 - 60 - 45, 15);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackground.png"]];


//    [(UIButton *)self.accessoryView setHighlighted:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.backgroundColor = [UIColor whiteColor];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
}
@end
