//
//  AnswerRequestViewController.h
//  WhistleIm
//
//  Created by 管理员 on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SystemMessageInfo;
@class FriendInfo;

@interface AnswerRequestViewController : UIViewController
{
    SystemMessageInfo * m_systemMessageInfo;
    FriendInfo * m_friendInfo;
}

@property (nonatomic, strong) SystemMessageInfo * m_systemMessageInfo;
@property (nonatomic, strong) FriendInfo * m_friendInfo;

@end
