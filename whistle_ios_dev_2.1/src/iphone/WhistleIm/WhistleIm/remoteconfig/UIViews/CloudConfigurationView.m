//
//  CloudConfigurationView.m
//  WhistleIm
//
//  Created by 移动组 on 13-12-10.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CloudConfigurationView.h"
#import "ImUtils.h"

@interface CloudConfigurationView ()
{
    CGRect _mainScreenFrame;

}
@end
@implementation CloudConfigurationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createSubviews];
    }
    return self;
}
#pragma mark -

#pragma mark createSubviews
- (void)createSubviews
{
    _mainScreenFrame = [[UIScreen mainScreen] bounds];
    [self createSelectSchoolSubviews];
}


- (void)createSelectSchoolSubviews
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(596/2, 16.25, 7, 25/2)];
    img.image = [UIImage imageNamed:@"disclosure.png"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64+8, 320, 45)];
    view.backgroundColor = [ImUtils colorWithHexString:@"#ffffff"];

    [self addSubview:view];
    self.recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recommendButton.frame = CGRectMake(15, 0, 320, 45);
    [self.recommendButton setTitle:@"推荐学校" forState:0];
    self.recommendButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f ];
    [self.recommendButton setTitleColor:[ImUtils colorWithHexString:@"#262626" ] forState:0];
    self.recommendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.recommendButton addTarget:self action:@selector(recommendButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:img];
    [view addSubview:self.recommendButton];
    
    
    
    UIImageView *img2 = [[UIImageView alloc] initWithFrame:CGRectMake(596/2, 16.25, 7, 25/2)];
    img2.image = [UIImage imageNamed:@"disclosure.png"];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 64+8+61, 320, 45)];
    view2.backgroundColor = [ImUtils colorWithHexString:@"#ffffff"];

    
    //如果系统推荐的学校不正确，手动选择正确的学校
    UIButton *selectSchoolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectSchoolButton.frame = CGRectMake(15, 0, 320, 45);
    [selectSchoolButton setTitle:@"选择学校" forState:UIControlStateNormal];
    selectSchoolButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [selectSchoolButton setTitleColor:[ImUtils colorWithHexString:@"#262626" ] forState:0];
    selectSchoolButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [selectSchoolButton addTarget:self action:@selector(selectSchoolButton:) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:selectSchoolButton];
    [view2 addSubview:img2];
    [self addSubview:view2];
    self.recommendButton.hidden = NO;
    
}

#pragma mark -

#pragma mark buttonMethods
- (void)recommendButton:(UIButton *)sender
{

    //若代理存在且响应了recommendButton:这个方法
    if (self.cloudDelegate && [self.cloudDelegate respondsToSelector:@selector(downLoadButton:)]) {
        [self.cloudDelegate downLoadButton:sender];
        //返回RemoteConfigInfo对象给AccountManager
    }
}

- (void)selectSchoolButton:(UIButton *)sender
{
    

    if (self.cloudDelegate && [self.cloudDelegate respondsToSelector:@selector(selectButton:)]) {
        [self.cloudDelegate selectButton:sender];
    }
}

@end
