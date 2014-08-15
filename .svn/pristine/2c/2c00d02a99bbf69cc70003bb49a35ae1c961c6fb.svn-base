//
//  EmotionView.m
//  WhistleIm
//
//  Created by liuke on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "EmotionView.h"
//#import "ImUtil.h"
#import "ImageUtil.h"

@interface EmotionView()
{
    UIButton* _perfectBtn;
    UIButton* _goodBtn;
    UIButton* _normalBtn;
    UIButton* _badBtn;
    UIButton* _sickBtn;
    
    enum EMOTION _currentEmotion;
}

@end

@implementation EmotionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int w = 44;
        NSLog(@"emotion view load");
        [self addSubview:[self createBackground: CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self addSubview:[self createEmotionItem:Perfact WithRect:CGRectMake(0, 0, w, 56)]];
        [self addSubview:[self createEmotionItem:Good WithRect:CGRectMake(w + 2, 0, w, 56)]];
        [self addSubview:[self createEmotionItem:Normal WithRect:CGRectMake(2 * (w + 2), 0, w, 56)]];
        [self addSubview:[self createEmotionItem:Bad WithRect:CGRectMake(3 * (w + 2), 0, w, 56)]];
        [self addSubview:[self createEmotionItem:Sick WithRect:CGRectMake(4 * (w + 2), 0, w, 56)]];
        
        [self setEmotion:Perfact IsLight:YES];//默认图标点亮
        _currentEmotion = Perfact;
    }
    return self;
}

- (UIView*) createBackground: (CGRect) rect
{
    UIView* emotion = [[UIView alloc] initWithFrame:rect];
    UIImage* img = [[ImageUtil getImageByImageNamed:@"feedback_edit.png" Consider:NO] stretchableImageWithLeftCapWidth:20 topCapHeight:25];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = emotion.bounds;
    [imgView setUserInteractionEnabled:YES];
    [emotion addSubview:imgView];
    return emotion;
}

- (UIView*) createEmotionItem: (enum EMOTION) e WithRect: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    NSLog(@"%@", NSStringFromCGRect(rect));
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 30, 20)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    switch (e) {
        case Perfact:
            _perfectBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _perfectBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_better_nor" Consider:NO]];
            [_perfectBtn setImage:[ImageUtil getImageByImageNamed:@"feedback_better_nor.png" Consider:NO ] forState:UIControlStateNormal];
            _perfectBtn.tag = Perfact;
            [_perfectBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _perfectBtn];
            lbl.text = @"喜欢";
            break;
    
        case Good:
            _goodBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _goodBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_good_nor.png" Consider:NO]];
            [_goodBtn setImage:[ImageUtil getImageByImageNamed: @"feedback_good_nor.png" Consider:NO] forState:UIControlStateNormal];
            _goodBtn.tag = Good;
            [_goodBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _goodBtn];
            lbl.text = @"不错";
            break;
            
        case Normal:
            _normalBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _normalBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_general_nor.png" Consider:NO]];
            [_normalBtn setImage:[ImageUtil getImageByImageNamed: @"feedback_general_nor.png" Consider:NO] forState:UIControlStateNormal];
            _normalBtn.tag = Normal;
            [_normalBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _normalBtn];
            lbl.text = @"一般";
            break;
            
        case Bad:
            _badBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _badBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_bad_nor.png" Consider:NO]];
            [_badBtn setImage:[ImageUtil getImageByImageNamed: @"feedback_bad_nor.png" Consider:NO] forState:UIControlStateNormal];
            _badBtn.tag = Bad;
            [_badBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _badBtn];
            lbl.text = @"不好";
            break;
            
        case Sick:
            _sickBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _sickBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_worse_nor.png" Consider:NO]];
            [_sickBtn setImage:[ImageUtil getImageByImageNamed: @"feedback_worse_nor.png" Consider:NO] forState:UIControlStateNormal];
            _sickBtn.tag = Sick;
            [_sickBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _sickBtn];
            lbl.text = @"讨厌";
            break;
            
        default:
            _perfectBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, 27, 27)];
//            _perfectBtn.backgroundColor = [UIColor colorWithPatternImage:[ImUtil getImageByImageNamed:@"feedback_better_nor.png" Consider:NO]];
            [_perfectBtn setImage:[ImageUtil getImageByImageNamed:@"feedback_better_nor.png" Consider:NO ] forState:UIControlStateNormal];
            _perfectBtn.tag = Perfact;
            [_perfectBtn addTarget:self action:@selector(pressDown:) forControlEvents: UIControlEventTouchDown];
            [view addSubview: _perfectBtn];
            lbl.text = @"喜欢";
            break;
    }
    
    [lbl setFont:[UIFont systemFontOfSize:14]];
    [view addSubview:lbl];
    return view;
}

- (IBAction) pressDown: (id) sender
{
    NSLog(@"this is a test event");
    NSLog(@"the emotion %d press", [sender tag]);
    [self setEmotion:Perfact IsLight:NO];
    [self setEmotion:Good IsLight:NO];
    [self setEmotion:Normal IsLight:NO];
    [self setEmotion:Bad IsLight:NO];
    [self setEmotion:Sick IsLight:NO];
    
    [self setEmotion:[sender tag] IsLight:YES];
    
    _currentEmotion = [sender tag];
    

}

- (enum EMOTION) getEmotion
{
    return _currentEmotion;
}

- (void) setEmotion: (enum EMOTION) e IsLight: (BOOL) isLight
{
    switch (e) {
        case Perfact:
            [_perfectBtn setImage:[ImageUtil getImageByImageNamed:isLight ? @"feedback_better_fcs.png" : @"feedback_better_nor.png" Consider:NO ] forState:UIControlStateNormal];
//            _perfectBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed:isLight ? @"feedback_better_fcs.png" : @"feedback_better_nor.png" Consider:NO ]];
            break;
            
        case Good:
            [_goodBtn setImage:[ImageUtil getImageByImageNamed: isLight ? @"feedback_good_fcs.png" : @"feedback_good_nor.png" Consider:NO] forState:UIControlStateNormal];
//            _goodBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed: isLight ? @"feedback_good_fcs.png" : @"feedback_good_nor.png" Consider:NO]];
            break;
            
        case Normal:
            [_normalBtn setImage:[ImageUtil getImageByImageNamed:isLight ? @"feedback_general_fcs.png" : @"feedback_general_nor.png" Consider:NO] forState:UIControlStateNormal];
//            _normalBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed:isLight ? @"feedback_general_fcs.png" : @"feedback_general_nor.png" Consider:NO]];
            
            break;
            
        case Bad:
            [_badBtn setImage:[ImageUtil getImageByImageNamed: isLight ? @"feedback_bad_fcs.png" : @"feedback_bad_nor.png" Consider:NO] forState:UIControlStateNormal];
//            _badBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed: isLight ? @"feedback_bad_fcs.png" : @"feedback_bad_nor.png" Consider:NO]];
            break;
            
        case Sick:
            [_sickBtn setImage:[ImageUtil getImageByImageNamed: isLight ? @"feedback_worse_fcs.png" : @"feedback_worse_nor.png" Consider:NO] forState:UIControlStateNormal];
//            _sickBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed: isLight ? @"feedback_worse_fcs.png" : @"feedback_worse_nor.png" Consider:NO]];
            break;
            
        default:
            [_perfectBtn setImage:[ImageUtil getImageByImageNamed:isLight ? @"feedback_better_fcs.png" : @"feedback_better_nor.png" Consider:NO ] forState:UIControlStateNormal];

//            _perfectBtn.backgroundColor = [UIColor colorWithPatternImage:
//                                           [ImUtil getImageByImageNamed: isLight ? @"feedback_better_fcs.png" :  @"feedback_better_nor.png" Consider:NO]];
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
