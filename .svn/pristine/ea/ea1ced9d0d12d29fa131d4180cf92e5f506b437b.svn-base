//
//  CommentView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-24.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AMRatingControl.h"
#import "BaseAppInfo.h"
@protocol CommentViewDelegate <NSObject>
@optional
- (void)score:(NSInteger)starScroe;
@end

@interface CommentView : AMRatingControl<UITextViewDelegate,RatingContrlDelegate>
@property (nonatomic, strong) UIButton *img1;
@property (nonatomic, strong) UIButton *img2;
@property (nonatomic, strong) UIButton *img3;
@property (nonatomic, strong) UIButton *img4;
@property (nonatomic, strong) UIButton *img5;
@property (nonatomic, strong) UITextView *textField;
@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UIView *quickReview;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, weak) id<CommentViewDelegate>starScroreDelegate;
- (id)initWithFrame:(CGRect)frame withStarComment:(BaseAppInfo *)info;
@end
