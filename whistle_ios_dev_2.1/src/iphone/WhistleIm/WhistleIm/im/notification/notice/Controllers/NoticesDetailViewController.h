//
//  NoticesDetailViewController.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticesDetailViewController : UIViewController
{
    NSMutableArray * m_arrNoticeData;
    NSUInteger m_selectedIndex;
    BOOL isNotice;
}

@property (nonatomic, strong) NSMutableArray * m_arrNoticeData;
@property (nonatomic, assign) NSUInteger m_selectedIndex;
@property (nonatomic,assign)BOOL isNotice;
@end
