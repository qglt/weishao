//
//  CommentView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-24.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CommentView.h"
#import "ImUtils.h"
#define COUNT 20
@implementation CommentView
@synthesize img5,img4,img3,img2,img1,quickReview;
@synthesize textField;
@synthesize starScroreDelegate;

- (id)initWithFrame:(CGRect)frame withStarComment:(BaseAppInfo *)info
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.info = info;
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    NSLog(@"self.info.comment.isCommented = %d",self.info.comment.isCommented);
    if (self.info.comment.isCommented) {
        //如果已经星评过
        //滑动后的值星评值要提交，及UI要相应调整
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(0, 0, 320, 25);
        [label2 setText:@"快评"];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12];
        label2.textColor = [ImUtils colorWithHexString:@"#808080"];
        label2.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
        [self addSubview:label2];
        
        quickReview = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 320, 60)];
        quickReview.backgroundColor = [UIColor whiteColor];
        [self addSubview:quickReview];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 320, 1)];
        lineLabel.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
        [quickReview addSubview:lineLabel];

        
        textField = [[UITextView alloc] initWithFrame:CGRectMake(0, 85, 320, self.frame.size.height-60)];
        
        textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        textField.font = [UIFont fontWithName:@"STHeitiSC-Thin"  size:15];
        textField.delegate = self;
        self.textField.text = @"请在此输入……";
        self.textField.returnKeyType = UIReturnKeyDefault;
        self.textField.scrollEnabled = YES;
        textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:textField];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(254, 190/2, 36, 36)];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.text  = @"140";
        _countLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
        _countLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [self.textField addSubview:_countLabel];

        
    }else{
        //如果没有星评过
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
        label.text = @"星评";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12];
        label.textColor = [ImUtils colorWithHexString:@"#808080"];
        label.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
        [self addSubview:label];
        
        UIImage *imag1 = [self reSizeImage:[UIImage imageNamed:@"empty_star.png"] toSize:CGSizeMake(12, 12)];
        UIImage *imag2 = [self reSizeImage:[UIImage imageNamed:@"solid_star.png"] toSize:CGSizeMake(12, 12)];
        //滑动后的值星评值要提交，及UI要相应调整
        AMRatingControl *ratingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(6, 6) emptyImage:imag1 solidImage:imag2 andMaxRating:5];
        [ratingControl setRating:0];
        ratingControl.backgroundColor = [UIColor whiteColor];
        ratingControl.ratingDelegate = self;
        ratingControl.frame = CGRectMake(120, 25+16.5, 80, 45);
        [self addSubview:ratingControl];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(0, 25+45, 320, 25);
        [label2 setText:@"快评"];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12];
        label2.textColor = [ImUtils colorWithHexString:@"#808080"];
        label2.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
        [self addSubview:label2];
        
        
        quickReview = [[UIView alloc] initWithFrame:CGRectMake(0, 95, 320, 60)];
        [self addSubview:quickReview];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 320, 1)];
        lineLabel.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
        [quickReview addSubview:lineLabel];

        
        textField = [[UITextView alloc] initWithFrame:CGRectMake(0, 155, 320, self.frame.size.height-60)];
        
        textField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        textField.font = [UIFont fontWithName:@"STHeitiSC-Thin"  size:15];
        textField.delegate = self;
        self.textField.text = @"请在此输入……";
        self.textField.returnKeyType = UIReturnKeyDefault;
        self.textField.scrollEnabled = YES;
        textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:textField];
        
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(254, 190/2, 36, 36)];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.text  = @"140";
        _countLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
        _countLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [self.textField addSubview:_countLabel];

        
        
}

    
    

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [quickReview addGestureRecognizer:singleTap];
    
    self.userInteractionEnabled = YES;
    img1 = [UIButton buttonWithType:UIButtonTypeCustom];
    img1.frame = CGRectMake(30, 10, 40, 40);
    [img1 setBackgroundImage:[UIImage imageNamed:@"brow1.png"] forState:UIControlStateNormal];
    [img1 setBackgroundImage:[UIImage imageNamed:@"brow_height1.png"] forState:UIControlStateSelected];
    [img1 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    img1.tag = 1001;
    
    img2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [img2 setBackgroundImage:[UIImage imageNamed:@"brow2.png"] forState:UIControlStateNormal];
    [img2 setBackgroundImage:[UIImage imageNamed:@"brow_height2.png"] forState:UIControlStateSelected];
    [img2 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    img2.tag = 1002;
    img2.frame = CGRectMake(85, 10, 40, 40);
    
    img3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [img3 setBackgroundImage:[UIImage imageNamed:@"brow3.png"] forState:UIControlStateNormal];
    [img3 setBackgroundImage:[UIImage imageNamed:@"brow_height3.png"] forState:UIControlStateSelected];
    [img3 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    img3.tag = 1003;
    img3.frame = CGRectMake(140, 10, 40, 40);
    
    img4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [img4 setBackgroundImage:[UIImage imageNamed:@"brow4.png"] forState:UIControlStateNormal];
    [img4 setBackgroundImage:[UIImage imageNamed:@"brow_height4.png"] forState:UIControlStateSelected];
    [img4 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    img4.tag = 1004;
    img4.frame = CGRectMake(195, 10, 40, 40);
    
    img5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [img5 setBackgroundImage:[UIImage imageNamed:@"brow5.png"] forState:UIControlStateNormal];
    [img5 setBackgroundImage:[UIImage imageNamed:@"brow_height5.png"] forState:UIControlStateSelected];
    [img5 addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    img5.tag = 1005;
    img5.frame = CGRectMake(250, 10, 40, 40);
    
    [quickReview addSubview:img1];
    [quickReview addSubview:img2];
    [quickReview addSubview:img3];
    [quickReview addSubview:img4];
    [quickReview addSubview:img5];
    
    
    
}
- (void)button:(UIButton *)sender
{
    if (sender.tag == 1001) {
        [self updateTextView:@"呵呵！太好玩！太有趣了!大家都来玩吧！"];
        sender.selected = YES;
        img2.selected = NO;
        img3.selected = NO;
        img4.selected = NO;
        img5.selected = NO;
    } else if (sender.tag == 1002)
    {
        [self updateTextView:@"哇哦！好喜欢耶～"];
        sender.selected = YES;
        img1.selected = NO;
        img3.selected = NO;
        img4.selected = NO;
        img5.selected = NO;
    } else if (sender.tag == 1003)
    {
        [self updateTextView:@"嗯，很有用呢！学习学习～"];
        sender.selected = YES;
        img1.selected = NO;
        img2.selected = NO;
        img4.selected = NO;
        img5.selected = NO;
    } else if (sender.tag == 1004)
    {
        [self updateTextView:@"一般般，没啥意思！"];
        sender.selected = YES;
        img1.selected = NO;
        img2.selected = NO;
        img3.selected = NO;
        img5.selected = NO;
    } else if (sender.tag == 1005)
    {
        [self updateTextView:@"不用好，不咋D！"];
        sender.selected = YES;
        img1.selected = NO;
        img2.selected = NO;
        img3.selected = NO;
        img4.selected = NO;
    }
    
    
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}
- (void)updateTextView:(NSString *)str
{
    if ([textField.text isEqualToString:@"请在此输入……"]) {
        textField.text = @" ";
    }
    textField.text = @" ";
    textField.text = str;
    _countLabel.text = [NSString stringWithFormat:@"%d",COUNT-[str length]];

    
}
- (void)singleTap:(UITapGestureRecognizer *)singleTap
{
    [self exitkeyboard];
}
- (void)exitkeyboard
{
    [textField resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
    if ([self.textField.text isEqualToString:@"请在此输入……"]) {
        self.textField.text = @" ";
    }
    float offset = 0.0f;
    if (self) {
        
        if (self.info.comment.isCommented) {
            offset = -25.0f;
        } else {
            offset = -70.0f;
            
        }
    }
    NSTimeInterval animationDurtion = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDurtion];
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    CGRect rect = CGRectMake(0.0f, offset, width, height);
    NSLog(@"textViewDidBeginEditing rect.origin.y = %f",rect.origin.y);
    NSLog(@"textViewDidBeginEditing rect.size.height = %f",rect.size.height);
    
    self.frame = rect;
    [UIView commitAnimations];
    if ([self.textField.text length] >COUNT) {
        _countLabel.text = [NSString stringWithFormat:@"%d",COUNT-[self.textField.text length]];
        
    } else {
        _countLabel.text = [NSString stringWithFormat:@"-%d",COUNT-[self.textField.text length]];
        
    }

    

}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    float offset = 0.0f;
//    if (self) {
//        //这里面要判断。如果有星评为100，如果无星评为40;
//        if (self.info.comment.isCommented) {
//            offset = +25.0f;
//        } else {
//            offset = +75.0f;
//        }
//    }
    NSTimeInterval animationDurtion = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDurtion];
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    CGRect rect = CGRectMake(0.0f, offset, width, height);
    self.frame = rect;
    NSLog(@"textViewDidEndEditing rect.origin.y = %f",rect.origin.y);
    NSLog(@"textViewDidEndEditing rect.size.height = %f",rect.size.height);
    [UIView commitAnimations];
    if ([self.textField.text length] >COUNT) {
        _countLabel.text = [NSString stringWithFormat:@"%d",COUNT-[self.textField.text length]];

    } else {
        _countLabel.text = [NSString stringWithFormat:@"-%d",COUNT-[self.textField.text length]];

    }
    
    

}
- (BOOL)textView:(UITextView *)textFiel shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //按回车可以改变
    if ([text isEqualToString:@"n"])
    {
        return YES;
    }
    
    NSString * toBeString = [textFiel.text stringByReplacingCharactersInRange:range withString:text]; //得到输入框的内容
    //判断是否时我们想要限定的那个输入框
    if (self.textField == textFiel)
    {
        //string就是此时输入的那个字符 textField就是此时正在输入的那个输入框 返回YES就是可以改变输入框的值 NO相反
        if ([toBeString length] > COUNT+1) { //如果输入框内容大于140则弹出警告
//            textField.text = [toBeString substringToIndex:140];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"超过最大字数不能输入了" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
            if ([self.textField.text length] <COUNT) {
                _countLabel.text = [NSString stringWithFormat:@"%d",COUNT-[self.textField.text length]];
                
            } else {
                _countLabel.text = [NSString stringWithFormat:@"-%d",COUNT-[self.textField.text length]];
                
            }

            _countLabel.textColor = [UIColor redColor];
        }else if([toBeString length] <8)
        {
            img1.selected = NO;
            img2.selected = NO;
            img3.selected = NO;
            img4.selected = NO;
            img5.selected = NO;
        }
    }
    if ([self.textField.text length] >COUNT) {
        _countLabel.text = [NSString stringWithFormat:@"%d",COUNT-[self.textField.text length]];
        
    } else {
        _countLabel.text = [NSString stringWithFormat:@"-%d",COUNT-[self.textField.text length]];
        
    }

    return YES;

}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - RatingContrlDelegate

- (void) commentRating:(NSInteger)rating
{
    NSLog(@"rating = %d",rating);
    [starScroreDelegate score:rating];
}
@end
