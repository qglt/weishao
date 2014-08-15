//
//  ShakeImageView.h
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShakeImageViewDelegate <NSObject>
- (void)deleteButtonPressedInShakeImageView:(id)mySelf;
- (void)addButtonPressedInShakeImageView:(UIButton *)button;
@end

@interface ShakeImageView : UIView
{
    __weak id <ShakeImageViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <ShakeImageViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame withImagePath:(NSString *)imagePath;
- (void)setShakeState:(BOOL)isShake;
- (void)setImage:(UIImage *)image;
- (void)setNameLabel:(NSString *)text;
- (void)setDeleteButtonState:(BOOL)hidden;
- (void)showAddButtonWith:(BOOL)show;

@end
