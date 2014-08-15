//
//  WriteContentView.m
//  WhistleIm
//
//  Created by liuke on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "WriteContentView.h"
#import "FeedbackView.h"

@interface WriteContentView() <UITextViewDelegate>
{
    UITextView* _textField;
    UIView* _pv;
    BOOL _isScrollUp;//输入文字时，界面是否上移
}

@end

@implementation WriteContentView

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame withParentView: (UIView*) pv
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:[self createBackground:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self addSubview:[self createContentView:CGRectMake(10, 5, frame.size.width - 20, frame.size.height - 10)]];
//        [self setBackgroundColor:[UIColor redColor]];
        
        _pv = pv;
    }
    return self;
}

- (UIView*) createBackground: (CGRect) rect
{
    UIView* emotion = [[UIView alloc] initWithFrame:rect];
    UIImage* img = [[UIImage imageNamed:@"feedback_edit"] stretchableImageWithLeftCapWidth:20 topCapHeight:25];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = emotion.bounds;
    [imgView setUserInteractionEnabled:YES];
    [emotion addSubview:imgView];
    return emotion;
}

- (UIView*) createContentView: (CGRect) rect
{
    _textField = [[UITextView alloc] initWithFrame:rect];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.delegate = self;
    return _textField;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
//    [self animateTextField: textView up: YES];
    CGRect frame = _pv.frame;
    frame.origin.y -= 120.0f;
    _pv.frame = frame;
//    [()_pv ]
    _isScrollUp = YES;
    NSLog(@"begin editing");
}
- (void) textViewDidEndEditing
{
    if (_isScrollUp) {
        CGRect frame = _pv.frame;
        frame.origin.y += 120.0f;
        _pv.frame = frame;
        _isScrollUp = NO;
        [self endEditing:YES];
        NSLog(@"end editing");
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location >= 100) {
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [m_delegate sendText:textView.text];
}



- (NSString*) getContent
{
    return [_textField text];
}

//- (void) animateTextField: (UITextView*) textField up: (BOOL) up
//{
////    const int movementDistance = 80; // tweak as needed
////    const float movementDuration = 0.3f; // tweak as needed
////    
////    int movement = (up ? -movementDistance : movementDistance);
////    
////    [UIView beginAnimations: @"anim" context: nil];
////    [UIView setAnimationBeginsFromCurrentState: YES];
////    [UIView setAnimationDuration: movementDuration];
////    self.frame = CGRectOffset(self.frame, 0, movement);
////    [UIView commitAnimations];
//    CGRect frame = self.frame;
//    frame.origin.y -= 70;
//    self.frame = frame;
//    
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
