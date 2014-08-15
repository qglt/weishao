//
//  NetworkBrokenView.m
//  WhistleIm
//
//  Created by liuke on 13-10-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NetworkBrokenView.h"
#import "Reachability.h"
#import "Whistle.h"
#import "AccountInfo.h"
#import "AccountManager.h"
#import "NetworkEnv.h"
#import "MBProgressHUD.h"
#import "GetFrame.h"


@interface NetworkBrokenView() <MBProgressHUDDelegate>
{
    CGFloat _w, _h;//view的宽度和高度
    
    UIView* _networkNotConnectView;
    
    UIView* _loginView;
    
    UIView* _autoLoginView;
    
    MBProgressHUD* HUD;
}
@end

@implementation NetworkBrokenView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect f = frame;
        f.origin.x = 2;
        f.size.width = 311;
        [self createLoginView:f];
        [self createNetworkDisconnectView:f];
        [self createAutoLoginView:f];
        _h = frame.size.height;
        _w = frame.size.width;
    }
    return self;
}

- (UIView* ) createNetworkDisconnectView: (CGRect) rect
{
    LOG_UI_INFO(@"rect rect == %@", NSStringFromCGRect(rect));
    if (!_networkNotConnectView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);

        _networkNotConnectView = [[UIView alloc] initWithFrame:frame];

        _networkNotConnectView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"networkerror_tip_normal"]];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:frame];

        
        [btn addTarget:self action:@selector(setNetworkPressUp:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(setNetworkPressDown:) forControlEvents:UIControlEventTouchDown];
        
        
        UIView* v = [[UIView alloc] initWithFrame:frame];

        
        [v setUserInteractionEnabled:NO];
        
        int image_w = 36;
        int right_w = 24;
        int label_w = rect.size.width - image_w - right_w;
        
        UIImage* image = [UIImage imageNamed:@"warning"];
        UIImageView* image_view = [[UIImageView alloc] initWithImage:image];
        [v addSubview:image_view];
        
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(image_w, 0, label_w, rect.size.height)];
        label.text = @"网络连接不可用，请检查网络设置";
        label.backgroundColor = [UIColor clearColor];
        [v addSubview:label];
        UIFont* font = [UIFont systemFontOfSize:15.0f];
        [label setFont:font];
        
//        UIColor* shadowColor = [UIColor colorWithRed:49 green:49 blue:49 alpha:1];
//        [label setShadowColor:shadowColor];
//        [label setShadowOffset:CGSizeMake(0, 1)];
        
        UIImage* right_img = [UIImage imageNamed:@"right"];
        UIImageView* right_view = [[UIImageView alloc] initWithImage:right_img];
        right_view.frame = CGRectMake(image_w + label_w, 0, right_w, rect.size.height);
        [v addSubview:right_view];
        
        
        [btn addSubview: v];
        [_networkNotConnectView addSubview:btn];
    }
    return _networkNotConnectView;
}

- (UIView *) createLoginView: (CGRect) rect
{
    if (!_loginView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
        _loginView = [[UIView alloc] initWithFrame:frame];

        
        _loginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"networkerror_tip_normal"]];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:frame];

        [btn addTarget:self action:@selector(loginPressDown:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(loginPressUp:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView* v = [[UIView alloc] initWithFrame:frame];

        [v setUserInteractionEnabled:NO];
        UILabel* label = [[UILabel alloc] initWithFrame:frame];

        label.text = @"请点击此处登录";
        label.backgroundColor = [UIColor clearColor];
        [v addSubview:label];
        UIFont* font = [UIFont systemFontOfSize:15.0f];
        [label setFont:font];
        
//        UIColor* shadowColor = [UIColor colorWithRed:49.0 / 255 green:49.0 / 255 blue:49.0 / 255 alpha:1];
//        [label setShadowColor:shadowColor];
//        [label setShadowOffset:CGSizeMake(0, 1)];
        
        [v addSubview:label];
        
        [btn addSubview:v];
        
        [_loginView addSubview:btn];
    }
    return _loginView;
}

- (UIView *) createAutoLoginView: (CGRect) rect
{
    if (!_autoLoginView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);

        _autoLoginView = [[UIView alloc] initWithFrame:frame];
        _autoLoginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"networkerror_tip_normal"]];
        UIView* v = [[UIView alloc] initWithFrame:frame];
        
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.text = @"正在登录中。。。";
        
        label.backgroundColor = [UIColor clearColor];
        UIFont* font = [UIFont systemFontOfSize:15.0f];
        [label setFont:font];
        
//        UIColor* shadowColor = [UIColor colorWithRed:49 green:49 blue:49 alpha:1];
//        [label setShadowColor:shadowColor];
//        [label setShadowOffset:CGSizeMake(0, 1)];
        
        [v addSubview:label];
        
        [_autoLoginView addSubview:v];
    }
    return _autoLoginView;
}

- (void) setNetworkPressUp: (id) sender
{
    NSLog(@"net work broken btn up");
    _networkNotConnectView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"networkerror_tip_normal"]];
}

- (void) setNetworkPressDown: (id) sender
{
    NSLog(@"net work broken btn down");
    if ([NetworkEnv isLocalWifiAvailable]) {
//    if (YES) {
        //本地wifi已经打开
        _networkNotConnectView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"networkerror_tip_press"]];
        [_networkNotConnectView removeFromSuperview];
        [_autoLoginView removeFromSuperview];
        [self addSubview:_loginView];
    }
    else
    {
        //本地wifi没有打开
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }

}

- (void) loginPressDown: (id) sender
{
    NSLog(@"login press down");
}

- (void) loginPressUp: (id) sender
{
    NSLog(@"login press up");
    [_networkNotConnectView removeFromSuperview];
    [_loginView removeFromSuperview];
    [self addSubview:_autoLoginView];
//    [self autoLogin];
}


+ (id) getInstance
{
    static NetworkBrokenView* _view = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int width_inner = [[UIScreen mainScreen] bounds].size.width;//311;
        
        BOOL iOS7 = [[GetFrame shareInstance] isIOS7Version];
        CGFloat y = 0.0f;
        if (iOS7) {
            y = 64.0f;
        }
        _view = [[NetworkBrokenView alloc] initWithFrame:CGRectMake(0,
                                                                    y,
                                                                    width_inner,
                                                                    36)];
        _view.hidden = YES;
    });
    return _view;
}

- (void) reset
{
    [[self delegate] setShowNetworkBrokenTip: NO];
    [_loginView removeFromSuperview];
    [_autoLoginView removeFromSuperview];
    [_networkNotConnectView removeFromSuperview];
    [[NetworkBrokenView getInstance] setHidden:YES];
}

- (void) showNetworkTip:(BOOL)isShow
{
    [[self delegate] setShowNetworkBrokenTip:isShow];
    if (isShow) {
        [_loginView removeFromSuperview];
        [_autoLoginView removeFromSuperview];
        [self addSubview: _networkNotConnectView];
    } else {

        [_networkNotConnectView removeFromSuperview];
        [_loginView removeFromSuperview];
        [self addSubview:_autoLoginView];
    }
}

- (void) showLoginByClick
{
    [_networkNotConnectView removeFromSuperview];
    [_autoLoginView removeFromSuperview];
    [self addSubview: _loginView];
    [[NetworkBrokenView getInstance] setHidden:NO];

    [[self delegate] setShowNetworkBrokenTip:YES];
}

//- (void) reachabilityChanged: (NSNotification *) note
//{
//    NSLog(@"net change");
//    Reachability* r = [note object];
//    LOG_GENERAL_INFO(@"网络变化为:%d", [r currentReachabilityStatus]);
//    if ([r currentReachabilityStatus] == NotReachable) {
//        NSLog(@"当前网络没有连接");
//        [self showNetworkTip:YES];
//        _isConnectedNetwork = NO;
//    }
//    else if(_isConnectedNetwork == NO /*&& ![[WHISTLE_APPPROXY whistleAccountManager] isLogon]*/)
//    {
//        NSLog(@"当前网络已经连接");
//        [self showNetworkTip:NO];
//        [self autoLogin];
//        _isConnectedNetwork = YES;
//    }
//}

- (CGFloat) getHeight
{
    return _h;
}

- (CGFloat) getWidth
{
    return _w;
}

- (void) hudWasHidden:(MBProgressHUD *)hud
{
    [HUD removeFromSuperViewOnHide];
    [HUD removeFromSuperview];
    HUD = nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
