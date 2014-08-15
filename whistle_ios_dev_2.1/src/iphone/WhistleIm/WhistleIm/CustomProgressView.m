//
//  CustomProgressView.m
//  WhistleIm
//
//  Created by 管理员 on 14-3-4.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CustomProgressView.h"

@interface CustomProgressView ()
{
    CGRect m_frame;
    UIImageView * m_upperImageView;
}

@property (nonatomic, strong) UIImageView * m_upperImageView;
@end

@implementation CustomProgressView

@synthesize progress;
@synthesize m_upperImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 2)];
    if (self) {
        // Initialization code
        m_frame = frame;
        [self createBottomImageView];
        [self createUppperImageView];
    }
    return self;
}

- (void)setProgress:(CGFloat)newProgress
{
    CGRect frame = self.m_upperImageView.frame;
    frame.size.width = newProgress * m_frame.size.width;
    self.m_upperImageView.frame = frame;
}

- (void)createBottomImageView
{
    UIImageView * bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 2)];
    bottomImageView.image = [UIImage imageNamed:@"grayBottom.png"];
    [self addSubview:bottomImageView];
}

- (void)createUppperImageView
{
    self.m_upperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    self.m_upperImageView.image = [UIImage imageNamed:@"blueUpper.png"];
    [self addSubview:self.m_upperImageView];
}

@end
