//
//  ShakeTableViewCell.h
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShakeTableViewCellDelegate <NSObject>

@optional
- (void)deleteButtonPressedInShakeTableViewCell:(id)mySelf andImageTag:(NSUInteger)deleteTag;
- (void)addButtonPressedInShakeTableViewCell;

@end

@interface ShakeTableViewCell : UITableViewCell
{
    NSMutableArray * m_arrImagePath;
    NSMutableArray * m_arrShakeState;
    BOOL m_isEdit;
    
    __weak id <ShakeTableViewCellDelegate> m_delegate;
}

@property (nonatomic, strong) NSMutableArray * m_arrImagePath;
@property (nonatomic, strong) NSMutableArray * m_arrShakeState;
@property (nonatomic, weak) __weak id <ShakeTableViewCellDelegate> m_delegate;
@property (nonatomic, assign) BOOL m_isEdit;



- (void)setCellData;

@end
