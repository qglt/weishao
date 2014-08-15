//
//  AddMembersScrollView.h
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMembersScrollView : UIView
- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)image andNumbers:(NSString *)numbers;
- (void)addMemberImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers;
//- (void)subtractImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers;
- (void)resetPreviousMemberImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers;


- (void)removeImageFromSuperViewAndMovePreviousImagesWithIndex:(NSInteger)index andNumbers:(NSString *)numbers;

@end
