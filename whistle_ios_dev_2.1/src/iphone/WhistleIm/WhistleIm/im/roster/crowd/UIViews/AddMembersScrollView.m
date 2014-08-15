//
//  AddMembersScrollView.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddMembersScrollView.h"
#import "MemberImageView.h"

#define IMAGE_WIDTH 35
#define DISTANCE 23

#define IMAGE_START_TAG 1000

@interface AddMembersScrollView ()
<UIScrollViewDelegate>
{
    CGRect m_frame;
    NSString * m_numbers;
    
    UIScrollView * m_scrollView;
    
    CGFloat m_startX;
    CGFloat y;
    
    NSUInteger m_hadCreateNum;
    
    CGFloat m_scrollWidth;
    
    BOOL m_isAdd;
}

@property (nonatomic, strong) NSString * m_numbers;
@property (nonatomic, strong) UIScrollView * m_scrollView;

@end

@implementation AddMembersScrollView

@synthesize m_numbers;

@synthesize m_scrollView;

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)image andNumbers:(NSString *)numbers
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_numbers = numbers;
        [self createScrollView];
        
        m_startX = 15.0f;
        y = 7.0f;
        m_scrollWidth = m_frame.size.width;
        [self createMemeberImageViewWithFrame:CGRectMake(m_startX, y, IMAGE_WIDTH, IMAGE_WIDTH) withImage:image andNumbers:numbers];
        
    }
    return self;
}

- (void)createScrollView
{
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    self.m_scrollView.delegate = self;
    self.m_scrollView.showsHorizontalScrollIndicator = NO;
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, m_frame.size.height);
    [self addSubview:self.m_scrollView];
}

// 在最后加一个
- (void)addMemberImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers
{
    m_isAdd = YES;
    m_hadCreateNum++;
    m_startX += IMAGE_WIDTH + DISTANCE;
    [self createMemeberImageViewWithFrame:CGRectMake(m_startX, y, IMAGE_WIDTH, IMAGE_WIDTH) withImage:image andNumbers:numbers];
    
    [self resetScrollViewContentSizeWithNumbers:numbers];
}

//// 去掉最后的一个
//- (void)subtractImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers
//{
//    m_isAdd = NO;
//    MemberImageView * imageView = (MemberImageView *)[self.m_scrollView viewWithTag:IMAGE_START_TAG + m_hadCreateNum];
//    [imageView removeFromSuperview];
//    m_startX -= IMAGE_WIDTH + DISTANCE;
//
//    [self resetScrollViewContentSizeWithNumbers:numbers];
//    
//    m_hadCreateNum--;
//}

// 加的时候，真实图片，没数字，减的时候，默认图片，有数字
- (void)createMemeberImageViewWithFrame:(CGRect)frame withImage:(UIImage *)image andNumbers:(NSString *)numbers
{
    MemberImageView * imageView = [[MemberImageView alloc] initWithFrame:frame andWithImage:image andWithNumbers:numbers];
    imageView.tag = m_hadCreateNum + IMAGE_START_TAG;
    [self.m_scrollView addSubview:imageView];
}

- (void)resetPreviousMemberImageViewWithImage:(UIImage *)image andNumbers:(NSString *)numbers
{
    MemberImageView * imageView = (MemberImageView *)[self.m_scrollView viewWithTag:IMAGE_START_TAG + m_hadCreateNum - 1];
    [imageView resetImageViewWithImage:image andResetLabelWith:numbers];
}

- (void)resetScrollViewContentSizeWithNumbers:(NSString *)numbers
{
//    if (m_isAdd) {
//        CGFloat distance = 0;
//        if (m_hadCreateNum > 4) {
//            
//            if (m_hadCreateNum == 5) {
//                distance = IMAGE_WIDTH;
//            } else {
//                distance = IMAGE_WIDTH + DISTANCE;
//            }
//            
//            m_scrollWidth += distance;
//            
//            self.m_scrollView.contentSize = CGSizeMake(m_scrollWidth, m_frame.size.height);
//        } else {
//            self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, m_frame.size.height);
//        }
//        
//        [self startMove];

//    } else {
//        CGFloat distance = 0;
//        if (m_hadCreateNum > 4) {
//            if (m_hadCreateNum == 5) {
//                distance = IMAGE_WIDTH;
//            } else {
//                distance = IMAGE_WIDTH + DISTANCE;
//            }
//
//            m_scrollWidth -= distance;
//            [self startMove];
//
//            self.m_scrollView.contentSize = CGSizeMake(m_scrollWidth, m_frame.size.height);
//
//        } else {
//            self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, m_frame.size.height);
//        }
//        
//
//    }
    
    CGFloat distance = 0;
    if (m_hadCreateNum > 4) {
        
        if (m_hadCreateNum == 5) {
            distance = IMAGE_WIDTH;
        } else {
            distance = IMAGE_WIDTH + DISTANCE;
        }
        
        m_scrollWidth += distance;
        
        self.m_scrollView.contentSize = CGSizeMake(m_scrollWidth, m_frame.size.height);
    } else {
        self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width, m_frame.size.height);
    }
    
    NSLog(@"add image contentSize == %@", NSStringFromCGSize(self.m_scrollView.contentSize));

    
    [self startMove];
}

- (void)startMove
{
    if (m_hadCreateNum > 4) {
        
        [self.m_scrollView scrollRectToVisible:CGRectMake(m_scrollWidth - m_frame.size.width, 0, m_frame.size.width, m_frame.size.height) animated:YES];
        NSLog(@"移动了 == %f", m_scrollWidth - m_frame.size.width);
    }
}

// 删除对应的图片，前面的向后移动
- (void)removeImageFromSuperViewAndMovePreviousImagesWithIndex:(NSInteger)index andNumbers:(NSString *)numbers
{
    [self removeCurrentImageWithIndex:index];
    [self animationPreviousImageWithIndex:index];
    [self resetAfterImageViewTag:index];
    [self resetScrollViewContentSizeAndContentOffset];
    m_hadCreateNum--;
    m_startX -= IMAGE_WIDTH + DISTANCE;
}

// 删除当前图片
- (void)removeCurrentImageWithIndex:(NSUInteger)index
{
    MemberImageView * imageView = (MemberImageView *)[self.m_scrollView viewWithTag:index + IMAGE_START_TAG];
    [imageView removeFromSuperview];
}

// 要删除图片的前面的所有图片，都向右侧移动一定的距离
- (void)animationPreviousImageWithIndex:(NSUInteger)index
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    for (NSUInteger i = IMAGE_START_TAG; i < IMAGE_START_TAG + index; i++) {
        MemberImageView * imageView = (MemberImageView *)[self.m_scrollView viewWithTag:i];
        CGRect frame = imageView.frame;
        frame.origin.x += IMAGE_WIDTH + DISTANCE;
        
        imageView.frame = frame;
    }
    
    [UIView commitAnimations];
}

// 设置当前要删除图片，后面所有图片的tag值减1
- (void)resetAfterImageViewTag:(NSInteger)index
{
    for (NSUInteger i = IMAGE_START_TAG + index + 1; i < IMAGE_START_TAG + m_hadCreateNum; i++) {
        MemberImageView * imageView = (MemberImageView *)[self.m_scrollView viewWithTag:i];
        imageView.tag = i - 1;
    }
}

- (void)resetScrollViewContentSizeAndContentOffset
{
    
//    [self.m_scrollView scrollRectToVisible:CGRectMake(m_scrollWidth - m_frame.size.width, 0, m_frame.size.width, m_frame.size.height) animated:YES];
    
//    m_scrollWidth -= IMAGE_WIDTH + DISTANCE;
//    self.m_scrollView.contentSize = CGSizeMake(m_scrollWidth, m_frame.size.height);
//    NSLog(@"subtract image contentSize == %@", NSStringFromCGSize(self.m_scrollView.contentSize));
    
    
//    [self.m_scrollView scrollRectToVisible:CGRectMake(m_scrollWidth - m_frame.size.width, 0, m_frame.size.width, m_frame.size.height) animated:YES];
//    NSLog(@"移动了 == %f", m_scrollWidth - m_frame.size.width);
    
   


}

- (void)move
{
    NSArray * subViews = self.subviews;
    for (MemberImageView * imageView in subViews) {
        CGRect frame = imageView.frame;
        frame.origin.x -= IMAGE_WIDTH + DISTANCE;
        imageView.frame = frame;
    }
}


@end
