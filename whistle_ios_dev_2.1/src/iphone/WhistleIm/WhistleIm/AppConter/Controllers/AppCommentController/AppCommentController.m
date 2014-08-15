//
//  AppCommentController.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppCommentController.h"
#import "AMRatingControl.h"
#import "CommentView.h"
#import "AppManager.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "NetworkBrokenAlert.h"
@interface AppCommentController ()<AppCenterDelegate,RatingContrlDelegate,CommentViewDelegate>
@end

@implementation AppCommentController
- (void)changeTheme:(NSNotification *)notification
{
//    [self createNavigationBar:NO];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavBar];
    [self initViews];
	// Do any additional setup after loading the view.
 //    [self createNavigationBar:YES];
    
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"评论" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

//- (void)leftNavigationBarButtonPressed:(UIButton *)button
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self createNavigationBar:NO];
//}
#pragma mark - setNavBar
- (void) setNavBar
{
    [self.navigationController  setNavigationBarHidden:NO animated:YES];
    
    //设置Navigation Bar颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(30/255.0) green:(175/255.0) blue:(200/255.0) alpha:1];
    UIButton *BackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 164.0, 45, 45)];
    [BackBtn setTitle:@"返回" forState:UIControlStateNormal];
	[BackBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:BackBtn];
	temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
	self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeButton setTitle:@"完成" forState:0];
    completeButton.tag = 1002;
    completeButton.frame = CGRectMake(320-45-10, 164, 45, 45);
    [completeButton addTarget:self action:@selector(completeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *completeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:completeButton];
    self.navigationItem.rightBarButtonItem = completeButtonItem;
    //标题栏
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    //加粗
    title.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20];
    title.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"评论";
    self.navigationItem.titleView = title;

}
- (void)initViews
{
    NSLog(@"isCommented = %hhd",self.info.comment.isCommented);
    self.commentView = [[CommentView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-64)withStarComment:self.info];
    self.commentView.backgroundColor = [UIColor clearColor];
    self.commentView.starScroreDelegate = self;
    [self.view addSubview:self.commentView];
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}
- (void) backAction
{
	[self.navigationController popViewControllerAnimated:YES];

}
- (void) completeButtonAction
{
    [self.commentView.textField resignFirstResponder];
    
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        
        return;
    }

    if ([self.commentView.textField.text length] >20) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"超过140最大字数" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    self.commentStr = self.commentView.textField.text;
    NSLog(@"self.starScore = %d",self.starScore);
    if (self.commentStr) {
        [[AppManager shareInstance] deliverComment:self.info comment:self.commentStr score:self.starScore callback:^(BOOL isSuccess) {
            //提示发送成功
        }];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
 }
#pragma mark - CommentViewDelegate

- (void)score:(NSInteger)starScroe
{
    self.starScore = starScroe;
}

@end
