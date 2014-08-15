//
//  AppContentController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppContentController.h"
#define HEIGHT 0

#import "JGExampleScrollableTableViewCell.h"

#import "JGScrollableTableViewCellAccessoryButton.h"

@interface AppContentController () <JGScrollableTableViewCellDelegate> {
    NSIndexPath *_openedIndexPath;
    //BOOL _left;
}

@end

@implementation AppContentController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavBar];
    //添加两个button
    [self customButton];

    [self initScrollView];
}
#pragma mark - setNavBar
- (void) setNavBar
{
    [self.navigationController  setNavigationBarHidden:NO animated:YES];
    
    //设置Navigation Bar颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(30/255.0) green:(175/255.0) blue:(200/255.0) alpha:1];
    UIButton *BackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 164.0, 45, 45)];
    [BackBtn setTitle:@"返回" forState:UIControlStateNormal];
	[BackBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:BackBtn];
	temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
	self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}
- (void) backAction
{
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - customButton

- (void)customButton
{
    self.schoolAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schoolAppButton setTitle:@"校园应用" forState:UIControlStateNormal];
    self.schoolAppButton.frame = CGRectMake(0, HEIGHT, 160, 38);
    self.schoolAppButton.backgroundColor = [UIColor grayColor];
    self.schoolAppButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.schoolAppButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//此时选中
    [self.schoolAppButton addTarget:self action:@selector(schoolAppButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.schoolAppButton];
    
    
    
    self.whistleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.whistleButton setTitle:@"微哨应用" forState:UIControlStateNormal];
    self.whistleButton.frame = CGRectMake(160, HEIGHT, 160, 38);
    self.whistleButton.backgroundColor = [UIColor grayColor];
    self.whistleButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.whistleButton setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    [self.whistleButton addTarget:self action:@selector(whistleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.whistleButton];
    
    //添加指示作用的lable
    self.slidLabel = [[UILabel alloc] init];
    self.slidLabel.frame = CGRectMake(0, HEIGHT+38, 160, 4);
    self.slidLabel.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.slidLabel];
    
    
}
#pragma mark - 初始化view
- (void) initScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,HEIGHT+38+4, 320, self.view.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    //关闭滚动
    self.scrollView.scrollEnabled = NO;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [self.view addSubview:self.scrollView];
    
    //公用
    currentPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor whiteColor];
    [self createAllEmptyPagesForScrollView];
    
    /*
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    _tableView.dataSource =self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    */
    //这里添加滑动视图
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
//    view.backgroundColor = [UIColor grayColor];
//    self.tableView.tableHeaderView = view;

}

- (void) createAllEmptyPagesForScrollView
{
    /*
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    _tableView.dataSource =self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    */
    
    //设置 tableScrollView 内部数据 UITableViewStyleGrouped
    _schoolAppTableView = [[UITableView alloc]initWithFrame:CGRectMake(320*0,HEIGHT, 320, self.scrollView.frame.size.height) style:UITableViewStylePlain ];
    _schoolAppTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_schoolAppTableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    
    _whistleAppTableView = [[UITableView alloc]initWithFrame:CGRectMake(320*1,HEIGHT, 320, self.scrollView.frame.size.height) style:UITableViewStylePlain ];
    _whistleAppTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_whistleAppTableView registerClass:[JGExampleScrollableTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    
    //设置tableView委托并添加进视图
    _schoolAppTableView.delegate = self;
    _schoolAppTableView.dataSource = self;
    [self.scrollView addSubview: _schoolAppTableView];
    _whistleAppTableView.delegate = self;
    _whistleAppTableView.dataSource = self;
    [self.scrollView addSubview: _whistleAppTableView];
    
    //设置 nibTableView 数据源数组 -- 仅仅用与测试
    couponArry = [[NSArray alloc]initWithObjects:@"coupon1",@"coupon2",@"coupon3", @"coupon4",nil ];
    groupbuyArry = [[NSArray alloc]initWithObjects:@"groupbuy1",@"groupbuy2",@"groupbuy3", nil ];

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    currentPage = page;
    pageControlUsed = NO;
    [self btnActionShow];
}
#pragma mark 界面按钮事件

- (void) btnActionShow
{
    if (currentPage == 0) {
        [self schoolAppButtonAction];
    }
    else{
        [self whistleButtonAction];
    }
}
- (void)schoolAppButtonAction
{
    [self.schoolAppButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//此时选中
    [self.schoolAppButton setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(0, HEIGHT+38, 160, 4);
    [self.scrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    [UIView commitAnimations];
}

- (void)whistleButtonAction
{
    [self.whistleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//此时选中
    [self.whistleButton setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(160, HEIGHT+38, 160, 4);
    [self.scrollView setContentOffset:CGPointMake(320*1, 0)];
    [UIView commitAnimations];
    
}

#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [_tableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"ScrollCell";
    
    JGExampleScrollableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //[cell setGrabberVisible:((indexPath.row % 3) == 0)];
    
    //[cell setOptionView:cell.optionView side:(_left ? JGScrollableTableViewCellSideLeft : JGScrollableTableViewCellSideRight)];
    
    cell.scrollDelegate = self;
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
