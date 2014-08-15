//
//  MemberImageView.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "MemberImageView.h"
#import "ImUtils.h"

@interface MemberImageView ()
{
    CGRect m_frame;
    UIImageView * m_imageView;
    UILabel * m_numberLabel;
}

@property (nonatomic, strong) UIImageView * m_imageView;
@property (nonatomic, strong) UILabel * m_numberLabel;

@end
@implementation MemberImageView

@synthesize m_imageView;
@synthesize m_numberLabel;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame andWithImage:(UIImage *)image andWithNumbers:(NSString *)numbers
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"frame == %@", NSStringFromCGRect(frame));
        m_frame = frame;
        [self createImageViewWithImage:image];
        [self createLabelWithNumber:numbers];
        [self createDeleteImageButton];
    }
    return self;
}

- (void)createImageViewWithImage:(UIImage *)image
{
    self.m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    self.m_imageView.image = image;
    self.m_imageView.layer.cornerRadius = m_frame.size.width / 2.0f;
    self.m_imageView.layer.masksToBounds = YES;
    self.m_imageView.userInteractionEnabled = YES;
    self.m_imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_imageView];
}

- (void)createLabelWithNumber:(NSString *)numbers
{
    self.m_numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];;
    self.m_numberLabel.backgroundColor = [UIColor clearColor];
    self.m_numberLabel.textColor = [UIColor blackColor];
    self.m_numberLabel.textAlignment = NSTextAlignmentCenter;
    self.m_numberLabel.text = numbers;
    self.m_numberLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    self.m_numberLabel.textColor = [ImUtils colorWithHexString:@"#6A6A6A"];
    [self addSubview:self.m_numberLabel];
}

- (void)createDeleteImageButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, m_frame.size.width, m_frame.size.height);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)buttonPressed:(UIButton *)button
{
    [m_delegate deleteImageButtonPressedInMemberImageView:self];
}

- (void)resetImageViewWithImage:(UIImage *)image andResetLabelWith:(NSString *)numbers
{
    self.m_imageView.image = image;
    self.m_numberLabel.text = numbers;
}

@end
