//
//  CrowdInfoTableView.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CrowdInfoTableViewDelegate <NSObject>
- (void)changeCrowdImage;
- (void)changeCrowdOthersInfoWithIndex:(NSIndexPath *)indexPath;

- (void)changeCrowdCategory;
- (void)changeCrowdAcceptStateWithIndex:(NSInteger)index;
- (void)showCrowdTalkRecord;
- (void)dissolveCrowd;
- (void)showCrowdMembers;
- (void)quitCrowd;
@end

@interface CrowdInfoTableView : UIView
{
    __weak id <CrowdInfoTableViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CrowdInfoTableViewDelegate> m_delegate;

- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableData andMySelfAuthority:(NSString *)authority;
- (void)refreshCrowdInfoTableViewWithDataArr:(NSMutableArray *)tableData andMySelfAuthority:(NSString *)authority;

@end
