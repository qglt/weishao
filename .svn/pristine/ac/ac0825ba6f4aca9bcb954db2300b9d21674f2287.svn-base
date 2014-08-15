//
//  ShakeTableView.h
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShakeTableViewDelegate <NSObject>

- (void)deleteButtonPressedInShakeTableView:(NSIndexPath *)indexPath andImageTag:(NSUInteger)deleteTag;
- (void)addButtonPressedInShakeTableView;

@end

@interface ShakeTableView : UIView
{
    NSMutableArray * m_arrTableData;
    __weak id <ShakeTableViewDelegate> m_delegate;
}

@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@property (nonatomic, weak) __weak id <ShakeTableViewDelegate> m_delegate;

- (id)initWithFrame:(CGRect)frame withDataArr:(NSMutableDictionary *)dataDict;
- (void)refreshTableView:(NSMutableDictionary *)dataDict andIsEditState:(BOOL)isEdit;

@end
