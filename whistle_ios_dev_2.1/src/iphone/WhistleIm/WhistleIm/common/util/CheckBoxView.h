//
//  CheckBoxView.h
//  WhistleIm
//
//  Created by 管理员 on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CheckBoxViewDelegate <NSObject>
@optional
- (void)checkBoxButtonPressed:(UIButton *)button;
@end

@interface CheckBoxView : UIView
{
   __weak id <CheckBoxViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CheckBoxViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;
- (void)resetButtonSelectedState:(BOOL)isSelected;
@end
