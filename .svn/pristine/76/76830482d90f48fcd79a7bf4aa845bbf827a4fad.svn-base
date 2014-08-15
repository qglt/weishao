//
//  AddMembersTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddMembersTableViewCell.h"
#import "ImUtils.h"
#import "RosterManager.h"
#import "LocalSearchData.h"

#define TEACHER @"teacher"

@interface AddMembersTableViewCell ()
{
    UIImageView * m_headerImageView;
    UIImageView * m_indicatorImageView;
    UIImageView * m_identityImageView;

    UILabel * m_nameLabel;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_indicatorImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;


@property (nonatomic, strong) UILabel * m_nameLabel;

@end

@implementation AddMembersTableViewCell

@synthesize m_headerImageView;
@synthesize m_indicatorImageView;
@synthesize m_identityImageView;
@synthesize m_nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createHeaderImageView];
        [self createIndicatorImageView];
        [self createIdentityImageView];
        [self createSeparateLine];
        [self createNameLabel];
    }
    return self;
}

// 好友，群，讨论组头像
- (void)createHeaderImageView
{
    // OK
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 35, 35)];
    self.m_headerImageView.image = nil;
    self.m_headerImageView.layer.cornerRadius = 35.0f / 2.0f;
    self.m_headerImageView.layer.masksToBounds = YES;
    self.m_headerImageView.backgroundColor = [UIColor orangeColor];
    [self addSubview:self.m_headerImageView];
}

- (void)createIdentityImageView
{
    self.m_identityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 15, 15, 15)];
    self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    self.m_identityImageView.hidden = YES;
    self.m_identityImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_identityImageView];
}

- (void)createNameLabel
{
    // 无图情况 OK
    self.m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 320 - 60 - 15 * 3, 15)];
    self.m_nameLabel.textAlignment = NSTextAlignmentLeft;
    self.m_nameLabel.backgroundColor = [UIColor clearColor];
    self.m_nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.m_nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_nameLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_nameLabel];
}

- (void)createIndicatorImageView
{
    // OK
    self.m_indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 15, 15, 15)];
    self.m_indicatorImageView.userInteractionEnabled = YES;
    self.m_indicatorImageView.image = [UIImage imageNamed:@"moreUnselected.png"];
    [self addSubview:self.m_indicatorImageView];
}

- (void)createSeparateLine
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5f)];
    // separateLine.png
    imageView.image = [UIImage imageNamed:@"separateLine.png"];
    [self addSubview:imageView];
}

- (void)setCellData:(id)data andIsSelected:(BOOL)selected andType:(NSString *)type
{
    if ([type isEqualToString:@"search"]) {
        LocalSearchData * local = (LocalSearchData *)data;
        [self setCellDataWithLocalSearchData:local andIsSelected:selected];
    } else if ([type isEqualToString:@"friend"]) {
        FriendInfo * friend = (FriendInfo *)data;
        [self setCellDataWithFriendInfo:friend andIsSelected:selected];
    }
    
    NSString * imagePath = nil;
    if (selected) {
        imagePath = @"moreSelected.png";
    } else {
        imagePath = @"moreUnselected.png";
    }
    
    [self setSelectedImageView:imagePath];
}

- (void)setCellDataWithFriendInfo:(FriendInfo *)friendInfo andIsSelected:(BOOL)selected
{
    self.m_headerImageView.image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:friendInfo convertToGray:NO];
    
    if ([friendInfo.identity_show isEqualToString:TEACHER]) {
        self.m_identityImageView.hidden = NO;
    } else {
        self.m_identityImageView.hidden = YES;
    }
    
    self.m_nameLabel.text = [[RosterManager shareInstance] getShownameByIdentity:friendInfo];
}

- (void)setCellDataWithLocalSearchData:(LocalSearchData *)local andIsSelected:(BOOL)selected
{
    self.m_headerImageView.image = [self getHeaderImageWithLocalSearchData:local];

    if ([local.m_friedIdentity isEqualToString:TEACHER]) {
        self.m_identityImageView.hidden = NO;
    } else {
        self.m_identityImageView.hidden = YES;
    }
    
    self.m_nameLabel.text = local.m_name;
}

- (UIImage *)getHeaderImageWithLocalSearchData:(LocalSearchData *)searchData
{
    UIImage * image = nil;
    image = [UIImage imageWithContentsOfFile:searchData.m_strHeaderImagePath];
    
    if (image == nil) {
        if ([searchData.m_sexShow isEqualToString:SEX_GIRL]) {
            image = [UIImage imageNamed:@"identity_woman.png"];
        } else {
            image = [UIImage imageNamed:@"identity_man_new.png"];
        }
    }
    
    return image;
}

- (void)setSelectedImageView:(NSString *)imagePath
{
    self.m_indicatorImageView.image = [UIImage imageNamed:imagePath];
    
    if (self.m_identityImageView.hidden == YES) {
        self.m_nameLabel.frame = CGRectMake(60, 15, 320 - 60 - 15 * 3, 15);
    } else {
        self.m_nameLabel.frame = CGRectMake(60 + 15 + 2, 15, 320 - 60 - 15 * 3 - 15 - 2, 15);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
