//
//  CustomScrollTableViewCell.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CustomScrollTableViewCell.h"
#import "JGScrollableTableViewCellAccessoryButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CustomScrollTableViewCell()
{
}
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CustomScrollTableViewCell
@synthesize actionView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setScrollViewBackgroundColor:[UIColor colorWithWhite:0.975f alpha:1.0f]];
        self.contentView.backgroundColor = [UIColor grayColor];
        
        actionView = [JGScrollableTableViewCellAccessoryButton button];
        
        [actionView setButtonColor:[UIColor colorWithRed:0.975f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [actionView setButtonColor:[UIColor colorWithRed:0.8f green:0.1f blue:0.1f alpha:1.0f] forState:UIControlStateHighlighted];
        [actionView addTarget:self action:@selector(mark:) forControlEvents:UIControlEventTouchUpInside];
        
        actionView.frame = CGRectMake(80.0f, 0.0f, 80.0f, 0.0f);
        actionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        JGScrollableTableViewCellAccessoryButton *moreView = [JGScrollableTableViewCellAccessoryButton button];
        
        [moreView setButtonColor:[UIColor colorWithWhite:0.8f alpha:1.0f] forState:UIControlStateNormal];
        [moreView setButtonColor:[UIColor colorWithWhite:0.65f alpha:1.0f] forState:UIControlStateHighlighted];
        [moreView addTarget:self action:@selector(pushAppDetail) forControlEvents:UIControlEventTouchUpInside];
        [moreView setTitle:@"详情" forState:UIControlStateNormal];
        moreView.frame = CGRectMake(0.0f, 0.0f, 80.0f, 0.0f);
        moreView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 0.0f)];
        
        [optionView addSubview:moreView];
        [optionView addSubview:actionView];
        
        [self setOptionView:optionView side:JGScrollableTableViewCellSideRight];
        [self createView];

    }
    return self;
}
- (void)createView
{
    self.headView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 10, 55, 55)];
    self.headView.layer.cornerRadius = 10.0f;
    self.headView.layer.masksToBounds = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(81, 10, 200, 15)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    self.nameLabel.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    
    self.appType = [[UILabel alloc] initWithFrame:CGRectMake(81, 30, 60, 15)];
    self.appType.backgroundColor = [UIColor clearColor];
    self.appType.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.appType.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    
    self.organizationLabel = [[UILabel alloc] initWithFrame:CGRectMake(81+60+10, 30, 80, 15)];
    self.organizationLabel.backgroundColor = [UIColor clearColor];
    self.organizationLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.organizationLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    
    self.popularityLable = [[UILabel alloc] initWithFrame:CGRectMake(81, 45, 80, 15)];
    self.popularityLable.backgroundColor = [UIColor clearColor];
    self.popularityLable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.popularityLable.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    
    UIImage *imag1 = [self reSizeImage:[UIImage imageNamed:@"empty_star.png"] toSize:CGSizeMake(12, 12)];
    UIImage *imag2 = [self reSizeImage:[UIImage imageNamed:@"solid_star.png"] toSize:CGSizeMake(12, 12)];
    RatingControl *ratingControl = [[RatingControl alloc] initWithLocation:CGPointMake(12, 12) emptyImage:imag1 solidImage:imag2 andMaxRating:5];
    [ratingControl setRating:3];
    ratingControl.frame = CGRectMake(80, 58, 72, 100);
    
    [self addContentView:self.headView];
    [self addContentView:self.nameLabel];
    [self addContentView:self.appType];
    [self addContentView:self.organizationLabel];
    [self addContentView:self.popularityLable];
    [self addContentView:ratingControl];
}
//自定长宽
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}
-(void) setupCell:(BaseAppInfo *) info
{
    NSLog(@"%@",info);
    if (info.appIcon_middle) {
        [self.headView setImageWithURL:[NSURL fileURLWithPath:info.appIcon_middle] placeholderImage:[UIImage imageNamed:@"app_default.png"]];
    }else{
        [self.headView setImage:[UIImage imageNamed:@"app_default.png"]];
    }
    
    self.nameLabel.text = info.appName;
    self.appType.text = info.type;
    self.organizationLabel.text = info.describe;
    self.popularityLable.text = [NSString stringWithFormat:@"%d",info.popularity];
    if (info.isCollection) {
        [actionView setTitle:@"取消收藏" forState:0];
    } else {
        [actionView setTitle:@"收藏" forState:0];
    }
    
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:self stopAfterFirst:YES];

}
- (void)pushAppDetail
{
    if ([self.scrollViewDelegate respondsToSelector:@selector(pushAppDetailController:)]) {
        [self.scrollViewDelegate pushAppDetailController:self];
    }
}
- (void)mark:(id)sender
{
    if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(markApp:)]) {
        [self.scrollViewDelegate markApp:self];
    }
    
}


@end
