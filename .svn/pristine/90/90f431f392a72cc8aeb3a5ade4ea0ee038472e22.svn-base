//
//  ShakeTableViewCell.m
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "ShakeTableViewCell.h"
#import "ShakeImageView.h"
#import "CrowdMemberInfo.h"
#import "ImUtils.h"

#define EACH_ROW_NUMBER 4
#define IMAGEVIEW_WIDTH 58
#define IMAGEVIEW_HEIGHT 80

#define IMAGE_TAG_START 1000

@interface ShakeTableViewCell ()
<ShakeImageViewDelegate>

@end

@implementation ShakeTableViewCell

@synthesize m_arrImagePath;
@synthesize m_arrShakeState;
@synthesize m_delegate;
@synthesize m_isEdit;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createAppImageView];
        [self createLineView];
    }
    return self;
}

- (void)createAppImageView
{
    for (NSUInteger i = 0; i < EACH_ROW_NUMBER; i++) {
        ShakeImageView * imageView = [[ShakeImageView alloc] initWithFrame:CGRectMake(i * (IMAGEVIEW_WIDTH + 16) + 16, 4, IMAGEVIEW_WIDTH, IMAGEVIEW_HEIGHT) withImagePath:nil];
        imageView.m_delegate = self;
        imageView.hidden = YES;
        imageView.tag = i + IMAGE_TAG_START;
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
    }
}

- (void)createLineView
{
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 83, 320, 1)];
    lineView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    [self addSubview:lineView];
}

// ShakeImageView delegate
- (void)deleteButtonPressedInShakeImageView:(id)mySelf
{
    ShakeImageView * shakeImageView = (ShakeImageView *)mySelf;
    NSLog(@"mySelf tag == %d", shakeImageView.tag);
    
    [m_delegate deleteButtonPressedInShakeTableViewCell:self andImageTag:shakeImageView.tag - IMAGE_TAG_START];
}

- (void)setCellData
{
    for (NSUInteger i = 0; i < EACH_ROW_NUMBER; i++) {
        ShakeImageView * imageView = (ShakeImageView *)[self viewWithTag:i + IMAGE_TAG_START];
        imageView.hidden = YES;
    }
    
    for (NSUInteger i = 0; i < [self.m_arrImagePath count]; i++) {
        if ([self.m_arrImagePath count] > i) {
            ShakeImageView * imageView = (ShakeImageView *)[self viewWithTag:i + IMAGE_TAG_START];
            imageView.hidden = NO;
            CrowdMemberInfo * memberInfo = [self.m_arrImagePath objectAtIndex:i];
            [imageView setImage:memberInfo.m_memberImage];
            [imageView setNameLabel:memberInfo.m_memberName];
            [imageView setDeleteButtonState:memberInfo.m_hiddenDelBtn];
            [imageView setShakeState:self.m_isEdit];
            [imageView showAddButtonWith:memberInfo.m_showAddBtn];
        }
    }
}

- (void)addButtonPressedInShakeImageView:(UIButton *)button
{
    [m_delegate addButtonPressedInShakeTableViewCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
