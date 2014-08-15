//
//  RootScrollView.h
//  SlideSwitchDemo
//


#import <UIKit/UIKit.h>
@protocol RootScrollViewDelegate <NSObject>
@optional
- (void)pushAppCententController;
@end
@interface RootScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSArray *viewNameArray;
    CGFloat userContentOffsetX;
    BOOL isLeftScroll;
}
@property (nonatomic, retain) NSArray *viewNameArray;
@property (nonatomic, assign)id<RootScrollViewDelegate>scrollViewDelegate;
+ (RootScrollView *)shareInstance;

@end
