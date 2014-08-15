//
//  LoginViewController.h
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteConfigInfo.h"

@interface LoginViewController : UIViewController

SINGLETON_DEFINE(LoginViewController)

@property (nonatomic) BOOL m_isChangeAccount;
@property (nonatomic,strong) RemoteConfigInfo* selectedConfig;

@end
