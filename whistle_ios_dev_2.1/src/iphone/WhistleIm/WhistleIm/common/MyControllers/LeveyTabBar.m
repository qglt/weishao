//
//  LeveyTabBar.m
//  LeveyTabBarController
//
//  Created by Levey Zhu on 12/15/10.
//  Copyright 2010 VanillaTech. All rights reserved.
//

#import "LeveyTabBar.h"

@implementation LeveyTabBar
@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize buttons = _buttons;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray andTitleArr:(NSArray *)titleArr
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		_backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundView];
		
		self.buttons = [NSMutableArray arrayWithCapacity:[imageArray count]];
		UIButton *btn;
		CGFloat width = 320.0f / [imageArray count];
		for (int i = 0; i < [imageArray count]; i++)
		{
			btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.showsTouchWhenHighlighted = YES;
			btn.tag = i;
			btn.frame = CGRectMake(width * i, 0, width, frame.size.height);
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Default"] forState:UIControlStateNormal];
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Highlighted"] forState:UIControlStateHighlighted];
			[btn setImage:[[imageArray objectAtIndex:i] objectForKey:@"Seleted"] forState:UIControlStateSelected];
			[btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self.buttons addObject:btn];
			[self addSubview:btn];
            
            UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, width, frame.size.height - 30)];
            titleLable.backgroundColor = [UIColor clearColor];
            titleLable.text = [titleArr objectAtIndex:i];
            titleLable.font = [UIFont systemFontOfSize:10.0f];
            titleLable.textAlignment = NSTextAlignmentCenter;
            titleLable.tag = 10000 + i;
            titleLable.textColor = [UIColor colorWithRed:134.0f / 255.0f green:182.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f];
            [btn addSubview:titleLable];
            
            UIImageView * unreadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 7, 8, 8)];
            unreadImageView.image = [UIImage imageNamed:@"unreadRedIndicator.png"];
            unreadImageView.userInteractionEnabled = YES;
            unreadImageView.hidden = YES;
            unreadImageView.backgroundColor = [UIColor clearColor];
            unreadImageView.tag = 20000 + i;
            [btn addSubview:unreadImageView];
		}
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)img
{
	[_backgroundView setImage:img];
}

- (void)tabBarButtonClicked:(id)sender
{
	UIButton *btn = sender;
	[self selectTabAtIndex:btn.tag];
    [self resetTitleColorWithButton:btn];
}

- (void)resetTitleColorWithButton:(UIButton *)button
{
    for (NSUInteger i = 0; i < [self.buttons count]; i++) {
        UILabel * label = (UILabel *)[self viewWithTag:10000 + i];
        label.textColor = [UIColor colorWithRed:134.0f / 255.0f green:182.0f / 255.0f blue:212.0f / 255.0f alpha:1.0f];
        if (button.tag == label.tag - 10000) {
            label.textColor = [UIColor whiteColor];
        }
    }
}

- (void)showOrHiddenRedSpotWithIndex:(NSUInteger)index isHidden:(BOOL)hidden
{
    for (NSUInteger i = 0; i < [self.buttons count]; i++) {
        if (index == i) {
            UIImageView * unreadImageView = (UIImageView *)[self viewWithTag:20000 + i];
            unreadImageView.hidden = hidden;
        }
    }
}

- (void)selectTabAtIndex:(NSInteger)index
{
	for (int i = 0; i < [self.buttons count]; i++)
	{
		UIButton *b = [self.buttons objectAtIndex:i];
		b.selected = NO;
	}
	UIButton *btn = [self.buttons objectAtIndex:index];
	btn.selected = YES;
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectIndex:)])
    {
        [_delegate tabBar:self didSelectIndex:btn.tag];
    }
    NSLog(@"Select index: %d",btn.tag);
}

- (void)removeTabAtIndex:(NSInteger)index
{
    // Remove button
    [(UIButton *)[self.buttons objectAtIndex:index] removeFromSuperview];
    [self.buttons removeObjectAtIndex:index];
   
    // Re-index the buttons
     CGFloat width = 320.0f / [self.buttons count];
    for (UIButton *btn in self.buttons) 
    {
        if (btn.tag > index)
        {
            btn.tag --;
        }
        btn.frame = CGRectMake(width * btn.tag, 0, width, self.frame.size.height);
    }
}
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index
{
    // Re-index the buttons
    CGFloat width = 320.0f / ([self.buttons count] + 1);
    for (UIButton *b in self.buttons) 
    {
        if (b.tag >= index)
        {
            b.tag ++;
        }
        b.frame = CGRectMake(width * b.tag, 0, width, self.frame.size.height);
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.showsTouchWhenHighlighted = YES;
    btn.tag = index;
    btn.frame = CGRectMake(width * index, 0, width, self.frame.size.height);
    [btn setImage:[dict objectForKey:@"Default"] forState:UIControlStateNormal];
    [btn setImage:[dict objectForKey:@"Highlighted"] forState:UIControlStateHighlighted];
    [btn setImage:[dict objectForKey:@"Seleted"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttons insertObject:btn atIndex:index];
    [self addSubview:btn];
}

//- (void)dealloc
//{
//    [_backgroundView release];
//    [_buttons release];
//    [super dealloc];
//}

@end
