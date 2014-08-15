//
//  FriendsDetailInfoViewController.h
//  WhistleIm
//
//  Created by 管理员 on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;

@interface FriendsDetailInfoViewController : UIViewController
{
    FriendInfo * m_friendInfo;
    NSString * m_type;
}

@property (nonatomic, strong) FriendInfo * m_friendInfo;
@property (nonatomic, strong) NSString * m_type;

@end
