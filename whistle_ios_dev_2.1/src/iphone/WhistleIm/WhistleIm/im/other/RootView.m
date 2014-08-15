//
//  RootView.m
//  WhistleIm
//
//  Created by liuke on 13-12-17.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "RootView.h"
#import "NetworkBrokenView.h"
#import "NetworkManager.h"

@interface RootView()
{
    NetworkBrokenView* networkView_;
    UIView* mainView_;
    CGFloat networkViewHeight_;
}

@end

@implementation RootView


- (id) initWithView:(UIView*) view
{
    self = [super init];
    if (self) {
        BOOL isIOS7_ = [[GetFrame shareInstance] isIOS7Version];
        CGRect frame = [[UIScreen mainScreen] bounds];
        float y = 0;
        float h = frame.size.height - 64 - 50;
        if (isIOS7_) {
            y += 64;
        }else{
            h += 20;
        }
        CGRect rect = CGRectMake(0, y, frame.size.width, frame.size.height);
        self.frame = rect;
        networkView_ = [NetworkBrokenView createView];
//        networkView_.backgroundColor = [UIColor yellowColor];
        networkViewHeight_ = [networkView_ getHeight];
        [self addSubview: networkView_];
        mainView_ = [[UIView alloc] initWithFrame:CGRectMake(0, networkViewHeight_, frame.size.width, frame.size.height - networkViewHeight_)];
        [mainView_ addSubview:view];
//        mainView_.backgroundColor = [UIColor redColor];
        [self addSubview: mainView_];
        [self setShowNetworkBrokenTip:![[NetworkManager shareInstance] isOnlineState]];
        [networkView_ addListener:self];
    }
    return self;
}


- (void) setShowNetworkBrokenTip:(BOOL)isShow
{
    if (isShow) {
        [networkView_ setHidden:NO];
        if (mainView_.frame.origin.y < 5) {
            //没有显示
            CGRect tmp = mainView_.frame;
            tmp.origin.y += networkViewHeight_;
            mainView_.frame = tmp;
        }
    }else{
        [networkView_ setHidden:YES];
        if (mainView_.frame.origin.y > 5) {
            //已经显示
            CGRect tmp = mainView_.frame;
            tmp.origin.y -= networkViewHeight_;
            mainView_.frame = tmp;
        }
    }
}


//- (void) createView
//{
//    BOOL isIOS7_ = [[GetFrame shareInstance] isIOS7Version];
////    BOOL is4Inch_ = [[GetFrame shareInstance] is4InchScreen];
//    CGRect frame = [[UIScreen mainScreen] bounds];
//    float y = 44;
//    float h = frame.size.height - 64 - 50;
//    if (isIOS7_) {
//        y += 64;
//    }else{
//        h += 20;
//    }
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, h)];
//    
//    [view addSubview:[NetworkBrokenView getInstance]];
//    
//    UIView* otherView = [[UIView alloc] initWithFrame:CGRectMake(0, [[NetworkBrokenView getInstance] getHeight], frame.size.width, frame.size.height - [[NetworkBrokenView getInstance] getHeight])];
//    
//    [view addSubview:otherView];

    
//    CGFloat y = 0;
//    CGRect m_frame = self.bounds;
//    CGFloat height = m_frame.size.height;
//    BOOL m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
//    BOOL m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
//    if (m_isIOS7) {
//        y += 64;
//        if (m_is4Inch) {
//            height = m_frame.size.height - 64 - 50;
//        } else {
//            height = m_frame.size.height - 64 - 50;
//        }
//    } else {
//        height = m_frame.size.height - 44 - 44;
//    }
    
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
