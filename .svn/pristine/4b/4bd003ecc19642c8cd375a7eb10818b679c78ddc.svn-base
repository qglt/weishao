//
//  CrowdDetailInfoSetting.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CrowdInfo;

@protocol CrowdDetailInfoSettingDelegate <NSObject>

- (void)sendCrowdDetailInfo:(NSMutableArray *)crowdInfo andDetailCrowdInfo:(CrowdInfo *)crowdInfo andMySelfAuthority:(NSString *)authority;

@end

@interface CrowdDetailInfoSetting : NSObject
{
    __weak id <CrowdDetailInfoSettingDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CrowdDetailInfoSettingDelegate> m_delegate;
- (void)getCrowdDetailInfoWithSessionId:(NSString *)sessionId;

@end
