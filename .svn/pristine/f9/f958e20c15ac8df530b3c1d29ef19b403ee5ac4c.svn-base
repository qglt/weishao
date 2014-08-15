//
//  AppContentController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppContentController.h"
#import "CustomScrollTableViewCell.h"
#import "JGScrollableTableViewCellAccessoryButton.h"
#import "SVWebViewController.h"
#import "HeaderScrollView.h"
#import "AppDetailController.h"
#import "AppCommentController.h"
#import "AppManager.h"
#import "WebAppInfo.h"
#import "LightAppInfo.h"
#import "NativeAppInfo.h"
#import "ImUtils.h"
#import "NBNavigationController.h"
#import "AppSearchViewController.h"
#import "PrivateTalkViewController.h"
#import "MJRefreshFooterView.h"
#import "CycleScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define BUTTON_HEIGHT 37
#define LINE_HEIGHT 3
#define HEIGHT 0

@interface AppContentController () <JGScrollableTableViewCellDelegate,AppCenterDelegate,MJRefreshBaseViewDelegate,CycleScrollViewDelegate> {
    NSIndexPath *_openedIndexPath;
    MJRefreshFooterView *_footer;
    MJRefreshFooterView *_footer2;
    NSInteger intergerOffset;
    NSInteger i;
    NSInteger j;
    NSInteger whistleOffset;
    BOOL isRefreshCampusData;
    BOOL isRefreshWhistleData;
    BOOL isTable;
    NSIndexPath *_indexPath;
}
@property (nonatomic, strong) NSMutableArray *campusDataArray;
@property (nonatomic, strong) NSMutableArray *whistelDataArray;
@property (nonatomic, strong) AppCenterViewController *centerVC;

@end

@implementation AppContentController
- (void)changeTheme:(NSNotification *)notification
{
//    [self createNavigationBar:NO];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    isTable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    self.slideImages = [[NSMutableArray alloc] initWithCapacity:1];

    

//    [self createNavigationBar:YES];
    [[AppManager shareInstance] addListener:self];
    [[AppManager shareInstance] getCampusApp:0 count:20 callback:^(BOOL isRefresh) {
        isRefreshCampusData = isRefresh;
        
    }];
    [[AppManager shareInstance] getWhistleApp:0 count:20 callback:^(BOOL isRefresh) {
        isRefreshWhistleData = isRefresh;
        
    }];
    [[AppManager shareInstance] getAppCycleImage];
    [[AppManager shareInstance] getCloudAppCycleImage];

    
    [self setNavBar];
    //添加两个button
    [self customButton];
    [self initScrollView];
 
    self.view.backgroundColor = [UIColor whiteColor];
    [self refresh];
}

#pragma mark - refresh
- (void)refresh
{
    _footer = [MJRefreshFooterView footer];
    _footer.delegate = self;
    _footer.scrollView = _schoolAppTableView;
    i = 1;
    intergerOffset = 21;
    
    _footer2 = [MJRefreshFooterView footer];
    _footer2.delegate = self;
    _footer2.scrollView = _whistleAppTableView;
    j = 1;
    whistleOffset = 21;
}
- (void)dealloc
{
    [_footer free];
    [_footer2 free];
}
#pragma mark - 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"%@----开始进入刷新状态", refreshView.class);
    NSLog(@"isRefreshCampusData = %d",isRefreshCampusData);

    if (isTable) {
        if (isRefreshCampusData) {
            NSLog(@"开始进入刷新状态");
            [self getData];
            
            
        } else {
            NSLog(@"停止刷新");
            [refreshView endRefreshing];
            return;
        }

    } else {
        if (isRefreshWhistleData) {
            [self getWhistelData];
        } else {
            [refreshView endRefreshing];
            return;
        }

    }
    
    
    
    
    [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];


}
- (void)getWhistelData
{
    j++;
    [[AppManager shareInstance] getWhistleApp:whistleOffset*j-(j-1) count:20 callback:^(BOOL isRefresh) {
        isRefreshWhistleData = isRefresh;
        
    }];
    
}
- (void)getData
{
    i++;
    NSLog(@"i = %d,起始值　＝　 %d",i, intergerOffset*i-(i-1));
    [[AppManager shareInstance] getCampusApp:intergerOffset*i-(i-1) count:20 callback:^(BOOL isRefresh) {
        isRefreshCampusData = isRefresh;
    }];

}
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [_schoolAppTableView reloadData];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"search" andLeftTitle:@"应用中心" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

//- (void)leftNavigationBarButtonPressed:(UIButton *)button
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self createNavigationBar:NO];
//}

#pragma mark - AppCenterDelegate
- (void) getCampusAppListFinish:(NSArray *)list total:(NSInteger)total{
    
    self.campusDataArray = [NSMutableArray arrayWithArray:list];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_schoolAppTableView reloadData];
    });
}
- (void) campusAppListChanged:(NSArray *)list
{
    self.campusDataArray = [NSMutableArray arrayWithArray:list];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_schoolAppTableView reloadData];
    });

}
- (void) getCampusAppListFailure{
    
}
- (void) getWhistleAppListFinsih:(NSArray *)list total:(NSInteger)total
{
    self.whistelDataArray = [NSMutableArray arrayWithArray:list];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_whistleAppTableView reloadData];
    });

}
- (void) whsitleAppListChanged:(NSArray*) list
{
    self.whistelDataArray = [NSMutableArray arrayWithArray:list];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_whistleAppTableView reloadData];
    });

}
- (void) getWhistleAppListFailure
{
    
}

//轮转图片更新事件
- (void) getCycleImageFinish:(NSArray*) list total:(NSInteger) total
{
    NSLog(@"list = %d",[list count]);
    dispatch_async(dispatch_get_main_queue(), ^{
        //将list数组作为参数传到相应的方法里
        //每次都先清掉之前的数据，再重新加载新数据
        [self setupViews:list];
    });
}
- (void) cycleImageListChange:(NSArray*) list
{

    dispatch_async(dispatch_get_main_queue(), ^{
        //将list数组作为参数传到相应的方法里
        //每次都先清掉之前的数据，再重新加载新数据
//        [_headerView addImagesToScrollView:list];
        [self setupViews:list];
    });
}
- (void) getCycleImageFailure
{
    
}
- (void) setupViews:(NSArray *)array
{
    NSMutableArray *viewsArray = [NSMutableArray array];
    
    for (BaseAppInfo *info in array) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 130.0)];
        info.recommend_icon?[img setImageWithURL:[NSURL fileURLWithPath:info.recommend_icon] placeholderImage:[UIImage imageNamed:@"app_center_default.png"]]:[img setImage:[UIImage imageNamed:@"app_center_default.png"]];
        
        [viewsArray addObject:img];
    }
    
    CycleScrollView *mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 130) animationDuration:2];
    mainScorllView.cycleDelegate = self;
    mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    mainScorllView.totalPagesCount = ^NSInteger(void){
        return viewsArray.count;
    };
    mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
    };
    _schoolAppTableView.tableHeaderView = mainScorllView;
}
- (void) getCloudAppCycleImageFinish:(NSArray *)list total:(NSInteger)total
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupCloudCycleView:list];
    });
}

- (void) cloudAppCycleImageListChange:(NSArray *)list
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupCloudCycleView:list];
    });
}

- (void) getCloudAppCycleImageFailure
{
    
}

- (void) setupCloudCycleView:(NSArray *)array
{
    NSMutableArray *viewsArray = [NSMutableArray array];
    
    for (BaseAppInfo *info in array) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 130.0)];
        info.recommend_icon?[img setImageWithURL:[NSURL fileURLWithPath:info.recommend_icon] placeholderImage:[UIImage imageNamed:@"app_center_default.png"]]:[img setImage:[UIImage imageNamed:@"app_center_default.png"]];
        
        [viewsArray addObject:img];
    }
    
    CycleScrollView *whistleCycleView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 130) animationDuration:2];
    whistleCycleView.cycleDelegate = self;
    whistleCycleView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return viewsArray[pageIndex];
    };
    whistleCycleView.totalPagesCount = ^NSInteger(void){
        return viewsArray.count;
    };
    whistleCycleView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
    };

    _whistleAppTableView.tableHeaderView = whistleCycleView;
    
}

- (void)iconPushToDetailVC:(UITapGestureRecognizer *)tag
{
//    CATransition *animation = [CATransition animation];
//    
//    [animation setDuration:0.3];
//    
//    [animation setType: kCATransitionPush];
//    
//    [animation setSubtype: kCATransitionFromTop];
//    
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];

    
    
//    BaseAppInfo *info = [infoArray objectAtIndex:tag];
//    AppDetailController *detailVC = [[AppDetailController alloc] init];
//    //获得详情的方法在详情控制器里面，相应的代理接受亦在详情控制器里面
//    detailVC.info = info;
//    [detailVC setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:detailVC animated:YES];
    
    
//    [self.navigationController.view.layer addAnimation:animation forKey:Nil];
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
    
    //加上应用中心搜索Button
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(320-45-10, 164.0, 45, 45)];
    [searchButton setTitle:@"搜索" forState:0];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    searchBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    

    //标题栏
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    //加粗
    title.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    title.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"应用中心";
    self.navigationItem.titleView = title;
}
- (void) backAction
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) searchAction
{
    AppSearchViewController *searchVC = [[AppSearchViewController alloc] init];
    [searchVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:searchVC animated:YES];
}
#pragma mark - customButton

- (void)customButton
{
    self.schoolAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.schoolAppButton setTitle:@"校园应用" forState:UIControlStateNormal];
    self.schoolAppButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    [self.schoolAppButton setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:0];
    self.schoolAppButton.frame = CGRectMake(0, HEIGHT, 160, BUTTON_HEIGHT);
    self.schoolAppButton.backgroundColor = [ImUtils colorWithHexString:@"#f6f6f6"];
    self.schoolAppButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.schoolAppButton addTarget:self action:@selector(schoolAppButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.schoolAppButton];
    
    
    
    self.whistleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.whistleButton setTitle:@"微哨应用" forState:UIControlStateNormal];
    self.whistleButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    [self.whistleButton setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:0];
    self.whistleButton.frame = CGRectMake(160, HEIGHT, 160, BUTTON_HEIGHT);
    self.whistleButton.backgroundColor = [ImUtils colorWithHexString:@"#f6f6f6"];
    self.whistleButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.whistleButton addTarget:self action:@selector(whistleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.whistleButton];
    
    //添加指示作用的lable
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, BUTTON_HEIGHT, 320, LINE_HEIGHT)];
    lineLabel.backgroundColor = [ImUtils colorWithHexString:@"#bad4ed"];
    [self.view addSubview:lineLabel];
    self.slidLabel = [[UILabel alloc] init];
    self.slidLabel.frame = CGRectMake(0, BUTTON_HEIGHT, 160, LINE_HEIGHT);
    self.slidLabel.backgroundColor = [ImUtils colorWithHexString:@"#2f87b9"];
    [self.view addSubview:self.slidLabel];
    
    
}
#pragma mark - 初始化view
- (void) initScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,BUTTON_HEIGHT+LINE_HEIGHT, 320, self.view.frame.size.height)];
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
    pageControl.backgroundColor = [UIColor grayColor];
    [self createAllEmptyPagesForScrollView];

}
#pragma mark －初始化两个UITableView
- (void) createAllEmptyPagesForScrollView
{
    
    //设置 tableScrollView 内部数据 UITableViewStyleGrouped
    _schoolAppTableView = [[UITableView alloc]initWithFrame:CGRectMake(320*0,HEIGHT, 320, self.scrollView.frame.size.height-64-BUTTON_HEIGHT-LINE_HEIGHT) style:UITableViewStylePlain ];
    _schoolAppTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_schoolAppTableView registerClass:[CustomScrollTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    _schoolAppTableView.tag = 1000;
//    [self createHeaderScrollView:_schoolAppTableView];
    
    _whistleAppTableView = [[UITableView alloc]initWithFrame:CGRectMake(320*1,HEIGHT, 320, self.scrollView.frame.size.height-64-BUTTON_HEIGHT-LINE_HEIGHT) style:UITableViewStylePlain ];
    _whistleAppTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_whistleAppTableView registerClass:[CustomScrollTableViewCell class] forCellReuseIdentifier:@"ScrollCell"];
    _whistleAppTableView.tag = 2000;
//    [self createHeaderScrollView:_whistleAppTableView] ;
    
    //设置tableView委托并添加进视图
    _schoolAppTableView.delegate = self;
    _schoolAppTableView.dataSource = self;
    [self.scrollView addSubview: _schoolAppTableView];
    _whistleAppTableView.delegate = self;
    _whistleAppTableView.dataSource = self;
    [self.scrollView addSubview: _whistleAppTableView];
    

    _schoolAppTableView.bounces = YES;
    _whistleAppTableView.bounces = YES;
}
#pragma mark －　添加UITableView的tableHeaderView
- (void) createHeaderScrollView:(UITableView *)table
{
    [self.slideImages addObject:@"tmp.png"];
    _headerView = [[HeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)withImageArr:self.slideImages];
    _headerView.scrollViewDelegate = self;
    table.tableHeaderView = _headerView;
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
    isTable = YES;
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(0, BUTTON_HEIGHT, 160, LINE_HEIGHT);
    [self.scrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    [UIView commitAnimations];
}

- (void)whistleButtonAction
{
    isTable = NO;
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(160, BUTTON_HEIGHT, 160, LINE_HEIGHT);
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
        _openedIndexPath = [_whistleAppTableView indexPathForCell:cell];
        _openedIndexPath = [_schoolAppTableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(tableView == _schoolAppTableView)
        return [self.campusDataArray count];
    else
        return [self.whistelDataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"ScrollCell";
    
    CustomScrollTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomScrollTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    if (tableView == _schoolAppTableView) {
        //学校应用页面
        BaseAppInfo *info = [self.campusDataArray objectAtIndex:indexPath.row];
        
        [cell setupCell:info];
     } else {
        //微哨应用页面
        BaseAppInfo *info = [self.whistelDataArray objectAtIndex:indexPath.row];
        [cell setupCell:info];
     }

    cell.scrollDelegate = self;
    //push到详情的代理方法
    cell.scrollViewDelegate = self;
    
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected Index Path %@", indexPath);
    ///在弹出警告后自动取消选中表视图单元
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _schoolAppTableView) {
        //
        BaseAppInfo *info = [self.campusDataArray objectAtIndex:indexPath.row ];
        PrivateTalkViewController *vc = [PrivateTalkViewController new];
        vc.inputObject = info;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];

    } else {
        
        //
        BaseAppInfo *info = [self.whistelDataArray objectAtIndex:indexPath.row ];
        if ([info isWebApp]) {
            NSURL *URL = [NSURL URLWithString:info.url];
            SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:URL];
            [webVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:webVC animated:YES];
        } else if ([info isLightApp]) {
            PrivateTalkViewController *vc = [[PrivateTalkViewController alloc] init];
            vc.inputObject = info;
            [vc setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([info isNativeApp]) {
            
        }
    }
}

#pragma mark -

#pragma mark RootScrollViewDelegate
- (void) pushWebViewController
{
    SVWebViewController *webVC = [[SVWebViewController alloc] init];
    [webVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:webVC animated:YES];
    
    
}

- (void)pushAppDetailController:(id)object
{
    if (isTable) {
        CustomScrollTableViewCell *cell2 = (CustomScrollTableViewCell *)object;
        NSIndexPath *indexPath2 = [_schoolAppTableView indexPathForCell:cell2];
        BaseAppInfo *info = [self.campusDataArray objectAtIndex:indexPath2.row ];

        AppDetailController *detailVC = [[AppDetailController alloc] init];
        detailVC.info = info;
        detailVC.commentrayView.info = info;
        detailVC.introdutionView.info = info;
        [detailVC setHidesBottomBarWhenPushed:YES];
        _indexPath = indexPath2;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else{
        CustomScrollTableViewCell * cell = (CustomScrollTableViewCell *)object;
        NSIndexPath* indexPath3 = [_whistleAppTableView indexPathForCell:cell];
        
        BaseAppInfo *info = [self.whistelDataArray objectAtIndex:indexPath3.row ];
        AppDetailController *detailVC = [[AppDetailController alloc] init];
        detailVC.info = info;
        _indexPath = indexPath3;
        detailVC.commentrayView.info = info;
        detailVC.introdutionView.info = info;
        [detailVC setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}
- (void)markApp:(id)object
{
    if (_schoolAppTableView) {
        CustomScrollTableViewCell *cell = (CustomScrollTableViewCell *)object;
        NSIndexPath *indexPath = [_schoolAppTableView indexPathForCell:cell];
        BaseAppInfo *baseAppInfo = [self.campusDataArray objectAtIndex:indexPath.row];
        
        if (baseAppInfo.isCollection) {
            [[AppManager shareInstance] removeFromMyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setupCell:baseAppInfo];
                    });
                }
            }];
        } else {
            [[AppManager shareInstance] add2MyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setupCell:baseAppInfo];
                    });
                }
                
            }];
        }

    }else if (_whistleAppTableView)
    {
        CustomScrollTableViewCell *cell = (CustomScrollTableViewCell *)object;
        NSIndexPath *indexPath = [_whistleAppTableView indexPathForCell:cell];
        BaseAppInfo *baseAppInfo = [self.whistelDataArray objectAtIndex:indexPath.row];
        
        if (baseAppInfo.isCollection) {
            [[AppManager shareInstance] removeFromMyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setupCell:baseAppInfo];
                    });
                }
            }];
        } else {
            [[AppManager shareInstance] add2MyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell setupCell:baseAppInfo];
                    });
                }
                
            }];
        }

    }
    
    
}
/*
- (void)refreshCollect:(BaseAppInfo *)info
{
    NSLog(@"%@",_campusDataArray);
    if (isTable) {
        NSArray * indexArr = [NSArray arrayWithObjects:_indexPath, nil];
        [_campusDataArray replaceObjectAtIndex:_indexPath.row withObject:info];
        [_schoolAppTableView reloadRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        NSArray * indexArr = [NSArray arrayWithObjects:_indexPath, nil];
        [_whistelDataArray replaceObjectAtIndex:_indexPath.row withObject:info];
        [_whistleAppTableView reloadRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}*/
@end
