//
//  MemberImageView.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemberImageView;
@protocol MemberImageViewDelegate <NSObject>

- (void)deleteImageButtonPressedInMemberImageView:(MemberImageView *)mySelf;

@end

@interface MemberImageView : UIView
{
    __weak id <MemberImageViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <MemberImageViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame andWithImage:(UIImage *)image andWithNumbers:(NSString *)numbers;
- (void)resetImageViewWithImage:(UIImage *)image andResetLabelWith:(NSString *)numbers;
@end
