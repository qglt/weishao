//
//  PersonCardViewController.h
//  WhistleIm
//
//  Created by 管理员 on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PersonCardViewControllerDelegate <NSObject>
- (void)changeShowName:(NSString *)remarkName;
- (void)clearLastConversation;
@end

@interface PersonCardViewController : UIViewController
{
    NSString * m_jid;
    __weak id <PersonCardViewControllerDelegate> m_delegate;
    BOOL m_isStranger;
}

@property (nonatomic, strong) NSString * m_jid;
@property (nonatomic, weak) __weak id <PersonCardViewControllerDelegate> m_delegate;
@property (nonatomic, assign) BOOL m_isStranger;

@end
