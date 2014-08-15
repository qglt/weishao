//
//  FriendsAndGroupViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FriendsAndGroupViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendInfo.h"
//#import "ImUtil.h"
#import "GroupCellData.h"
#import "CrowdInfo.h"
#import "Whistle.h"
#import "CrowdManager.h"
#import "RosterManager.h"
#import "ImageUtil.h"
#import "ImUtils.h"

#define TEACHER @"teacher"
#define STUDENT @"student"


#define DISTANCE 2.0f
#define IMAGE_VIEW_WIDTH 17.0f
#define IMAGE_VIEW_HEIGHT 17.0f


@interface FriendsAndGroupViewCell ()
{
    UIImageView * m_headerImageView;
    UIImageView * m_identityImageView;
    UIImageView * m_shieldImageView;
    UIImageView * m_statusImageView;
    UIImageView * m_activeImageView;
    
    UILabel * m_nameLabel;
    UILabel * m_personalizedSignatureLabel;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;
@property (nonatomic, strong) UIImageView * m_shieldImageView;
@property (nonatomic, strong) UIImageView * m_statusImageView;
@property (nonatomic, strong) UIImageView * m_activeImageView;


@property (nonatomic, strong) UILabel * m_nameLabel;
@property (nonatomic, strong) UILabel * m_personalizedSignatureLabel;


@end

@implementation FriendsAndGroupViewCell

@synthesize m_headerImageView;
@synthesize m_identityImageView;
@synthesize m_shieldImageView;
@synthesize m_statusImageView;
@synthesize m_activeImageView;

@synthesize m_nameLabel;
@synthesize m_personalizedSignatureLabel;

@synthesize m_isGroup;
@synthesize m_isCrowd;

@synthesize m_delegate;

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
    [self createButton];
    [self createNameLabel];
    [self createpersonalizedSignatureLabel];
    [self createHeaderImageView];
    [self createStatusImageView];
    [self createSeparateLine];
}

// 好友，群，讨论组头像
- (void)createHeaderImageView
{
    // OK
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 35, 35)];
    self.m_headerImageView.image = nil;
    self.m_headerImageView.layer.cornerRadius = 35.0f / 2.0f;
    self.m_headerImageView.layer.masksToBounds = YES;
    self.m_headerImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_headerImageView];
}

- (void)createStatusImageView
{
    // OK
    self.m_statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 15, 15, 15)];
    self.m_statusImageView.backgroundColor = [UIColor clearColor];
    self.m_statusImageView.hidden = YES;
    [self addSubview:self.m_statusImageView];
}

- (void)createButton
{
    // OK
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, 45, 45);
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)buttonPressed:(UIButton *)button
{
    [m_delegate cellImageButtonPressed:button];
}

- (void)createIdentityImageView
{
    // OK
    self.m_identityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 6, 15, 15)];
    self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    self.m_identityImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_identityImageView];
}

- (void)createActiveImageView
{
    // OK
    self.m_activeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60 + 15 + 1, 15, 15, 15)];
    self.m_activeImageView.image = [UIImage imageNamed:@"activeCrowd.png"];
    self.m_activeImageView.backgroundColor = [UIColor clearColor];
    self.m_activeImageView.hidden = YES;
    [self addSubview:self.m_activeImageView];
}

- (void)createNameLabel
{
    // OK
    self.m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60 + 15 + 2, 6, 320 - 60 - 15 - 2 - 40, 15)];
    self.m_nameLabel.textAlignment = NSTextAlignmentLeft;
    self.m_nameLabel.backgroundColor = [UIColor clearColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self.m_nameLabel setFont:font];
    self.m_nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_nameLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_nameLabel];
}

- (void)createpersonalizedSignatureLabel
{
    // OK
    self.m_personalizedSignatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 24, 320 - 60 - 40, 12)];
    self.m_personalizedSignatureLabel.textAlignment = NSTextAlignmentLeft;
    self.m_personalizedSignatureLabel.backgroundColor = [UIColor clearColor];
    
    UIFont * si_font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self.m_personalizedSignatureLabel setFont:si_font];
    self.m_personalizedSignatureLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_personalizedSignatureLabel.highlightedTextColor = [UIColor whiteColor];

    [self addSubview:self.m_personalizedSignatureLabel];
}

- (void)createSeparateLine
{
    // OK
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    imageView.image = [UIImage imageNamed:@"separateLine.png"];
    [self addSubview:imageView];
}

- (void)setCellData:(FriendInfo *)friendInfo
{
    [self setFriendsData:friendInfo];
}

- (void)setCrowdAndGroupData:(id)data
{
    if (m_isCrowd) {
        [self setCrowdCellData:data];
    } else {
        [self setGroupCellData:data];
    }
}

- (void)setCrowdCellData:(CrowdInfo *)crowdInfo
{
    //NSInteger alert;//0-接收并提醒；1-接收不提醒；2-不接收
    NSLog(@"crowdInfo alert in FriendsAndGroupViewCell == %d", crowdInfo.alert);
    self.m_statusImageView.hidden = YES;
    self.m_statusImageView.image = nil;
    if (crowdInfo.alert == 2) {
        self.m_statusImageView.hidden = NO;
        self.m_statusImageView.image = [UIImage imageNamed:@"crowdShieldImg.png"];
    }
    
    self.m_activeImageView.hidden = YES;
    if ([crowdInfo isActive]) {
        self.m_activeImageView.hidden = NO;
        NSLog(@"crowdInfo.name == %@, and active == %d", crowdInfo.name, [crowdInfo isActive]);
    }
    
    if (crowdInfo.remark && crowdInfo.remark.length > 0) {
        self.m_nameLabel.text = crowdInfo.remark;
    } else {
        self.m_nameLabel.text = crowdInfo.name;
    }
    
    NSLog(@"crowdInfo.name == %@", crowdInfo.name);
    NSLog(@"crowdInfo.remark == %@", crowdInfo.remark);
    NSLog(@"[crowdInfo isActive] == %d", [crowdInfo isActive]);
    NSLog(@"crowdInfo.active == %@", crowdInfo.active);

    
    LOG_UI_INFO(@"crowdInfo.official  === %d", crowdInfo.official);
    if (crowdInfo.official) {
        self.m_identityImageView.hidden = NO;
        CGRect frame = self.m_identityImageView.frame;
        frame.origin.y = 15;
        self.m_identityImageView.frame = frame;
        self.m_identityImageView.image = [UIImage imageNamed:@"officialCrowd.png"];
    } else {
        self.m_identityImageView.hidden = YES;
        CGRect frame = self.m_identityImageView.frame;
        frame.origin.y = 6.0f;
        self.m_identityImageView.frame = frame;
    }
    
    [self changeFrameForCrowd:crowdInfo];
    self.m_personalizedSignatureLabel.hidden = YES;
    
    UIImage * image = [crowdInfo getCrowdIcon];
    
    // 冻结了
    if (crowdInfo.status == 1) {
        image = [[GetFrame shareInstance] convertImageToGrayScale:image];
    }
    self.m_headerImageView.image = image;
}

- (void)changeFrameForCrowd:(CrowdInfo *)crowdInfo
{
    self.m_activeImageView.frame = CGRectMake(60 + 15 + 1, 15, 15, 15);
    if (crowdInfo.official && ![crowdInfo isActive]) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.origin.y = 15;
        frame.size.width = 320 - 60 - 15 - 2 - 40;
        self.m_nameLabel.frame = frame;
    } else if (crowdInfo.official && [crowdInfo isActive]) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 1 + 15 + 2;
        frame.origin.y = 15;
        frame.size.width = 320 - 60 - 15- 1 - 15 - 2 - 40;
        self.m_nameLabel.frame = frame;
        
        NSLog(@"crowdInfo.name offical and active == %@", crowdInfo.name);

    } else if (!crowdInfo.official && [crowdInfo isActive]) {
        self.m_activeImageView.frame = CGRectMake(60, 15, 15, 15);
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60 + 15 + 2;
        frame.origin.y = 15;
        frame.size.width = 320 - 60 - 15 - 2 - 40;
        self.m_nameLabel.frame = frame;
    } else if (!crowdInfo.official && ![crowdInfo isActive]) {
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = 60;
        frame.origin.y = 15;
        frame.size.width = 320 - 60 - 40;
        self.m_nameLabel.frame = frame;
    }
}

// 设置讨论组cell的数据
- (void)setGroupCellData:(GroupCellData *)cellData
{
    self.m_activeImageView.hidden = YES;
    self.m_statusImageView.hidden = YES;
    NSLog(@"GroupCellData m_strGroupName == %@", cellData.m_strGroupName);
    NSLog(@"GroupCellData m_strMemberName == %@", cellData.m_strMemberName);

    self.m_nameLabel.text = cellData.m_strGroupName;
    self.m_personalizedSignatureLabel.hidden = NO;
    self.m_personalizedSignatureLabel.text = cellData.m_strMemberName;
    self.m_identityImageView.hidden = YES;

    self.m_nameLabel.frame = CGRectMake(60, 6, 320 - 60 - 15, 15);
    self.m_personalizedSignatureLabel.frame = CGRectMake(60, 24, 320 - 60 - 15, 12);
    
    // discussion_group_default.png
    [self setHeaderImageView:@"discussion_group_default.png"];
}

- (void)setHeaderImageView:(NSString *)imagePath
{
    self.m_headerImageView.image = nil;
    self.m_headerImageView.image = [UIImage imageNamed:imagePath];
}

// 设置好友页面的cell数据
- (void)setFriendsData:(FriendInfo *)friendInfo
{
    self.m_nameLabel.text = [[RosterManager shareInstance] getShownameByIdentity:friendInfo];
    self.m_personalizedSignatureLabel.text = friendInfo.moodWords;
    
    self.m_activeImageView.hidden = YES;
    self.m_identityImageView.hidden = YES;
    self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    self.m_identityImageView.frame = CGRectMake(60, 6, 15, 15);
    if ([friendInfo.identity_show isEqualToString:TEACHER]) {
        self.m_identityImageView.hidden = NO;
    }
    
    if (self.m_identityImageView.hidden == YES) {
        self.m_nameLabel.frame = CGRectMake(60, 6, 320 - 60 - 40, 15);
    } else {
        self.m_nameLabel.frame = CGRectMake(60 + 15 + 2, 6, 320 - 60 - 40 - 15 - 2, 15);
    }
    [self createFriendHeaderImageView:friendInfo];
    NSLog(@"identity_show == %@", friendInfo.identity_show);
}

- (void)createFriendHeaderImageView:(FriendInfo *)friendInfo
{
    self.m_headerImageView.image = nil;
    self.m_headerImageView.image = [self getHeaderImageWithFriendInfo:friendInfo];
}

- (UIImage *)getHeaderImageWithFriendInfo:(FriendInfo *)friendInfo
{
    NSLog(@"friendInfo.showName == %@, friendInfo.isOnline == %d, friendInfo.presence == %@", friendInfo.showName, friendInfo.isOnline, friendInfo.presence);
    NSLog(@"friendInfo.head == %@", friendInfo.head);


    NSString * imagePath = nil;
    self.m_statusImageView.hidden = NO;
    self.m_statusImageView.image = nil;
    if ([friendInfo.presence isEqualToString:@"Busy"]) {
        NSString * newState = [NSString stringWithFormat:@"%@%@", @"[忙碌]", friendInfo.moodWords];
        self.m_personalizedSignatureLabel.text = newState;
    } else if ([friendInfo.presence isEqualToString:@"Away"]) {
        NSString * newState = [NSString stringWithFormat:@"%@%@", @"[离开]", friendInfo.moodWords];
        self.m_personalizedSignatureLabel.text = newState;
    } else if ([friendInfo.presence isEqualToString:@"IOS"]) {
        imagePath = @"presence_apple.png";
    } else if ([friendInfo.presence isEqualToString:@"Android"]) {
        imagePath = @"presence_andriod.png";
    } else if ([friendInfo.presence isEqualToString:@"Offline"] || [friendInfo.presence isEqualToString:@"Online"]) {
        self.m_statusImageView.hidden = YES;
        
        if ([friendInfo.presence isEqualToString:@"Offline"]) {
            NSString * newState = [NSString stringWithFormat:@"%@%@", @"[离开]", friendInfo.moodWords];
            self.m_personalizedSignatureLabel.text = newState;
        }
    }
    self.m_statusImageView.image = [UIImage imageNamed:imagePath];
    NSLog(@"imagePath == %@, and friendShowName == %@ and self.m_statusImageView.hidden == %d", imagePath, friendInfo.showName, self.m_statusImageView.hidden);
    
    UIImage * image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:friendInfo convertToGray:YES];
    
//    if (friendInfo.isOnline == NO) {
//        image = [[GetFrame shareInstance] convertImageToGrayScale:image];
//    }
    return image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
