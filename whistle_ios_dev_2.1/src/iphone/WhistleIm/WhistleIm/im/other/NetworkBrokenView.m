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
#import "NetworkManager.h"
#import "ImUtils.h"

@interface NetworkBrokenView()<NetworkDelegate>
{
    CGFloat _w, _h;//view的宽度和高度
    
    UIView* _networkNotConnectView;
    
    UIView* _loginView;
    
    UIView* _autoLoginView;
    
    NSMutableArray* set_;
}
@end

@implementation NetworkBrokenView


//SINGLETON_IMPLEMENT(NetworkBrokenView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect f = frame;
        [self createLoginView:f];
        [self createNetworkDisconnectView:f];
        [self createAutoLoginView:f];
        _h = frame.size.height;
        _w = frame.size.width;
    }
    return self;
}

- (UIView*) createNetworkDisconnectView: (CGRect) rect
{
    if (!_networkNotConnectView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
        _networkNotConnectView = [[UIView alloc] initWithFrame:frame];
        _networkNotConnectView.backgroundColor = [UIColor whiteColor];
        UILabel* label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:@"网络连接不可用，请检查网络设置。"];
        UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [label setFont:font];
        label.textColor = [ImUtils colorWithHexString:@"#808080"];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_networkNotConnectView addSubview:label];
        
        UIView* sp = [[UIView alloc] init];
        sp.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
        [sp setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_networkNotConnectView addSubview:sp];
        
        NSMutableArray* constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-9-[sp(==1)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label, sp)]];
        
        [_networkNotConnectView addConstraints:constraints];
        

    }
    return _networkNotConnectView;
}

- (UIView *) createLoginView: (CGRect) rect
{
    if (!_loginView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
        _loginView = [[UIView alloc] initWithFrame:frame];
        _loginView.backgroundColor = [UIColor whiteColor];
        UIButton* btn = [[UIButton alloc] init];
        btn.titleLabel.text = @"您已掉线，请点击重新登录。";
        UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [btn.titleLabel setFont:font];
        [btn setTitle:@"您已掉线，请点击重新登录。" forState:UIControlStateNormal];
        [btn setTitleColor:[ImUtils colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(loginPressUp:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(loginPressDown:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(loginCancel:) forControlEvents:UIControlEventTouchUpOutside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_loginView addSubview:btn];
        
        
        UIView* sp = [[UIView alloc] init];
        sp.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
        [sp setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_loginView addSubview:sp];
        
        NSMutableArray* constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btn]-0-[sp(==1)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn, sp)]];
        [_loginView addConstraints:constraints];
        
    }
    return _loginView;
}

- (UIView *) createAutoLoginView: (CGRect) rect
{
    if (!_autoLoginView) {
        CGRect frame = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);

        _autoLoginView = [[UIView alloc] initWithFrame:frame];
        _autoLoginView.backgroundColor = [UIColor whiteColor];
        
        UILabel* label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:@"正在登录中..."];
        UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [label setFont:font];
        label.textColor = [ImUtils colorWithHexString:@"#808080"];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_autoLoginView addSubview:label];
        
        UIView* sp = [[UIView alloc] init];
        sp.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
        [sp setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_autoLoginView addSubview:sp];
        
        NSMutableArray* constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-9-[sp(==1)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label, sp)]];
        
        [_autoLoginView addConstraints:constraints];
    }
    return _autoLoginView;
}

- (void) loginPressDown: (id) sender
{
    NSLog(@"login press down");
    UIButton* btn = (UIButton*) sender;
    btn.backgroundColor = [ImUtils colorWithHexString:@"#cccccc"];
}

- (void) loginPressUp: (id) sender
{
    UIButton* btn = (UIButton*) sender;
    btn.backgroundColor = [UIColor whiteColor];
    [_networkNotConnectView removeFromSuperview];
    [_loginView removeFromSuperview];
    [self addSubview:_autoLoginView];
    [[AccountManager shareInstance] login];
}

- (void) loginCancel:(id) sender
{
    UIButton* btn = (UIButton*) sender;
    btn.backgroundColor = [UIColor whiteColor];
}

+ (NetworkBrokenView*) createView
{
    NetworkBrokenView* _view = nil;
    int width_inner = [[UIScreen mainScreen] bounds].size.width;//311;
    _view = [[NetworkBrokenView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                width_inner,
                                                                35)];
    [[NetworkManager shareInstance] addListener:_view];
    if ([[NetworkManager shareInstance] isOnlineState]) {
        [_view setHidden:YES];
    }else{
        if ([NetworkEnv isLocalWifiAvailable]) {
            [_view showLoginByClick];
        }else{
            [_view showNetworkTip];
        }
    }
    return _view;
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
    });
    return _view;
}

- (void) showLoginByClick
{
    [_networkNotConnectView removeFromSuperview];
    [_autoLoginView removeFromSuperview];
    [self addSubview: _loginView];
}

- (CGFloat) getHeight
{
    return _h;
}

- (CGFloat) getWidth
{
    return _w;
}

- (void) addListener:(id)listner
{
    if (!set_) {
        set_ = [[NSMutableArray alloc] initWithCapacity:3];
    }
    [set_ addObject:listner];
}

- (void) showNetworkTip
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loginView removeFromSuperview];
        [_autoLoginView removeFromSuperview];
        [self addSubview: _networkNotConnectView];
        [self setHidden:NO];
        [self sendSetShowNetworkTipDelegate:YES];
    });
}

- (void) showLoginTip
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoginByClick];
        [self setHidden:NO];
        [self sendSetShowNetworkTipDelegate:YES];
    });
}

- (void) hideNetworkTip
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHidden:YES];
        [self sendSetShowNetworkTipDelegate:NO];
    });
}

- (void) sendSetShowNetworkTipDelegate:(BOOL) isShow
{
    if (!set_) {
        return;
    }
    for (id<NetworkBrokenDelegate> d in set_) {
        if ([d respondsToSelector:@selector(setShowNetworkBrokenTip:)]) {
            [d setShowNetworkBrokenTip:isShow];
        }
    }
}

@end
