//
//  FeedbackView.m
//  WhistleIm
//
//  Created by liuke on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FeedbackView.h"
#import "Whistle.h"
#import "EmotionView.h"
#import "WriteContentView.h"
#import "ImUtils.h"


@interface FeedbackView()
<WriteContentViewDelegate>
{
    UIView* _lblView;
    UIView* _emotionView;
    EmotionView* _emotionFaceView;
    UIView* _contentView;
    UIColor* _backgroundColor;
    WriteContentView* _writeContentView;
    UILabel * m_remarkLabel;
}
@property (nonatomic, strong) UILabel * m_remarkLabel;
@end



@implementation FeedbackView
@synthesize m_remarkLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];

        [self setBackgroundColor: _backgroundColor];
//        [self setBackgroundColor: [UIColor greenColor]];
        CGSize size = [[UIScreen mainScreen] bounds].size;
        [self addSubview: [self createSubTitle: CGRectMake(20, 0, size.width - 40, 70)]];
        [self addSubview: [self createEmotionFace: CGRectMake(20, 70, size.width - 40, 66)]];
        [self addSubview: [self createContent: CGRectMake(20, 70 + 66 + 14, size.width - 40, 150)]];
        [self createLimitLabelWithFrame:CGRectMake(200, 300, 100, 30)];
        
    }
    return self;
}

- (UIView*) createSubTitle: (CGRect) rect
{
    _lblView = [[UIView alloc] initWithFrame:rect];
    UILabel* content = [[UILabel alloc] initWithFrame:_lblView.bounds];

    [content setText:@"您好，感谢您对我们的产品提出需求和想法，帮助我们优化产品。"];

    content.numberOfLines = 2;
    content.lineBreakMode = NSLineBreakByCharWrapping;
    [content setBackgroundColor: [UIColor clearColor]];
    

    
    UIFont* font = [UIFont systemFontOfSize:15.0f];
    [content setFont:font];
    
    UIColor* shadowColor = [UIColor colorWithRed:49 green:49 blue:49 alpha:1];
    [content setShadowColor:shadowColor];
    [content setShadowOffset:CGSizeMake(0, 1)];
    
    
    
    [_lblView addSubview:content];

    [_lblView setBackgroundColor: [UIColor clearColor]];

    return _lblView;
}

- (UIView*) createEmotionFace: (CGRect) rect
{
    NSLog(@"load emotion face view");
    
    _emotionView = [[UIView alloc] initWithFrame: rect];

    UILabel* lbl = [[UILabel alloc] init];
    lbl.text = @"心情";
    UIFont* font = [UIFont systemFontOfSize:15.0f];
    [lbl setFont:font];
    
    UIColor* shadowColor = [UIColor colorWithRed:49 green:49 blue:49 alpha:1];
    [lbl setShadowColor:shadowColor];
    [lbl setShadowOffset:CGSizeMake(0, 1)];
    lbl.frame = CGRectMake(0, 0, 43, 40);
    [lbl setBackgroundColor:[UIColor clearColor]];
    [_emotionView addSubview:lbl];
    
    
    _emotionFaceView = [[EmotionView alloc] initWithFrame:CGRectMake(lbl.frame.size.width, 0, rect.size.width - lbl.frame.size.width, rect.size.height)];
    [_emotionView addSubview: _emotionFaceView];
    return _emotionView;
}


- (UIView*) createContent: (CGRect) rect
{
    _contentView = [[UIView alloc] initWithFrame:rect];
    
    UILabel* lbl = [[UILabel alloc] init];
    lbl.text = @"内容";
    lbl.frame = CGRectMake(0, 0, 40, 40);
    
    UIFont* font = [UIFont systemFontOfSize:15.0f];
    [lbl setFont:font];
    
    UIColor* shadowColor = [UIColor colorWithRed:49 green:49 blue:49 alpha:1];
    [lbl setShadowColor:shadowColor];
    [lbl setShadowOffset:CGSizeMake(0, 1)];
    
    [lbl setBackgroundColor: [UIColor clearColor]];
    [_contentView addSubview:lbl];
    
    _writeContentView = [[WriteContentView alloc] initWithFrame:
                                 CGRectMake(lbl.frame.size.width, 0, rect.size.width - lbl.frame.size.width, rect.size.height)
                                                         withParentView: self ];
    _writeContentView.m_delegate = self;
    [_contentView addSubview:_writeContentView];
    
    return _contentView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    NSLog(@"feedback view touch end");
    [_writeContentView textViewDidEndEditing];
}

- (void) endEditing
{
    [_writeContentView textViewDidEndEditing];
}

- (enum EMOTION) getEmotion
{
    return [_emotionFaceView getEmotion];
}

- (NSString*) getContent
{
    return [_writeContentView getContent];
}


- (void)sendText:(NSString *)text
{
    NSUInteger length = [text length];
    
    NSInteger limitNumber = 100 - length;
    if (limitNumber <= 0) {
        limitNumber = 0;
    }
    self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", limitNumber];
}

- (void)createLimitLabelWithFrame:(CGRect)frame
{
    self.m_remarkLabel = [[UILabel alloc] initWithFrame:frame];
    self.m_remarkLabel.textAlignment = NSTextAlignmentCenter;
    self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", 100];
    self.m_remarkLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_remarkLabel];
}

@end
