//
//  RootScrollView.h
//  SlideSwitchDemo
//


#import <UIKit/UIKit.h>
#import "CustomeView.h"
@protocol RootScrollViewDelegate <NSObject>
@optional
- (void)pushWebViewController;
- (void)pushAppDetailController:(id)self;
- (void)pushCommentController;
- (void)markApp:(id)info;
@end
@interface RootScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSArray *viewNameArray;
    CGFloat userContentOffsetX;
    BOOL isLeftScroll;
}
@property (nonatomic, retain) NSArray *viewNameArray;
@property (nonatomic, strong) CustomeView *customeView;//数字校园列表
@property (nonatomic, strong) CustomeView *whistelView;//微哨精选列表
@property (nonatomic, strong) CustomeView *collectView;//我的收藏列表
@property (nonatomic, assign)id<RootScrollViewDelegate>scrollViewDelegate;
+ (RootScrollView *)shareInstance;

@end
