//
//  AppDetailController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppDetailController.h"
#import "AppIntrodutionView.h"
#import "CommentaryView.h"
#import "AppCommentController.h"
#import "AppManager.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "NativeAppInfo.h"
#import "PrivateTalkViewController.h"
#import "SVWebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#define HEIGHT 0
#define BUTTON_HEIGHT 38
#define LINE_HEIGHT 2
@interface AppDetailController ()<AppCenterDelegate,AppIntrodutionViewDelegate>
{
}
@end

@implementation AppDetailController
- (void)changeTheme:(NSNotification *)notification
{
//    [self createNavigationBar:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self createNavigationBar:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    [[AppManager shareInstance] addListener:self];
    [[AppManager shareInstance] getAppDetailInfo:self.info];
    [[AppManager shareInstance] getAppComment:self.info offset:0 count:20];

    
    [self setNavBar];
    [self customButton];
    [self initScrollView];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:@"back" andLeftTitle:@"应用详情" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self createNavigationBar:NO];
//}
//
//- (void)leftNavigationBarButtonPressed:(UIButton *)button
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark -AppCenterDelegate
- (void) getAppDetailFinish:(BaseAppInfo*) info
{
    [self refreshData:info];
}

- (void) getAppDetailFailure
{
    
}
- (void) appDetailInfoChanged:(BaseAppInfo*) info
{
    [self refreshData:info];
}

- (void) getAppComments:(BaseAppInfo *)app
{
    //代理方法里接受到评论的数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshComments:app];
    });
}

- (void) appCommentsChanged:(BaseAppInfo *)app
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshComments:app];
    });
}
- (void) refreshComments:(BaseAppInfo *)info
{
    //代理方法接收到评论数据后应该将值赋到commentrayView里，push到控制里需要评论的数据
    self.commentrayView.info = info;
    //评论页面此处赋值，别的地方不要赋值，这里要特别注意
    AppCommentInfo *commentInfo = info.comment;

    self.info = info;
 
    
    if (commentInfo.comment_total == 0) {
        _commentrayView.fiveStarLabel.text = @"0";
        _commentrayView.fourStarLabel.text = @"0";
        _commentrayView.threeStarLabel.text = @"0";
        _commentrayView.twoStarLabel.text = @"0";
        _commentrayView.oneStarLabel.text = @"0";
    }else
    {
        _commentrayView.fiveStarView.progress = commentInfo.scroe_5 * 1.0 /commentInfo.comment_total;
        _commentrayView.fourStarView.progress = commentInfo.scroe_4* 1.0 /commentInfo.comment_total;
        _commentrayView.threeStarView.progress = commentInfo.scroe_3* 1.0 /commentInfo.comment_total;
        _commentrayView.twoStarView.progress = commentInfo.scroe_2* 1.0 /commentInfo.comment_total;
        _commentrayView.oneStarView.progress = commentInfo.scroe_1* 1.0 /commentInfo.comment_total;
        _commentrayView.fiveStarLabel.text = [NSString stringWithFormat:@"%d",commentInfo.comment_total];
        _commentrayView.fourStarLabel.text = [NSString stringWithFormat:@"%d",commentInfo.comment_total];
        _commentrayView.threeStarLabel.text = [NSString stringWithFormat:@"%d",commentInfo.comment_total];
        _commentrayView.twoStarLabel.text = [NSString stringWithFormat:@"%d",commentInfo.comment_total];
        _commentrayView.oneStarLabel.text = [NSString stringWithFormat:@"%d",commentInfo.comment_total];
    }
    _commentrayView.scrorcLabel.text = [NSString stringWithFormat:@"%d",commentInfo.average];
    NSMutableArray *commentInfoArray = [NSMutableArray arrayWithArray:commentInfo.comments];
    _commentrayView.infoArray = commentInfoArray;
    [_commentrayView reloadData];
    

}
- (void)refreshData:(BaseAppInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.introdutionView.info = info;
        self.commentrayView.info = info;
        self.commentrayView.info = info;
        UIImageView *appImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        appImage.layer.masksToBounds = YES;
        appImage.layer.cornerRadius = 10.0f;
        if (self.info.appIcon_middle) {
            [appImage setImageWithURL:[NSURL fileURLWithPath:self.info.appIcon_middle]];
        }
        [_introdutionView.btn addSubview:appImage];
        
        _introdutionView.lalel.text = info.appName;
        _introdutionView.lable2.text = info.type;
        _introdutionView.lable3.text = info.developer_name;
        if (info.isCollection) {
            [_introdutionView.markBtn setTitle:@"取消收藏" forState:0];
        } else {
            [_introdutionView.markBtn setTitle:@"收藏" forState:0];
        }
        if ([info isNativeApp]) {
            [_introdutionView.downLoadBtn setTitle:@"下载" forState:0];
        } else {
            [_introdutionView.downLoadBtn setTitle:@"打开" forState:0];
        }
        //传递介绍应用的图片
        _introdutionView.imageArray = info.screenshot;
        [_introdutionView.hFlowView reloadData];
        
        if ([info isNativeApp]) {
            _introdutionView.versionLable.text = ((NativeAppInfo *)info).version;

        }else
        {
            _introdutionView.versionLable.text = @"最新版本";
        }
        _introdutionView.organisationNameLabel.text = info.developer_name;
        _introdutionView.organisationLabel.text = info.developer_organization;
        _introdutionView.popularityLable.text = [NSString stringWithFormat:@"%d",info.popularity];
        _introdutionView.updateLabel.text = info.modifyTime;
        _introdutionView.summaryLable.text = info.describe;
    });

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
    
    //标题栏
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    //加粗
    title.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    title.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"应用详情";
    self.navigationItem.titleView = title;
}
- (void) backAction
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - customButton

- (void)customButton
{
    self.IntroductionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.IntroductionButton setTitle:@"应用介绍" forState:UIControlStateNormal];
    self.IntroductionButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    self.IntroductionButton.frame = CGRectMake(0, HEIGHT, 160, 38);
    self.IntroductionButton.backgroundColor = [ImUtils colorWithHexString:@"#f6f6f6"];
    self.IntroductionButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.IntroductionButton setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:UIControlStateNormal];//此时选中
    [self.IntroductionButton addTarget:self action:@selector(introductionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.IntroductionButton];
    
    self.commentaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentaryButton setTitle:@"用户评论" forState:UIControlStateNormal];
    self.commentaryButton.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.commentaryButton.frame = CGRectMake(160, HEIGHT, 160, 38);
    self.commentaryButton.backgroundColor = [ImUtils colorWithHexString:@"#f6f6f6"];
    self.commentaryButton.showsTouchWhenHighlighted = YES;  //指定按钮被按下时发光
    [self.commentaryButton setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:UIControlStateNormal];//此时未被选中
    [self.commentaryButton addTarget:self action:@selector(commentaryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commentaryButton];
    
    //添加指示作用的lable
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, BUTTON_HEIGHT, 320, LINE_HEIGHT)];
    lineLabel.backgroundColor = [ImUtils colorWithHexString:@"#bad4ed"];
    [self.view addSubview:lineLabel];
    self.slidLabel = [[UILabel alloc] init];
    self.slidLabel.frame = CGRectMake(0, BUTTON_HEIGHT, 160, LINE_HEIGHT);
    self.slidLabel.backgroundColor = [ImUtils colorWithHexString:@"#2f87b9"];
    [self.view addSubview:self.slidLabel];
    
}
#pragma mark - 初始化滑动视图
- (void) initScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,HEIGHT+38+2, 320, self.view.frame.size.height)];
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
    [self createEmptyView];
}
- (void) createEmptyView
{
    //此处初始化view后赋值　数据不完整
    _introdutionView = [[AppIntrodutionView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height-64-40)];
    _introdutionView.appIntrodutionDelegate = self;
    UIImageView *appImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    appImage.layer.masksToBounds = YES;
    appImage.layer.cornerRadius = 10.0f;
    if (self.info.appIcon_middle) {
       [appImage setImageWithURL:[NSURL fileURLWithPath:self.info.appIcon_middle]];
    }
    [_introdutionView.btn addSubview:appImage];
    [self.scrollView addSubview:_introdutionView];
    
    self.commentrayView = [[CommentaryView alloc] initWithFrame:CGRectMake(320, 0, 320, self.scrollView.frame.size.height-64-40)];
    self.commentrayView.scrollViewDelegate = self;
    [self.scrollView addSubview:self.commentrayView];
    
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
        [self introductionButtonAction];
    }
    else{
        [self commentaryButtonAction];
    }
}
- (void)introductionButtonAction
{
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(0, HEIGHT+38, 160, 2);
    [self.scrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    [UIView commitAnimations];
}

- (void)commentaryButtonAction
{
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    self.slidLabel.frame = CGRectMake(160, HEIGHT+38, 160, 2);
    [self.scrollView setContentOffset:CGPointMake(320*1, 0)];
    [UIView commitAnimations];
    
}
#pragma mark - 评论页面
- (void) pushCommentController
{
    AppCommentController *commentVC = [[AppCommentController alloc] init];
    NSLog(@"isCommented = %d",self.info.comment.isCommented);
    commentVC.info = self.info;
    [commentVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark - AppIntrodutionViewDelegate

- (void) downLoad:(BaseAppInfo *)info
{
    NSLog(@"downLoad");
    if ([info isLightApp]) {
        //
        PrivateTalkViewController *vc = [PrivateTalkViewController new];
        vc.inputObject = info;
        [vc setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([info isNativeApp])
    {
        //启动本地应用
    } else if ([info isWebApp])
    {
        NSURL *URL = [NSURL URLWithString:info.url];
        SVWebViewController *webVC = [[SVWebViewController alloc] initWithURL:URL];
        [webVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void) collect:(BaseAppInfo *)info
{
    if (info.isCollection) {
        [[AppManager shareInstance] removeFromMyCollectApp:info callback:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [cell setupCell:baseAppInfo];
                    [_introdutionView.markBtn setTitle:@"收藏" forState:0];
//                    [collectDelegate removeCollect:info];
                
                });
            }
        }];
    } else {
        [[AppManager shareInstance] add2MyCollectApp:info callback:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [cell setupCell:baseAppInfo];
                    [_introdutionView.markBtn setTitle:@"取消收藏" forState:0];
//                    [collectDelegate addCollect:info];
                });
            }
            
        }];
    }

}
@end
