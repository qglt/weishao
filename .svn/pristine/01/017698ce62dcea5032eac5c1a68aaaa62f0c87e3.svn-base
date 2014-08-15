//
//  CrowdVoteTableView.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CrowdVoteTableViewDelegate <NSObject>

- (void)voteButtonPressed:(NSMutableArray *)stateArr;
- (void)showVoteList;

@end

@interface CrowdVoteTableView : UIView
{
    __weak id <CrowdVoteTableViewDelegate> m_delegate;
    BOOL m_isShowVoteRatio;
    BOOL m_hadVoted;
    BOOL m_anonymous;
}

@property (nonatomic, weak) __weak id <CrowdVoteTableViewDelegate> m_delegate;

@property (nonatomic, assign) BOOL m_isShowVoteRatio;
@property (nonatomic, assign) BOOL m_hadVoted;
@property (nonatomic, assign) BOOL m_anonymous;


- (void)refreshTableViewWithData:(NSMutableArray *)tableData andInfoDict:(NSMutableDictionary *)dict;
- (void)refreshTableViewWithVotePercentageData:(NSMutableArray *)votePercentageData andInfoDict:(NSMutableDictionary *)dict;
@end
