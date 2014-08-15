//
//  TileView.m
//  IPhoneTest
//
//  Created by Lovells on 13-8-27.
//  Copyright (c) 2013年 Luwei. All rights reserved.
//

#import "TileView.h"
#import "ImUtils.h"
#import "TQRichTextView.h"
#define kLabelWidth     30.f
#define kLabelHeight    30.f
#import "ImUtils.h"
#import "AppNameView.h"
@interface TileView ()<TQRichTextViewDelegate>
@property (nonatomic,strong) TQRichTextView *richTextView;

@end

@implementation TileView

- (id)initWithTarget:(id)target action:(SEL)action info:(BaseAppInfo *)info editable:(BOOL)removable isLongPress:(BOOL) isLongPress;
{
    self = [super init];
    if (self)
    {
//        self.backgroundColor = [UIColor colorWithRed:0.605 green:0.000 blue:0.007 alpha:1.000];
//        self.backgroundColor = [UIColor clearColor];

        self.info = info;
        //创建时初始值为不可编辑
        self.isEditing = NO;
        //确定是否可编辑
        self.isRemovable = removable;
        //是否可长按
        self.isLongPressEdit =isLongPress;
        [self createLabelAndAddToSelf:self.info];

        if (self.isLongPressEdit) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
            [self addGestureRecognizer:longPress];
            longPress = Nil;
        }
        
        
        
        if (self.isRemovable) {
            self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            float w = 20;
            float h = 20;
            [self.deleteButton setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h)];
            [self.deleteButton setImage:[UIImage imageNamed:@"leftHeaderDeleteNormal.png"] forState:UIControlStateNormal];
            [self.deleteButton setImage:[UIImage imageNamed:@"leftHeaderDeleteSelected.png"] forState:UIControlStateHighlighted];
            self.deleteButton.backgroundColor = [UIColor clearColor];
            [self.deleteButton addTarget:self action:@selector(removeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.deleteButton setHidden:YES];
            [self addSubview:self.deleteButton];
        }

    }
    return self;
}
- (void) pressedLong:(UILongPressGestureRecognizer *) gestureRecognizer{
    
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                _long_point = [gestureRecognizer locationInView:self];
                [self.delegate gridItemDidEnterEditingMode:self];
                //放大这个item
                [self setAlpha:1.0];
                NSLog(@"press long began");
                break;
            case UIGestureRecognizerStateEnded:
                _long_point = [gestureRecognizer locationInView:self];
                [self.delegate gridItemDidEndMoved:self withLocation:_long_point moveGestureRecognizer:gestureRecognizer];
                //变回原来大小
                [self setAlpha:0.5f];
                NSLog(@"press long ended");
                break;
            case UIGestureRecognizerStateFailed:
                NSLog(@"press long failed");
                break;
            case UIGestureRecognizerStateChanged:
                //移动
                
//                [self.delegate gridItemDidMoved:self withLocation:_long_point moveGestureRecognizer:gestureRecognizer];
                NSLog(@"press long changed");
                break;
            default:
                NSLog(@"press long else");
                break;
        }
}
- (void)createLabelAndAddToSelf:(BaseAppInfo *)info
{
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:Nil forState:0];
    button.tag = 1006;
    button.frame = CGRectMake(0, 0, 60, 60);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 10.0f;
    if (self.info.appIcon_middle) {
        [button setImage:[UIImage imageWithContentsOfFile:self.info.appIcon_middle] forState:0];
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@"app_default.png"] forState:0];

    }
    [self addSubview:button];
    
    
    _appName = [[UILabel alloc] initWithFrame:CGRectMake(0, 67.5, 60, 26)];
    _appName.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12];
    _appName.textColor = [ImUtils colorWithHexString:@"#262626"];
    _appName.numberOfLines = 0;
    _appName.textAlignment = NSTextAlignmentCenter;
    _appName.backgroundColor = [UIColor whiteColor];
//    [self addSubview:_appName];
    
    if ([info isLightApp]) {
        [self creatCoreText:info imageName:@"[lightApp]"];

    } else if ([info isNativeApp]){
        [self creatCoreText:info imageName:@"[nativeApp]"];
        
    }else if ([info isWebApp]){
        [self creatCoreText:info imageName:@"[webApp]"];
    }else if(nil){//这个应该是代登录
        
    }
}
- (void)creatCoreText:(BaseAppInfo *)info imageName:(NSString *)imageName
{
    self.richTextView = [[TQRichTextView alloc] initWithFrame:CGRectMake(0, 67.5, 60, 26)];
    self.richTextView.text = [NSString stringWithFormat:@"%@%@",imageName,info.appName];
    NSLog(@"richTextView.text = %@",self.richTextView.text);
    self.richTextView.backgroundColor = [UIColor whiteColor];
    self.richTextView.delegage = self;
    [self addSubview:self.richTextView];

}

#pragma mark - TQRichTextViewDelegate
- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run
{
    
}
- (void)richTextView:(TQRichTextView *)view touchEndRun:(TQRichTextBaseRun *)run
{
    if (run.type == richTextURLRunType)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:run.originalText]];
    }

}

- (void) buttonAction:(UIButton *)sender
{
    [self.delegate sendExpressInfoWhenTouched:self.info];

//    if ([self.delegate respondsToSelector:@selector(sendExpressInfoWhenTouched:)]) {
//        [self.delegate sendExpressInfoWhenTouched:self.info];
//    }
}

- (void) removeButtonClicked:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteCommonExpressWithExpressInfo:)]) {
        [self.delegate deleteCommonExpressWithExpressInfo:self.info];
    }
}

#pragma mark - Custom Method

- (void) enableEditing
{
    if (self.isEditing == YES) {
        return;
    }
    self.isEditing = YES;
    [self.deleteButton setHidden:NO];
    [button setEnabled:NO];
    
    CGFloat rotation = 0.03;
    
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
    shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
    
    [self.layer addAnimation:shake forKey:@"shakeAnimation"];
    
}

- (void) disableEditing
{
    [self.layer removeAnimationForKey:@"shakeAnimation"];
    [self.deleteButton setHidden:YES];
    [button setEnabled:YES];
    self.isEditing = NO;
}
@end
