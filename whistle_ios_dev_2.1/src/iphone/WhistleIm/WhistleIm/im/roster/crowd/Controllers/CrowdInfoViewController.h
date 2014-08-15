//
//  CrowdInfoViewController.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CrowdInfo;
@interface CrowdInfoViewController : UIViewController
{
    CrowdInfo * m_crowdInfo;
    NSString * m_crowdSessionID;
}

@property (nonatomic, strong) CrowdInfo * m_crowdInfo;
@property (nonatomic, strong) NSString * m_crowdSessionID;

@end
