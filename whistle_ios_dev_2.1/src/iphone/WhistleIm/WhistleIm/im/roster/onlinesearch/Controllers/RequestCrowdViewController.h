//
//  RequestCrowdViewController.h
//  WhistleIm
//
//  Created by ruijie on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CrowdInfo;

@interface RequestCrowdViewController : UIViewController
{
    CrowdInfo * m_CrowdInfo;
}
@property (nonatomic,strong) CrowdInfo * m_CrowdInfo;
@end
