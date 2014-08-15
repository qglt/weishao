//
//  AddCrowdTableView.h
//  WhistleIm
//
//  Created by ruijie on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CrowdInfo;
@protocol AddCrowdTableViewDelegate <NSObject>

- (void)didSelectedRowWithCrowdInfo:(NSUInteger)index;
- (void)sendSelectedTypeToController:(NSString *)selectedType andSearchKey:(NSString *)key andMaxCounter:(NSUInteger)counter andIndex:(NSUInteger)pageIndex isCommond:(BOOL)isCommond;
- (void)didSelectedButtonWithAddCrowd:(NSUInteger)index;
- (void)showCrowdAlockingAlert;
- (void)showNoneTextAlert;

@end

@interface AddCrowdTableView : UIView
@property (nonatomic,weak) id<AddCrowdTableViewDelegate> m_delegate;

- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableData;

- (void)refreshTableData:(NSMutableArray *)tableDataArr andSelectedType:(NSString *)type;
- (void)hiddenEmptySearchResultView:(BOOL)isShow andText:(NSString *)text;

@end
