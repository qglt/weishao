//
//  SeriesButton.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "SeriesButton.h"

#define BUTTON_TAG_START 1000

#define DISTANC 2.0f

@interface SeriesButton ()
{
    CGRect m_frame;
    BOOL m_hasPhone;
}
@end

@implementation SeriesButton

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame wihtHasPhone:(BOOL)hasPhone
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        m_hasPhone = hasPhone;
        [self createBGImageView];
        [self createLineImageView];
        [self createButtons];
    }
    return self;
}

- (void)createButtons
{
    if (m_hasPhone) {
        [self createHasPhoneButtons];
    } else {
        [self createNonePhoneButtons];
    }
}

- (void)createBGImageView
{
    UIImageView * lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    lineImageView.image = [UIImage imageNamed:@"halfLucencyBG.png"];
    lineImageView.userInteractionEnabled = YES;
    [self addSubview:lineImageView];
}

- (void)createLineImageView
{
    UIImageView * lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 1)];
    lineImageView.image = [UIImage imageNamed:@"starLine.png"];
    lineImageView.userInteractionEnabled = YES;
    [self addSubview:lineImageView];
}

- (void)createHasPhoneButtons
{
    NSArray * titlesArr = [[NSArray alloc] initWithObjects:@"拨号", @"短信", @"删除好友", nil];
    NSArray * normalImageArr = [[NSArray alloc] initWithObjects:@"callUp_mobile_3s.png", @"short_message_3s.png", @"delete_friends_3s.png", nil];
    NSArray * selectedImageArr = [[NSArray alloc] initWithObjects:@"callUp_mobile_pressed_3s.png", @"short_message_pressed_3s.png", @"delete_friends_prssed_3s.png", nil];

    for (NSUInteger i = 0; i < 3; i++) {
        NSString * title = [titlesArr objectAtIndex:i];
        NSString * normalPath = [normalImageArr objectAtIndex:i];
        NSString * selectedPath = [selectedImageArr objectAtIndex:i];
        [self createButtonWithFrame:CGRectMake((m_frame.size.width / 3.0f) * i, 0, m_frame.size.width / 3.0f, m_frame.size.height) andNormalImage:normalPath andSelectedImage:selectedPath andButtonTitle:title andTag:BUTTON_TAG_START + i];
    }
}

- (void)createNonePhoneButtons
{
    NSArray * titlesArr = [[NSArray alloc] initWithObjects:@"拨号", @"删除好友", nil];
    NSArray * normalImageArr = [[NSArray alloc] initWithObjects:@"callUp_mobile_2s.png", @"delete_friends_2s.png", nil];
    NSArray * selectedImageArr = [[NSArray alloc] initWithObjects:@"callUp_mobile_pressed_2s.png", @"delete_friends_prssed_2s.png", nil];

    for (NSUInteger i = 0; i < 2; i++) {
        NSString * title = [titlesArr objectAtIndex:i];
        NSString * normalPath = [normalImageArr objectAtIndex:i];
        NSString * selectedPath = [selectedImageArr objectAtIndex:i];
        [self createButtonWithFrame:CGRectMake((m_frame.size.width / 2.0f) * i, 0, m_frame.size.width / 2.0f, m_frame.size.height) andNormalImage:normalPath andSelectedImage:selectedPath andButtonTitle:title andTag:BUTTON_TAG_START + i];
    }
}

- (void)createButtonWithFrame:(CGRect)frame andNormalImage:(NSString *)normalPath andSelectedImage:(NSString *)selectedPath andButtonTitle:(NSString *)title andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;

    [button setBackgroundImage:[UIImage imageNamed:normalPath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedPath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedPath] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setLabelTextWhiteColor:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setLabelTextWhiteColor:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(setLabelTextGrayColor:) forControlEvents:UIControlEventTouchDown];

    CGRect labelFrame = CGRectZero;
    if (m_hasPhone) {
        if (tag == BUTTON_TAG_START || tag == BUTTON_TAG_START + 1) {
            labelFrame = CGRectMake(50, DISTANC, 70, m_frame.size.height - DISTANC);
        } else {
            labelFrame = CGRectMake(33, DISTANC, 70, m_frame.size.height - DISTANC);
        }
    } else {
        
        if (tag == BUTTON_TAG_START) {
            labelFrame = CGRectMake(80, DISTANC, 70, m_frame.size.height - DISTANC);
        } else if (tag == BUTTON_TAG_START + 1){
            labelFrame = CGRectMake(65, DISTANC, 70, m_frame.size.height - DISTANC);
        }
    }
    
    [button addSubview:[self createTitleLabelWithFrame:labelFrame andTitle:title]];
    [self addSubview:button];
}

- (void)buttonPressed:(UIButton *)button
{
    if (m_hasPhone) {
        if (button.tag - BUTTON_TAG_START == 0) {
            [m_delegate callUpInSeriesButton];
        } else if (button.tag - BUTTON_TAG_START == 1) {
            [m_delegate sendMessageInSeriesButton];
        } else if (button.tag - BUTTON_TAG_START == 2) {
            [m_delegate deleteFriendInSeriesButton];
        }
    } else {
        if (button.tag - BUTTON_TAG_START == 0) {
            [m_delegate gotoPhonePageInSeriesButton];
        } else if (button.tag - BUTTON_TAG_START == 1) {
            [m_delegate deleteFriendInSeriesButton];
        }
    }
}

- (void)setLabelTextGrayColor:(UIButton *)button
{
    for (UIView * view in button.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel * titleLabel = (UILabel *)view;
            titleLabel.textColor = [UIColor colorWithRed:83.0f / 255.0f green:83.0f / 255.0f blue:83.0f / 255.0f alpha:1.0f];
        }
    }
}

- (void)setLabelTextWhiteColor:(UIButton *)button
{
    for (UIView * view in button.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel * titleLabel = (UILabel *)view;
            titleLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (UILabel *)createTitleLabelWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.text = title;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.textColor = [UIColor whiteColor];
    return titleLabel;
}

@end
