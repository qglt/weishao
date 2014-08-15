//
//  CircularHeaderImageView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CircularHeaderImageView.h"
#import "ImageUtil.h"
#import "GBPathImageView.h"
@interface CircularHeaderImageView ()
{
    CGRect m_frame;
    NSString * m_imagePath;
    UIImage * m_image;
}

@property (nonatomic, strong) NSString * m_imagePath;
@property (nonatomic, strong) UIImage * m_image;

@end

@implementation CircularHeaderImageView

@synthesize m_imagePath;
@synthesize m_image;

- (id)initWithFrame:(CGRect)frame withPath:(NSString *)imagePath
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_imagePath = imagePath;
        [self createImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_image = image;
        [self createImageView];
    }
    return self;
}


- (void)createImageView
{
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    bgImageView.image = [ImageUtil getImageByImageNamed:@"portrait_circleframe.png" Consider:NO];
    
    UIImage * image = nil;
    if (!self.m_image) {
//         image = [ImageUtil getImageByImageNamed:self.m_imagePath Consider:NO];
        
        if ([self.m_imagePath hasPrefix:@"/"]) {
            image = [UIImage imageWithContentsOfFile:self.m_imagePath];
        } else {
            image = [UIImage imageNamed:self.m_imagePath];
        }
    } else {
        image = self.m_image;
    }
    
    GBPathImageView * imageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(10, 10, m_frame.size.width - 20, m_frame.size.height - 20) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:3.0f];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    [bgImageView addSubview:imageView];
    imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgImageView];
}
@end
