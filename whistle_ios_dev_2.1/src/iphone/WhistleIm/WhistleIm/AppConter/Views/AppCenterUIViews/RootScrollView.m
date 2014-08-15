//
//  RootScrollView.m
//  SlideSwitchDemo
//


#import "RootScrollView.h"
#import "Globle.h"
#import "TopScrollView.h"
#import "CustomeView.h"
#define POSITIONID (int)scrollView.contentOffset.x/320

@implementation RootScrollView

@synthesize viewNameArray;

+ (RootScrollView *)shareInstance {
    static RootScrollView *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] initWithFrame:CGRectMake(0,40, 320, [Globle shareInstance].globleHeight-40)];
    });
    return __singletion;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scrollEnabled = NO;//关闭滑动
        self.viewNameArray = [NSArray arrayWithObjects:@"1", @"2", @"3",  nil];
        self.contentSize = CGSizeMake(320*[viewNameArray count], [Globle shareInstance].globleHeight-40);
        self.pagingEnabled = YES;
        self.userInteractionEnabled = YES;
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        userContentOffsetX = 0;
        
        [self initWithViews];
        
    }
    return self;
}

- (void)initWithViews
{

    
    _customeView = [[CustomeView alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-64-40)isHide:NO];
    [self addSubview:_customeView];
    
    _whistelView = [[CustomeView alloc] initWithFrame:CGRectMake(320, 0, 320, self.frame.size.height-64-40)isHide:NO];
    [self addSubview:_whistelView];
    
    _collectView = [[CustomeView alloc] initWithFrame:CGRectMake(640, 0, 320, self.frame.size.height-64-40) isHide:YES];
    [self addSubview:_collectView];

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    userContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (userContentOffsetX < scrollView.contentOffset.x) {
        isLeftScroll = YES;
    }
    else {
        isLeftScroll = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //调整顶部滑条按钮状态
    [self adjustTopScrollViewButton:scrollView];
    [[TopScrollView shareInstance] setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)adjustTopScrollViewButton:(UIScrollView *)scrollView
{
    [[TopScrollView shareInstance] setButtonUnSelect];
    [TopScrollView shareInstance].scrollViewSelectedChannelID = POSITIONID+100;
    [[TopScrollView shareInstance] setButtonSelect];
}


@end
