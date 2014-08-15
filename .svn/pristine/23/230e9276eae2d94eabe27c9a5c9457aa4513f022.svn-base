//
//  CrowdAndGroupInfo.h
//  WhistleIm
//
//  Created by 管理员 on 13-11-4.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CrowdAndGroupInfoDelegate  <NSObject>

@optional
- (void)sendGroupAllData:(NSMutableArray *)dataArr;
- (void)sendCrowdAllData:(NSMutableArray *)dataArr;

@end

@interface CrowdAndGroupInfo : NSObject
{
    __weak id <CrowdAndGroupInfoDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CrowdAndGroupInfoDelegate> m_delegate;

- (void)getDisccussionData;
- (void)getCrowdData;

@end
