//
//  SearchFriendsTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 13-11-5.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SearchFriendsTableViewCell.h"
#import "LocalSearchData.h"
#import "FriendInfo.h"
#import "ImageUtil.h"
#import "Whistle.h"
#import "CrowdManager.h"
#import "ImUtils.h"

@interface SearchFriendsTableViewCell ()
{
    
    BOOL m_isGroup;
    
    BOOL m_isCrowd;
    
    BOOL m_isFriend;
    
    UIImageView * m_headerImageView;
    UIImageView * m_identityImageView;
    UIImageView * m_activeImageView;
    
    UILabel * m_nameLabel;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;
@property (nonatomic, strong) UIImageView * m_activeImageView;
@property (nonatomic, strong) UILabel * m_nameLabel;

@end

@implementation SearchFriendsTableViewCell

@synthesize m_headerImageView;
@synthesize m_identityImageView;
@synthesize m_activeImageView;
@synthesize m_nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createCellSubViews];
    }
    return self;
}

- (void)createCellSubViews
{
    [self createActiveImageView];
    [self createIdentityImageView];
    [self createNameLabel];
    [self createHeaderImageView];
    [self createSeparateLine];
}

// 好友，群，讨论组头像
- (void)createHeaderImageView
{
    // OK
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 35, 35)];
    self.m_headerImageView.image = nil;
    self.m_headerImageView.backgroundColor = [UIColor clearColor];
    self.m_headerImageView.layer.cornerRadius = 35 / 2.0f;
    self.m_headerImageView.layer.masksToBounds = YES;
    [self addSubview:self.m_headerImageView];
}

- (void)createIdentityImageView
{
    // OK
    self.m_identityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 15, 15, 15)];
    self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    self.m_identityImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_identityImageView];
}

- (void)createNameLabel
{
    // OK 无图情况坐标
    self.m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 320 - 60 - 15, 15)];
    self.m_nameLabel.textAlignment = NSTextAlignmentLeft;
    self.m_nameLabel.backgroundColor = [UIColor clearColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self.m_nameLabel setFont:font];
    self.m_nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_nameLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_nameLabel];
}

- (void)createSeparateLine
{
    // OK
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    imageView.image = [UIImage imageNamed:@"separateLine.png"];
    [self addSubview:imageView];
}

- (void)createActiveImageView
{
    //  OK
    self.m_activeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60 + 15 + 1, 15, 15, 15)];
    self.m_activeImageView.image = [UIImage imageNamed:@"activeCrowd@2x.png"];
    self.m_activeImageView.backgroundColor = [UIColor clearColor];
    self.m_activeImageView.hidden = YES;
    [self addSubview:self.m_activeImageView];
}

- (void)setCellData:(LocalSearchData *)searchData
{
    m_isFriend = NO;
    m_isCrowd = NO;
    m_isGroup = NO;
    if ([searchData.m_type isEqualToString:@"conversation"]) {
        m_isFriend = YES;
    } else if ([searchData.m_type isEqualToString:@"crowd_chat"]) {
        m_isCrowd = YES;
    } else if ([searchData.m_type isEqualToString:@"group_chat"]) {
        m_isGroup = YES;
    }
    
    self.m_activeImageView.hidden = YES;
    
    self.m_identityImageView.hidden = YES;

    if (m_isFriend) {
        if ([searchData.m_friedIdentity isEqualToString:@"teacher"]) {
            self.m_identityImageView.hidden = NO;
            // CGRectMake(60, 15, 320 - 60 - 15, 15)
            self.m_nameLabel.frame = CGRectMake(60 + 15 + 2, 15, 320 - 15 - 77, 15);
            self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
        } else {
            self.m_identityImageView.hidden = YES;
            self.m_nameLabel.frame = CGRectMake(60, 15, 320 - 60 - 15, 15);
            self.m_identityImageView.image = nil;
        }
        self.m_headerImageView.image = [self getHeaderImageWithLocalSearchData:searchData];
    } else if (m_isCrowd) {
        self.m_nameLabel.frame = CGRectMake(60, 15, 320 - 60 - 15, 15);
        if (searchData.m_strHeaderImagePath != nil && [searchData.m_strHeaderImagePath length] > 0) {
            self.m_headerImageView.image = [UIImage imageWithContentsOfFile:searchData.m_strHeaderImagePath];
        } else {
            self.m_headerImageView.image = [[CrowdManager shareInstance] getCrowdIcon:searchData.m_jid];
        }
        
        // 冻结了
        if (searchData.m_crowdInfo.status == 1) {
            UIImage * image = self.m_headerImageView.image;
            image = [[GetFrame shareInstance] convertImageToGrayScale:image];
            self.m_headerImageView.image = image;
        }
        
        if (searchData.m_officialCrowd) {
            self.m_identityImageView.image = [UIImage imageNamed:@"officialCrowd.png"];
            self.m_identityImageView.hidden = NO;
        } else {
            self.m_identityImageView.image = nil;
            self.m_identityImageView.hidden = YES;
        }
        
        if (searchData.m_activeCrowd) {
            self.m_activeImageView.hidden = NO;
        } else {
            self.m_activeImageView.hidden = YES;
        }
        
        [self changeFrameForCrowd:searchData];
        
    } else if (m_isGroup) {
        self.m_nameLabel.frame = CGRectMake(60, 15, 320 - 60 - 15, 15);
        self.m_headerImageView.image = [UIImage imageNamed:@"discussion_group_default.png"];
    }
    
    self.m_nameLabel.text = searchData.m_name;
 
    NSLog(@"searchData.m_strHeaderImagePath in cell == %@", searchData.m_strHeaderImagePath);
}

- (void)changeFrameForCrowd:(LocalSearchData *)searchData
{
    self.m_activeImageView.frame = CGRectMake(60 + 15 + 1, 15, 15, 15);

    if (searchData.m_officialCrowd && !searchData.m_activeCrowd) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.size.width = 320 - 60 - 15 - 2 - 15;
        self.m_nameLabel.frame = frame;
    } else if (searchData.m_officialCrowd && searchData.m_activeCrowd) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 1 + 15 + 2;
        frame.size.width = 320 - 60 - 15 - 1 - 15 - 2 - 15;
        self.m_nameLabel.frame = frame;
    } else if (!searchData.m_officialCrowd && searchData.m_activeCrowd) {
        self.m_activeImageView.frame = CGRectMake(60, 15, 15, 15);
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.size.width = 320 - 60 - 15 - 2 - 15;
        self.m_nameLabel.frame = frame;
    } else if (!searchData.m_officialCrowd && !searchData.m_activeCrowd) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60;
        frame.size.width = 320 - 60 - 15;
        self.m_nameLabel.frame = frame;
    }
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
