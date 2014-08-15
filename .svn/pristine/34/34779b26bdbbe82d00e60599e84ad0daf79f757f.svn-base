//
//  GroupViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "GroupViewController.h"
#import "NBNavigationController.h"
@interface GroupViewController ()
<NBNavigationControllerDelegate, UIScrollViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSInteger m_selectedSection;
    BOOL m_isOpened;
    BOOL m_firstOpen;
    BOOL m_secondOpen;
    
    UIView * m_bgView;
    
    UIScrollView * m_scrollView;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) UIScrollView * m_scrollView;
@property (nonatomic, strong) UIView * m_bgView;


@end

@implementation GroupViewController

@synthesize m_tableView;
@synthesize m_scrollView;
@synthesize m_bgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bbb) name:@"www" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    m_frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor orangeColor];
    [self createScrollView];
    [self createViewsOnScrollView];
    [self createNavigationBar:YES];
    self.m_bgView = [CommonBackGroudView getBackGroudView];
    [self.view addSubview:self.m_bgView];
    [self createLabel];
}

- (void)createLabel
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, m_frame.size.width - 40, 40)];
    label.backgroundColor = [UIColor redColor];
    [self.m_bgView addSubview:label];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"add" andRightBtnType:@"friendSwitch" andLeftTitle:@"好友" andRightTitle:@"群" andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    NSLog(@"leftButtonPressed in GroupViewController");
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    NSLog(@"button selected in GroupViewController == %d", button.selected);
    if (button.selected) {
        self.m_scrollView.contentOffset = CGPointMake(m_frame.size.width, 0);
    } else {
        self.m_scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];

}

- (void)createScrollView
{
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:m_frame];
    self.m_scrollView.delegate = self;
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width * 2, m_frame.size.height);
    [self.view addSubview:self.m_scrollView];
}

- (void)createViewsOnScrollView
{
    for (NSUInteger i = 0; i < 2; i++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0 + m_frame.size.width * i, 0, m_frame.size.width, m_frame.size.height)];
        
        UIColor * color = nil;
        if (i == 0) {
            color = [UIColor redColor];
        } else if (i == 1) {
            color = [UIColor greenColor];
        }
        view.backgroundColor = color;
        [self.m_scrollView addSubview:view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
//    if (scrollView.contentOffset.x <= 0.0f) {
//        [nav resetTitleAndSwitchButtonWithSelectedState:NO];
//    } else if (scrollView.contentOffset.x >= m_frame.size.width) {
//        [nav resetTitleAndSwitchButtonWithSelectedState:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
