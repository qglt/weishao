//
//  TopScrollView.m
//  SlideSwitchDemo
//


#import "TopScrollView.h"
#import "Globle.h"
#import "RootScrollView.h"
#import "ImUtils.h"
//按钮空隙
#define BUTTONGAP 5
//按钮长度
#define BUTTONWIDTH 95
//按钮高度
#define BUTTONHEIGHT 30
//滑条CONTENTSIZEX
#define CONTENTSIZEX 280

#define BUTTONID (sender.tag-100)

@implementation TopScrollView

@synthesize nameArray;
@synthesize scrollViewSelectedChannelID;

+ (TopScrollView *)shareInstance {
    static TopScrollView *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    });
    return __singletion;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
        self.scrollEnabled = NO;
        self.pagingEnabled = YES;//控制控件是否整页翻动
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.nameArray = [NSArray arrayWithObjects:@"数字校园", @"微哨精选", @"我的收藏", nil];
        
        //滚动范围的大小
        self.contentSize = CGSizeMake(250, 44);
        
        userSelectedChannelID = 100;
        scrollViewSelectedChannelID = 100;
        
        [self initWithNameButtons];
    }
    return self;
}

- (void)initWithNameButtons
{
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 320, 2)];
    lineLabel.backgroundColor = [UIColor colorWithRed:168.0/255.0 green:212.0/255.0 blue:228.0/255.0 alpha:1.0];
    [self addSubview:lineLabel];
    selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 106.6, 2)];
    selectLabel.backgroundColor = [ImUtils colorWithHexString:@"#2f87b9"];
    [self addSubview:selectLabel];
    
    for (int i = 0; i < [self.nameArray count]; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(BUTTONGAP+(BUTTONGAP+BUTTONWIDTH)*i, 9, BUTTONWIDTH, 30)];
        [button setTag:i+100];
        if (i == 0) {
            button.selected = YES;
        }
        [button setTitle:[NSString stringWithFormat:@"%@",[self.nameArray objectAtIndex:i]] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [button setTitleColor:[Globle colorFromHexRGB:@"808080"] forState:UIControlStateNormal];
        //暂时先不设置点击效果
//        [button setTitleColor:[Globle colorFromHexRGB:@"f6f6f6"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)selectNameButton:(UIButton *)sender
{
    [self adjustScrollViewContentX:sender];
    
    //如果更换按钮
    if (sender.tag != userSelectedChannelID) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[self viewWithTag:userSelectedChannelID];
        lastButton.selected = NO;
        //赋值按钮ID
        userSelectedChannelID = sender.tag;
    }
    
    //按钮选中状态
    if (!sender.selected) {
        sender.selected = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [selectLabel setFrame:CGRectMake(sender.frame.origin.x, 38, 106.6, 2)];
            
        } completion:^(BOOL finished) {
            if (finished) {
                //设置**页出现
                [[RootScrollView shareInstance] setContentOffset:CGPointMake(BUTTONID*320, 0) animated:NO];
                //赋值滑动列表选择频道ID
                scrollViewSelectedChannelID = sender.tag;
            }
        }];
        
    }
    //重复点击选中按钮
    else {
        
    }
}

- (void)adjustScrollViewContentX:(UIButton *)sender
{
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
    /*
    if (sender.frame.origin.x - self.contentOffset.x > CONTENTSIZEX-(BUTTONGAP+BUTTONWIDTH)) {
        //监控目前滚动的位置
        [self setContentOffset:CGPointMake((BUTTONID-4)*(BUTTONGAP+BUTTONWIDTH)+45, 0)  animated:YES];
        //        [self setContentOffset:CGPointMake(<#CGFloat x#>, 0) animated:<#(BOOL)#>]
    }
    
    if (sender.frame.origin.x - self.contentOffset.x < 5) {
        [self setContentOffset:CGPointMake(BUTTONID*(BUTTONGAP+BUTTONWIDTH), 0)  animated:YES];
    }
     */
}

- (void)setButtonUnSelect
{
    //滑动撤销选中按钮，滑动后先撤销选中的按钮，然后重新选中按按钮
    UIButton *lastButton = (UIButton *)[self viewWithTag:scrollViewSelectedChannelID];
    lastButton.selected = NO;
}

- (void)setButtonSelect
{
    //滑动选中按钮
    UIButton *button = (UIButton *)[self viewWithTag:scrollViewSelectedChannelID];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [selectLabel setFrame:CGRectMake(button.frame.origin.x, 38, 106.6, 2)];
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (!button.selected) {
                button.selected = YES;
                userSelectedChannelID = button.tag;
            }
        }
    }];
    
}


@end
