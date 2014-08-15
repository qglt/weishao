//
//  AppIntrodutionView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppIntrodutionView.h"
#import "CommonView.h"
#import "RatingControl.h"
#import "ImUtils.h"
@interface AppIntrodutionView()<PagedFlowViewDataSource,PagedFlowViewDelegate>

{
    
}

@end

@implementation AppIntrodutionView
@synthesize hFlowView;
@synthesize hPageControl;
@synthesize imageArray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentSize = CGSizeMake(320, 700);
        self.pagingEnabled = NO;
        self.userInteractionEnabled = YES;
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        [self initViews];
        [self initScrollView];
        [self initLable];
    }
    return self;
}
#pragma mark - 初始化应用简介
- (void)initViews
{
    self.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 85+39)];
    [self addSubview:view];
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = CGRectMake(15, 15, 55, 55);
    [_btn setImage:[UIImage imageNamed:@"app_name.png"] forState:0];
    [view addSubview:_btn];
    _lalel = [[UILabel alloc] init];
    _lalel.frame = CGRectMake(80, 15, 200, 15);
    _lalel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    _lalel.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [view addSubview:_lalel];
    
    _lable2 = [[UILabel alloc] init];
    _lable2.frame = CGRectMake(80, 33, 200, 15);
    _lable2.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    _lable2.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    [view addSubview:_lable2];
    
    _lable3 = [[UILabel alloc] init];
    _lable3.frame = CGRectMake(80, 45, 200, 15);
    _lable3.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    _lable3.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    [view addSubview:_lable3];
    
    
    
    UIImage *imag1 = [self reSizeImage:[UIImage imageNamed:@"empty_star.png"] toSize:CGSizeMake(12, 12)];
    UIImage *imag2 = [self reSizeImage:[UIImage imageNamed:@"solid_star.png"] toSize:CGSizeMake(12, 12)];
    RatingControl *ratingControl = [[RatingControl alloc] initWithLocation:CGPointMake(80, 50) emptyImage:imag1 solidImage:imag2 andMaxRating:5];
    [ratingControl setRating:3];
    ratingControl.frame = CGRectMake(80, 58, 72, 100);
    [view addSubview:ratingControl];
    
    
   
    
    _downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downLoadBtn setTitleColor:[UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0] forState:0];
    _downLoadBtn.tag = 2000;
    _downLoadBtn.frame = CGRectMake(0, 85, 160, 39);
    [_downLoadBtn setImage:[UIImage imageNamed:nil] forState:0];
    _downLoadBtn.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [_downLoadBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_downLoadBtn];
    
    _markBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_markBtn setTitleColor:[UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0] forState:0];
    _markBtn.tag = 3000;
    _markBtn.frame = CGRectMake(160, 85, 160, 39);
    [_markBtn setImage:[UIImage imageNamed:nil] forState:0];
    _markBtn.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    [_markBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_markBtn];
    

    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, 320, 1)];
    lineLabel.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0];
    [view addSubview:lineLabel];

    UILabel *lineLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 85+39, 320, 1)];
    lineLabel3.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0];
    [view addSubview:lineLabel3];
    
    UILabel *lineLable2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 85, 1, 39)];
    lineLable2.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0];
    [view addSubview:lineLable2];

    
    
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


- (void)btnAction:(UIButton *)sender
{
    if (sender.tag == 1000) {
        return;
    } else if (sender.tag == 2000){
        if (self.appIntrodutionDelegate && [self.appIntrodutionDelegate respondsToSelector:@selector(downLoad:)]) {
            [self.appIntrodutionDelegate downLoad:self.info];
        }
    }else if (sender.tag == 3000){
        if (self.appIntrodutionDelegate && [self.appIntrodutionDelegate respondsToSelector:@selector(collect:)]) {
            [self.appIntrodutionDelegate collect:self.info];
        }
    }
}
#pragma mark - initScrollView
- (void)initScrollView
{
    

    hFlowView = [[PagedFlowView alloc] initWithFrame:CGRectMake(15, 124, 300, 296)];
    
    hFlowView.delegate = self;
    hFlowView.dataSource = self;
    hFlowView.pageControl = hPageControl;
    hFlowView.minimumPageAlpha = 0.3;
    hFlowView.minimumPageScale = 0.9;
    [self addSubview:hFlowView];
}
- (void)initLable
{
    UILabel *lab1 = [[UILabel alloc] init];
    lab1.frame = CGRectMake(15, 380+10+30, 120, 15);
    [lab1 setText:@"版本号:"];
    lab1.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lab1.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab1];
    self.versionLable = [[UILabel alloc] init];
    self.versionLable.frame = CGRectMake(80, 390+30, 100, 15);
    self.versionLable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.versionLable.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.versionLable];
    
    UILabel *lab2 = [[UILabel alloc] init];
    lab2.frame = CGRectMake(15, 380+10+20+30, 120, 15);
    [lab2 setText:@"开发者:"];
    lab2.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lab2.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab2];
    self.organisationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 410+30, 120, 15)];
    self.organisationNameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.organisationNameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.organisationNameLabel];
    
    UILabel *lab3 = [[UILabel alloc] init];
    lab3.frame = CGRectMake(15, 380+10+40+30, 120, 15);
    [lab3 setText:@"组织:"];
    lab3.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lab3.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab3];
    self.organisationLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 430+30, 200, 15)];
    self.organisationLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.organisationLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.organisationLabel];
    
    UILabel *lab4 = [[UILabel alloc] init];
    lab4.frame = CGRectMake(15, 380+10+60+30, 120, 15);
    [lab4 setText:@"人气:"];
    lab4.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lab4.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab4];
    self.popularityLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 450+30, 120, 15)];
    self.popularityLable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.popularityLable.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.popularityLable];
    
    UILabel *lab5 = [[UILabel alloc] init];
    lab5.frame = CGRectMake(15, 380+10+80+30, 120, 15);
    [lab5 setText:@"更新:"];
    lab5.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lab5.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab5];
    self.updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 470+30, 120, 15)];
    self.updateLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    self.updateLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:self.updateLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 489+30, 320, 1)];
    lineLabel.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0];
    [self addSubview:lineLabel];
    
    
    UILabel *lab6 = [[UILabel alloc] init];
    lab6.frame = CGRectMake(15, 380+10+100+10+30, 120, 15);
    [lab6 setText:@"应用简介"];
    lab6.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    lab6.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self addSubview:lab6];
    
    self.summaryLable = [[UILabel alloc] init];
    self.summaryLable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    CGSize maximumSize =CGSizeMake(300,9999);
    NSString*dateString =@"The date today is January 1st, 1999";
    UIFont*dateFont =[UIFont fontWithName:@"STHeitiSC-Thin" size:12.0];
    self.summaryLable.textColor = [ImUtils colorWithHexString:@"#262626"];
    CGSize dateStringSize =[dateString sizeWithFont:dateFont
                                  constrainedToSize:maximumSize
                                      lineBreakMode:self.summaryLable.lineBreakMode];
    CGRect dateFrame =CGRectMake(15,500+25+30,320-50, dateStringSize.height);
    self.summaryLable.numberOfLines = 0;
    self.summaryLable.frame = dateFrame;
    
    
    [self addSubview:self.summaryLable];

}

#pragma mark -
#pragma mark PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return CGSizeMake(150, 266);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"Scrolled to page # %d", index);
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    NSLog(@"Tapped on page # %d", index);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView Datasource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return [imageArray count];
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    
    UIImageView *imageView = (UIImageView *)[flowView dequeueReusableCell];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
    }
    imageView.image = [UIImage imageWithContentsOfFile:[imageArray objectAtIndex:index]];
//    imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:index]];
    return imageView;
}

- (void)pageControlValueDidChange:(id)sender {
    UIPageControl *pageControl = sender;
    [hFlowView scrollToPage:pageControl.currentPage];
}

@end
