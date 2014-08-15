//
//  LoginView.h
//  WhistleIm
//
//  Created by liuke on 14-2-18.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountInfo.h"

@protocol LoginViewDelegate <NSObject>
@optional
- (void) login:(NSString*) user pwd:(NSString*) pwd savepwd:(BOOL) save invisible:(BOOL) invisible;
- (void) deleteAccount:(NSString*) user;

@end

@interface LoginView : UIView

@property (nonatomic, strong, setter = setHead:) NSString* head;//头像
@property (nonatomic, strong, setter = setUser:) NSString* user;//用户名
@property (nonatomic, strong) NSString* pwd;//密码

@property (nonatomic, setter = setremPwd:) BOOL rememberPwd;//记住密码
@property (nonatomic, setter = setremInv:) BOOL invisibleLogin;//隐身登录

@property (nonatomic, strong) NSArray* moreAccount;
@property (nonatomic, strong, setter = setUsers:) AccountInfo* currentAccount;

@property (nonatomic, weak) id<LoginViewDelegate> delegate;

- (void) loading:(BOOL) isshow;
//- (void) draw;

@end
