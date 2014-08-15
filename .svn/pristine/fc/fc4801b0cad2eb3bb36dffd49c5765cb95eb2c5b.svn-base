//
//  AddFriendsTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AddFriendsTableViewCell.h"
#import "FriendInfo.h"
//#import "ImUtil.h"
#import "ImUtils.h"
#import "ImageUtil.h"
#define TEACHER @"teacher"
#define STUDENT @"student"
#define GIRL @"girl"
#define BOY @"boy"

#define START_X 63.0f
#define IDENTY_IMAGE_WIDTH 15.0f
#define SEX_IMAGE_WIDTH 20.0f
#define AGE_LABEL_WIDTH 30.0f
#define DISTANCE 10.0f


@interface AddFriendsTableViewCell ()
{
    UIImageView * m_headerImageView;
    UIImageView * m_identityImageView;
    
    UILabel * m_nameLabel;
    UILabel * m_personalizedSignatureLabel;
    UILabel * m_ageLabel;
    
    UILabel * m_sexLabel;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;
@property (nonatomic, strong) UILabel * m_nameLabel;
@property (nonatomic, strong) UILabel * m_personalizedSignatureLabel;
@property (nonatomic, strong) UILabel * m_ageLabel;
@property (nonatomic, strong) UILabel * m_sexLabel;

@end

@implementation AddFriendsTableViewCell

@synthesize m_headerImageView;
@synthesize m_identityImageView;
@synthesize m_nameLabel;
@synthesize m_personalizedSignatureLabel;
@synthesize m_ageLabel;
@synthesize m_strSelectedType;
@synthesize m_sexLabel;

@synthesize m_delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createNameLabel];
        [self createIdentityImageView];
        [self createpersonalizedSignatureLabel];
        [self createSexLabel];
        [self createAgeLabel];
        [self createAddButton];
        [self createImageViewButton];
        [self createFriendHeaderImageView];
        [self createSeparateLine];
    }
    return self;
}

- (void)createFriendHeaderImageView
{
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 35, 35)];
    self.m_headerImageView.backgroundColor = [UIColor orangeColor];
    self.m_headerImageView.layer.cornerRadius = 35 / 2.0f;
    self.m_headerImageView.layer.masksToBounds = YES;
    [self addSubview:self.m_headerImageView];
}

- (void)createImageViewButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, 45, 45);
    [button addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)imageButtonPressed:(UIButton *)button
{
    [m_delegate cellImageButtonPressed:button];
}

- (void)createIdentityImageView
{
    self.m_identityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 6, 15, 15)];
    self.m_identityImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    self.m_identityImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_identityImageView];
}

- (void)createNameLabel
{
    self.m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 6, 0, 15)];
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
    self.m_personalizedSignatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 24, 320 - 60 - 45, 12)];
    self.m_personalizedSignatureLabel.textAlignment = NSTextAlignmentLeft;
    self.m_personalizedSignatureLabel.backgroundColor = [UIColor clearColor];
    UIFont * si_font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self.m_personalizedSignatureLabel setFont:si_font];
    self.m_personalizedSignatureLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_personalizedSignatureLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_personalizedSignatureLabel];
}

- (void)createSexLabel
{
    self.m_sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 0, 12)];
    self.m_sexLabel.textAlignment = NSTextAlignmentLeft;
    self.m_sexLabel.backgroundColor = [UIColor clearColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self.m_sexLabel setFont:font];
    self.m_sexLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_sexLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_sexLabel];
}

- (void)createAgeLabel
{
    self.m_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 50, 12)];
    self.m_ageLabel.textAlignment = NSTextAlignmentLeft;
    self.m_ageLabel.backgroundColor = [UIColor clearColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self.m_ageLabel setFont:font];
    self.m_ageLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_ageLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.m_ageLabel];
}

- (void)createSeparateLine
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    imageView.image = [UIImage imageNamed:@"separateLine.png"];
    [self addSubview:imageView];
}

// ols_ic_add.png

- (void)createAddButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(280, 7, 40, 40);
    button.frame = CGRectMake(self.frame.size.width - 49, 0, 49, 45);
    [button setBackgroundImage:[UIImage imageNamed:@"onlineSearch_add"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"onlineSearch_add_P"] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"onlineSearch_add_P"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)buttonPressed:(UIButton *)button
{
    [m_delegate addButtonPressedInAddFriendsTableViewCell:button];
}

- (void)setCellData:(FriendInfo *)friendInfo
{
    NSLog(@"\n\n\n");
    NSLog(@"friendInfo.head == %@", friendInfo.head);
    NSLog(@"friendInfo.showName == %@", friendInfo.showName);
    NSLog(@"friendInfo.showName == %@", friendInfo.name);

    NSLog(@"friendInfo.moodWords == %@", friendInfo.moodWords);
    NSLog(@"friendInfo.sexShow == %@", friendInfo.sexShow);
    NSLog(@"friendInfo.age == %@", friendInfo.age);
    NSLog(@"friendInfo.nickName == %@", friendInfo.nickName);

    NSLog(@"friendInfo.identity_show == %@", friendInfo.identity_show);



    self.m_headerImageView.image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:friendInfo convertToGray:NO];
    if ([self.m_strSelectedType isEqualToString:@"name"]) {
        self.m_nameLabel.text = friendInfo.name;
    } else if ([self.m_strSelectedType isEqualToString:@"nick_name"]) {
        self.m_nameLabel.text = friendInfo.name;
    } else if ([self.m_strSelectedType isEqualToString:@"aid"]) {
        self.m_nameLabel.text = friendInfo.aid;
    }
    self.m_personalizedSignatureLabel.text = friendInfo.moodWords;
    self.m_identityImageView.hidden = YES;
    if ([friendInfo.identity isEqualToString:@"biz.vcard.teacher"]) {
        self.m_identityImageView.hidden = NO;
    }
    if ([friendInfo.sexShow isEqualToString:@"boy"]) {
        self.m_sexLabel.text = @"男";
    } else {
        self.m_sexLabel.text = @"女";
    }
    
    self.m_ageLabel.text = @"";
    if ([friendInfo.age length] > 0 && friendInfo.age != NULL && friendInfo.age != nil && ![friendInfo.age isEqualToString:@"(null)"]) {
        if ([self hasNumberWithAgeStr:friendInfo.age]) {
            NSString * age = [NSString stringWithFormat:@"%@岁", friendInfo.age];
            self.m_ageLabel.text = age;
        } else {
            self.m_ageLabel.text = @"";
        }
    } else {
        self.m_ageLabel.text = @"";
    }
    
    [self changeFrame:self.m_nameLabel.text andSex:self.m_sexLabel.text andAge:self.m_ageLabel.text];
}

- (BOOL)hasNumberWithAgeStr:(NSString *)age
{
    for (NSUInteger i = 0; i < 10; i++) {
        if ([age hasPrefix:[NSString stringWithFormat:@"%d", i]]) {
            return YES;
        }
    }
    return NO;
}

- (void)changeFrame:(NSString *)name andSex:(NSString *)sex andAge:(NSString *)age
{
    CGSize nameSize = [name sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
    NSLog(@"nameSize == %@", NSStringFromCGSize(nameSize));
    CGRect nameFrame = self.m_nameLabel.frame;
    nameFrame.size.width = nameSize.width;
    self.m_nameLabel.frame = nameFrame;
    
    CGSize sexSize = [sex sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f]];
    NSLog(@"sexSize == %@", NSStringFromCGSize(sexSize));
    CGRect sexFrame = self.m_sexLabel.frame;
    sexFrame.origin.x = 60 + nameSize.width + 10;
    sexFrame.size.width = sexSize.width;
    self.m_sexLabel.frame = sexFrame;
    
    CGSize ageSize = [age sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f]];
    NSLog(@"ageSize == %@", NSStringFromCGSize(ageSize));
    CGRect ageFrame = self.m_ageLabel.frame;
    ageFrame.origin.x = 60 + nameSize.width + 10 + sexSize.width + 10;
    self.m_ageLabel.frame = ageFrame;
    
    if (self.m_identityImageView.hidden) {
        nameFrame = self.m_nameLabel.frame;
        nameFrame.origin.x = 60.0f;
        
        if (nameFrame.size.width > 320 - 60 - 45 - 10 - 10 - sexSize.width - 50) {
            nameFrame.size.width = 320 - 60 - 45 - 10 - 10 - sexSize.width - 50;
        }
        self.m_nameLabel.frame = nameFrame;
    } else {
        nameFrame = self.m_nameLabel.frame;
        nameFrame.origin.x = 60.0f + 15 + 2;
        if (nameFrame.size.width > 320 - 60 - 45 - 10 - 10 - sexSize.width - 50 - 15 - 2) {
            nameFrame.size.width = 320 - 60 - 45 - 10 - 10 - sexSize.width - 50 - 15 - 2;
        }
        self.m_nameLabel.frame = nameFrame;
        
        CGRect sexFrame = self.m_sexLabel.frame;
        sexFrame.origin.x = 60 + nameSize.width + 10 + 15 + 2;
        self.m_sexLabel.frame = sexFrame;
        
        CGRect ageFrame = self.m_ageLabel.frame;
        ageFrame.origin.x = 60 + nameSize.width + 10 + sexSize.width + 10 + 15 + 2;
        self.m_ageLabel.frame = ageFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
