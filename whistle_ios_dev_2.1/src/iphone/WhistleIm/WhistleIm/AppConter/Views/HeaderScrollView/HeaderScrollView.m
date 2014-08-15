//
//  HeaderScrollView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-9.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "HeaderScrollView.h"

#define BUTTON_HEIGHT 37
#define LINE_HEIGHT 3
#define HEIGHT 0

@interface HeaderScrollView ()
<UIScrollViewDelegate>
{
    CGRect m_frame;
    UIScrollView * m_scrollView;
    UIPageControl * m_pageControl;
    NSTimer * m_timer;
}

@property (nonatomic, strong) UIScrollView * m_scrollView;
@property (nonatomic, strong) UIPageControl * m_pageControl;
@property (nonatomic, strong) NSTimer * m_timer;

@end
@implementation HeaderScrollView
@synthesize m_scrollView;
@synthesize m_pageControl;
@synthesize m_slideImages;
@synthesize m_timer;
- (id)initWithFrame:(CGRect)frame withImageArr:(NSMutableArray *)imageArr
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        m_frame = frame;
        self.m_slideImages = [[NSMutableArray alloc] initWithCapacity:1];
        self.m_slideImages = imageArr;
        [self createPageControl];
        [self createScrollViews];
        [self addImagesToScrollView];
        
        //[self performSelector:@selector(startTimer) withObject:nil afterDelay:5.0f];
    }
    return self;
}

- (void)startTimer
{
    self.m_timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    [self.m_timer fire];
}

- (void)turnPage
{
    int page = m_pageControl.currentPage; // 获取当前的page
    [self.m_scrollView scrollRectToVisible:CGRectMake(m_frame.size.width * (page + 1), 0, m_frame.size.width, m_frame.size.height - 20) animated:NO]; // 触摸pagecontroller那个点点 往后翻一页 +1
    
    NSLog(@"timer page == %d", page);
}

- (void)runTimePage
{
    int page = m_pageControl.currentPage; // 获取当前的page
    page++;
    page = page > [self.m_slideImages count] - 1 ? 0 : page;
    m_pageControl.currentPage = page;
    [self turnPage];
}

- (void)createPageControl
{
    self.m_pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(20, m_frame.size.height - 20, m_frame.size.width - 40, 20)];
    self.m_pageControl.numberOfPages = [self.m_slideImages count];
    self.m_pageControl.currentPage = 0;
    [self addSubview:self.m_pageControl];
}

- (void)createScrollViews
{
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height - 20)];
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.delegate = self;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    [self.m_scrollView setContentOffset:CGPointMake(m_frame.size.width, 0)];
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width * ([self.m_slideImages count] + 2), m_frame.size.height - 20);
    [self addSubview:self.m_scrollView];
}

- (void)addImagesToScrollView
{
    NSString * imagePath = [m_slideImages objectAtIndex:[m_slideImages count] - 1];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagePath]];
    imageView.frame = CGRectMake(20, 0, m_frame.size.width - 40, m_frame.size.height - 20);
    [self.m_scrollView addSubview:imageView];
    for (int i = 0;i < [m_slideImages count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((m_frame.size.width * i) + m_frame.size.width + 20, 0, m_frame.size.width  - 40, m_frame.size.height - 20);
        [btn setBackgroundImage:[UIImage imageNamed:m_slideImages[i]] forState:0];
        [btn addTarget:self action:@selector(gotoWebString) forControlEvents:UIControlEventTouchUpInside];
        [self.m_scrollView addSubview:btn];
    }
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[m_slideImages objectAtIndex:0]]];
    imageView.frame = CGRectMake((m_frame.size.width * ([m_slideImages count] + 1)) + 20, 0, m_frame.size.width - 40, m_frame.size.height - 20);
    [self.m_scrollView addSubview:imageView];
}

- (void)addImagesToScrollView:(NSArray *)arr
{
    
    [self.m_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //处理传递过来的数组，取出里面的元素中的图片，组成一个新的数组
    [m_slideImages removeAllObjects];
    for (BaseAppInfo *info in arr) {
        if (info.recommend_icon) {
            [m_slideImages addObject:info.recommend_icon];
        }else
        {
            //如果没有用默认图片代替
            [m_slideImages addObject:@"tmp.png"];
        }
    }
    NSLog(@"m_slideImages count　＝　%d",[m_slideImages count]);
    
   
}
- (void) gotoWebString
{
    if ([self.scrollViewDelegate respondsToSelector:@selector(pushWebViewController)]) {
        [self.scrollViewDelegate pushWebViewController];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int currentPage = floor((self.m_scrollView.contentOffset.x - self.m_scrollView.frame.size.width
                             / ([m_slideImages count]+2)) / self.m_scrollView.frame.size.width) + 1;
    if (currentPage == 0) {
        //go last but 1 page
        self.m_pageControl.currentPage = [self.m_slideImages count] - 1;
        [self.m_scrollView scrollRectToVisible:CGRectMake(m_frame.size.width * [m_slideImages count],0,m_frame.size.width ,m_frame.size.height - 20) animated:NO];
    } else {
        self.m_pageControl.currentPage = currentPage - 1;
        if (currentPage == ([m_slideImages count]+1)) {
            self.m_pageControl.currentPage = 0;
            
            //如果是最后+1,也就是要开始循环的第一个
            [self.m_scrollView scrollRectToVisible:CGRectMake(m_frame.size.width ,0,m_frame.size.width ,m_frame.size.height - 20) animated:NO];
        }
    }
    
    NSLog(@"currentPage == %d", self.m_pageControl.currentPage);
}

- (void)clearTimer
{
    [self.m_timer invalidate];
    self.m_timer = nil;
}

- (void)dealloc
{
    [self.m_timer invalidate];
    self.m_timer = nil;
}

@end











