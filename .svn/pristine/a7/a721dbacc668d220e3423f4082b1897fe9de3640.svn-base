//
//  RootScrollView.m
//  SlideSwitchDemo
//


#import "RootScrollView.h"
#import "Globle.h"
#import "TopScrollView.h"

#define POSITIONID (int)scrollView.contentOffset.x/320

@implementation RootScrollView

@synthesize viewNameArray;

+ (RootScrollView *)shareInstance {
    static RootScrollView *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] initWithFrame:CGRectMake(0, 64+44+10, 320, [Globle shareInstance].globleHeight-44)];
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
        self.contentSize = CGSizeMake(320*[viewNameArray count], [Globle shareInstance].globleHeight-44);
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
    for (int i = 0; i < [viewNameArray count]; i++) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0+320*i, 0, 320, [Globle shareInstance].globleHeight-64-44-30)];
//        label.text = [NSString stringWithFormat:@"%@",[viewNameArray objectAtIndex:i]];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont boldSystemFontOfSize:50.0];
//        label.backgroundColor = [UIColor redColor];
//        [self addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16+320*2, 0, 45, 45);
        [btn setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pushAppCentent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
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
    /*
    if (isLeftScroll) {
        if (scrollView.contentOffset.x <= 320*3) {
            [[TopScrollView shareInstance] setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        else {
            [[TopScrollView shareInstance] setContentOffset:CGPointMake((POSITIONID-4)*64+45, 0) animated:YES];
        }
        
    }
    else {
        if (scrollView.contentOffset.x >= 320*3) {
            [[TopScrollView shareInstance] setContentOffset:CGPointMake(2*64+45, 0) animated:YES];
        }
        else {
            [[TopScrollView shareInstance] setContentOffset:CGPointMake(POSITIONID*64, 0) animated:YES];
        }
    }
     */
}

- (void)adjustTopScrollViewButton:(UIScrollView *)scrollView
{
    [[TopScrollView shareInstance] setButtonUnSelect];
    [TopScrollView shareInstance].scrollViewSelectedChannelID = POSITIONID+100;
    [[TopScrollView shareInstance] setButtonSelect];
}
#pragma mark pushAppCentent
- (void)pushAppCentent
{
    if ([self.scrollViewDelegate respondsToSelector:@selector(pushAppCententController)]) {
        [self.scrollViewDelegate pushAppCententController];
    }
}

@end
