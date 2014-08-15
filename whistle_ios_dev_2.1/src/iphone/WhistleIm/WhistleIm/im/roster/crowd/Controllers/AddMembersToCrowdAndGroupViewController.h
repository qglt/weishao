//
//  AddMembersToCrowdAndGroupViewController.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMembersToCrowdAndGroupViewController : UIViewController
{
    NSString * m_type;
    NSString * m_crowdSessionID;
    
    // 好友的jid
    NSString * m_friendJid;
    
    // 已经在讨论组中或群中的成员数组，不能在列表里显示了
    NSMutableArray * m_arrHadMembersJid;
    
    NSUInteger m_maxLimit;
}

@property (nonatomic, strong) NSString * m_type;
@property (nonatomic, strong) NSString * m_crowdSessionID;
@property (nonatomic, strong) NSString * m_friendJid;
@property (nonatomic, strong) NSMutableArray * m_arrHadMembersJid;
@property (nonatomic, assign) NSUInteger m_maxLimit;

@end
