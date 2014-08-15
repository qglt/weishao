//
//  ShakeImageView.m
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "ShakeImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImUtils.h"

@interface ShakeImageView ()
{
    CGRect m_frame;
    UIImageView * m_imageView;
    NSString * m_imagePath;
    UIButton * m_deleteButton;
    UIButton * m_addButton;
    UILabel * m_nameLabel;
}

@property (nonatomic, strong) UIImageView * m_imageView;
@property (nonatomic, strong) NSString * m_imagePath;
@property (nonatomic, strong) UIButton * m_deleteButton;
@property (nonatomic, strong) UIButton * m_addButton;
@property (nonatomic, strong) UILabel * m_nameLabel;



@end

@implementation ShakeImageView

@synthesize m_imageView;
@synthesize m_imagePath;
@synthesize m_deleteButton;
@synthesize m_addButton;
@synthesize m_delegate;
@synthesize m_nameLabel;

- (id)initWithFrame:(CGRect)frame withImagePath:(NSString *)imagePath
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor yellowColor];
        m_frame = frame;
        self.m_imagePath = imagePath;
        self.clipsToBounds = YES;
        [self createImageView];
        [self createNameLabel];
        [self createDeleteButton];
        [self createAddButton];
    }
    return self;
}

- (void)createImageView
{
    self.m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 50, 50)];
    self.m_imageView.image = [UIImage imageNamed:self.m_imagePath];
    self.m_imageView.layer.cornerRadius = 50 / 2.0f;
    self.m_imageView.layer.masksToBounds = YES;
    self.m_imageView.userInteractionEnabled = YES;
    [self addSubview:self.m_imageView];
}

- (void)createNameLabel
{
    self.m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4 + 50, m_frame.size.width - 8, m_frame.size.height - 4 - 50 - 6)];
    self.m_nameLabel.backgroundColor = [UIColor clearColor];
    self.m_nameLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_nameLabel.textAlignment = NSTextAlignmentCenter;
    self.m_nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    [self addSubview:self.m_nameLabel];
}

- (void)createAddButton
{
    self.m_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_addButton.backgroundColor = [UIColor clearColor];
    self.m_addButton.hidden = YES;
    self.m_addButton.enabled = NO;
    self.m_addButton.frame = CGRectMake(8, 4, 50, 50);
    [self.m_addButton setBackgroundImage:[UIImage imageNamed:@"addMemberNormal@2x.png"] forState:UIControlStateNormal];
    [self.m_addButton setBackgroundImage:[UIImage imageNamed:@"addMemberPressed@2x.png"] forState:UIControlStateSelected];
    [self.m_addButton setBackgroundImage:[UIImage imageNamed:@"addMemberPressed@2x.png"] forState:UIControlStateHighlighted];

    [self.m_addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_addButton];
}

- (void)addButtonPressed:(UIButton *)button
{
    [m_delegate addButtonPressedInShakeImageView:button];
}

- (void)setImage:(UIImage *)image
{
    self.m_imageView.image = image;
}

- (void)setNameLabel:(NSString *)text
{
    self.m_nameLabel.text = text;
}

- (void)setDeleteButtonState:(BOOL)hidden
{
    self.m_deleteButton.hidden = hidden;
}

- (void)showAddButtonWith:(BOOL)show
{
    self.m_addButton.hidden = !show;
    self.m_addButton.enabled = show;
    if (show) {
        self.m_deleteButton.hidden = show;
    }
}

- (void)createDeleteButton
{
    self.m_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_deleteButton.frame = CGRectMake(4, 0, 20, 20);
    self.m_deleteButton.backgroundColor = [UIColor clearColor];
    self.m_deleteButton.hidden = YES;
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"leftHeaderDeleteNormal.png"] forState:UIControlStateNormal];
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"leftHeaderDeleteSelected.png"] forState:UIControlStateSelected];
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"leftHeaderDeleteSelected.png"] forState:UIControlStateHighlighted];

    [self.m_deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_deleteButton];
}

- (void)deleteButtonPressed:(id)sender
{
    [self resetShakeState];
    [m_delegate deleteButtonPressedInShakeImageView:self];
}

- (void)startAnimation
{
    [self.layer addAnimation:[self getAnimation] forKey:@"wiggle"];
}

- (CABasicAnimation *)getAnimation
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.1;
    animation.repeatCount = 999999;
    animation.autoreverses = YES;
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -0.03, 0.0, 0.0, 0.03)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, 0.03, 0.0, 0.0, 0.03)];
    return animation;
}

- (void)resetShakeState
{
    self.m_deleteButton.hidden = YES;
    [self.layer removeAnimationForKey:@"wiggle"];
}

- (void)setShakeState:(BOOL)isShake
{
    if (isShake) {
        [self startAnimation];
    } else {
        [self resetShakeState];
    }
}

- (void)dealloc
{
    [self.m_imageView.layer removeAnimationForKey:@"wiggle"];
}

@end
