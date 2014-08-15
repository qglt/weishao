//
//  WelcomeViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ImageUtil.h"
#import "WhistlePageController.h"
#import "LoginViewController.h"
#import "GetFrame.h"

#define IMAGES_NUMBERS 3

@interface WelcomeViewController ()
<UIScrollViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    UIScrollView * m_scrollView;
    WhistlePageController * m_pageControl;
}

@property (nonatomic, strong) UIScrollView * m_scrollView;
@property (nonatomic, strong) WhistlePageController * m_pageControl;

@end

@implementation WelcomeViewController

@synthesize m_scrollView;

@synthesize m_pageControl;

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
    [self setBasicConditions];
    [self createScrollView];
    [self createViewsOnScrollView];
//    [self getPageControl];
}

- (void)setBasicConditions
{
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)getPageControl
{
    CGFloat width = 148;
    CGFloat height = 24;
    CGFloat y = 0.0f;
    if (isIOS7) {
        y = 92.f;
    } else {
        y = 56.0f;
    }
   
    self.m_pageControl = [[WhistlePageController alloc] initWithFrame:CGRectMake((m_frame.size.width - width) / 2, m_frame.size.height - y, width, height)];
    self.m_pageControl.numberOfPages = IMAGES_NUMBERS;
    self.m_pageControl.currentPage = 0;
    [self.view addSubview:self.m_pageControl];
}

- (void)createScrollView
{
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:m_frame];
    self.m_scrollView.delegate = self;
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.bounces = NO;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.showsVerticalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width * IMAGES_NUMBERS, m_frame.size.height);
    [self.view addSubview:self.m_scrollView];
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= m_frame.size.width * (IMAGES_NUMBERS - 1)) {
        [self startButtonPressed:nil];
    }
}

- (void)createViewsOnScrollView
{
    NSArray * imageArr = [[NSArray alloc] initWithObjects:@"guide_1.png", @"guide_2.png", @"guide_3.png",nil];
    for (NSUInteger i = 0; i < IMAGES_NUMBERS; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 + m_frame.size.width * i, 0, m_frame.size.width, m_frame.size.height)];
        imageView.userInteractionEnabled = YES;
//        if (i == IMAGES_NUMBERS - 1) {
//            UISwipeGestureRecognizer *recognizer;
//            recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(startButtonPressed:)];
//            [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//            [imageView addGestureRecognizer:recognizer];
//            imageView.userInteractionEnabled = NO;
//        }
        imageView.image = [ImageUtil getImageByImageNamed:[imageArr objectAtIndex:i] Consider:YES];
        [self.m_scrollView addSubview:imageView];
    }
}

- (UIButton *)createStartButton
{
    CGFloat y = 0.0f;
    if (is4Inch) {
        y = m_frame.size.height - 132 - 66;
    } else {
        y = m_frame.size.height - 106 - 66;
    }
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(70, y, m_frame.size.width - 140.0f, 66.0f);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)startButtonPressed:(id)sender
{
    [self.navigationController pushViewController:[LoginViewController shareInstance] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
