//
//  AboutOurViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-21.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AboutOurViewController.h"
#import "GetFrame.h"
#import "NBNavigationController.h"
#import "ImUtils.h"

#define LEFT_ITEM_TAG 2000

@interface AboutOurViewController ()
<UITextViewDelegate>
{
    UIScrollView * m_scrollView;
    CGRect m_frame;
    UITextView * m_textView;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    
    CGFloat m_contentHeight;
    CGFloat m_versionHeight;
}

@property (nonatomic, strong) UITextView * m_textView;
@property (nonatomic, strong) UIScrollView * m_scrollView;

@end

@implementation AboutOurViewController

@synthesize m_textView;
@synthesize m_scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setbasicCondition];
    [self createNavigationBar:YES];
    [self createScrollView];
    [self createDefaultImageView];
    [self createVersionLabel];
    [self createContentLabel];
    [self createCopyrightNotice];
}

- (void)setbasicCondition
{
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"关于" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createScrollView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        height = m_frame.size.height - 64;
    } else {
        height = m_frame.size.height - 44;
    }
    
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_scrollView.delegate = self;
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.showsVerticalScrollIndicator = NO;
    [self.m_scrollView setContentSize:CGSizeMake(m_frame.size.width, height)];
    [self.view addSubview:self.m_scrollView];
}

- (void)createDefaultImageView
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((m_frame.size.width - 143 / 2.0f) / 2.0f, 30, 143 / 2.0f, 70.0f)];
    imageView.image = [UIImage imageNamed:@"aboutDefaultImg.png"];
    [self.m_scrollView addSubview:imageView];
}

- (void)createVersionLabel
{
    UIFont * font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    UIColor * textColor = [ImUtils colorWithHexString:@"#262626"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
//    NSString *build = infoDictionary[(NSString*)kCFBundleNameKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleVersionKey];
    NSLog(@"bundleName == %@", bundleName);
    NSString * versionName = [NSString stringWithFormat:@"%@%@", @"微哨版本号为: ", bundleName];
    
    CGSize textSize = [versionName sizeWithFont:font constrainedToSize:CGSizeMake(290, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
    m_versionHeight = textSize.height;
    
    UILabel * versionLabel = [self createLabelWithFrame:CGRectMake(15, 130, m_frame.size.width - 30, m_versionHeight) andText:versionName andFont:font andTextColor:textColor];
    versionLabel.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:versionLabel];
}

- (void)createContentLabel
{
    UIFont * font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    UIColor * textColor = [ImUtils colorWithHexString:@"#262626"];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"about_me" ofType:@"txt"];
    NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"content == %@", content);
    content = [NSString stringWithFormat:@"        %@", content];

    CGSize textSize = [content sizeWithFont:font constrainedToSize:CGSizeMake(290, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
    m_contentHeight = textSize.height;
    
    UILabel * contentLabel = [self createLabelWithFrame:CGRectMake(15, 130 + m_versionHeight + 15, m_frame.size.width - 30, textSize.height) andText:content andFont:font andTextColor:textColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:contentLabel];
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, 165 + textSize.height);
}

- (void)createCopyrightNotice
{
    UIFont * font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    UIColor * textColor = [ImUtils colorWithHexString:@"#808080"];
    
    NSString * year = @"锐捷网络 版权所有（2007-2014)";
    CGSize textSize = [year sizeWithFont:font constrainedToSize:CGSizeMake(290, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
    CGFloat yearHeight = textSize.height;
    
    CGFloat yearY = 130 + m_versionHeight + 15 + m_contentHeight + 62;
    UILabel * yearLabel = [self createLabelWithFrame:CGRectMake(15, yearY, m_frame.size.width - 30, yearHeight) andText:@"锐捷网络 版权所有（2007-2014）" andFont:font andTextColor:textColor];
    yearLabel.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:yearLabel];
    
    CGFloat copyRightY = yearY + yearHeight + 6;
    UILabel * copyRightLabel = [self createLabelWithFrame:CGRectMake(15, copyRightY, m_frame.size.width - 30, yearHeight) andText:@"Copyright 2013. All Right Reserved." andFont:font andTextColor:textColor];
    copyRightLabel.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:copyRightLabel];

    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, 130 + m_versionHeight + 15 + m_contentHeight + 62 + yearHeight * 2 + 30);
}

- (UILabel *)createLabelWithFrame:(CGRect)frame andText:(NSString *)text andFont:(UIFont *)font andTextColor:(UIColor *)color
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
