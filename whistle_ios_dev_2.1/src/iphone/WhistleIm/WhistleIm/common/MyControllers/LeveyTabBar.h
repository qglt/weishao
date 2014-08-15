//
//  LeveyTabBar.h
//  LeveyTabBarController
//
//  Created by Levey Zhu on 12/15/10.
//  Copyright 2010 VanillaTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeveyTabBarDelegate;

@interface LeveyTabBar : UIView
{
	UIImageView *_backgroundView;
	__weak id<LeveyTabBarDelegate> _delegate;
	NSMutableArray *_buttons;
}
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, weak) id<LeveyTabBarDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *buttons;

- (id)initWithFrame:(CGRect)frame buttonImages:(NSArray *)imageArray andTitleArr:(NSArray *)titleArr;
- (void)selectTabAtIndex:(NSInteger)index;
- (void)removeTabAtIndex:(NSInteger)index;
- (void)insertTabWithImageDic:(NSDictionary *)dict atIndex:(NSUInteger)index;
- (void)setBackgroundImage:(UIImage *)img;
- (void)showOrHiddenRedSpotWithIndex:(NSUInteger)index isHidden:(BOOL)hidden;

@end
@protocol LeveyTabBarDelegate<NSObject>
@optional
- (void)tabBar:(LeveyTabBar *)tabBar didSelectIndex:(NSInteger)index;
@end
