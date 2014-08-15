//
//  LoginView.m
//  WhistleIm
//
//  Created by liuke on 14-2-18.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LoginView.h"
#import "ImUtils.h"
#import "ImageUtil.h"
#import "AccountInfo.h"
#import <objc/runtime.h>
#import "AccountManager.h"

@interface LoginView()
{
    
    UIImageView* head_;//头像
    
    UITextField* userinput_;//用户名输入
    
    UITextField* pwd_;//密码输入
    
    UIImageView* rempwd;//记录密码
    
    UIImageView* reminv;//隐身登录
    
    int top_;//登录view的上坐标
//    CGFloat bottom_;
    BOOL keyboard_is_show;//键盘是否显示
    
    UIView* moreUserDetailView_;
    UIView* inner_MoreUserDetailView_;
    NSMutableDictionary* userViewDic_;
    
    //newer
    UIView* headView_;
    NSLayoutConstraint* headExplanConstrints_;
    NSLayoutConstraint* headShrinkConstrints_;
    CGFloat headViewExplanHegiht_;
    CGFloat headViewShrinkHegiht_;
    
    //登录部分
    UIView* loginView_;
    NSLayoutConstraint* loginConstrinets_;
    CGFloat loginHeight_;
    
    //更多账号部分
    NSLayoutConstraint* moreUserConstrints_;

    UIView* mainView_;
    NSLayoutConstraint* mainConstraints_;
    
    UIButton* moreUserBtn_;
    BOOL isOpenMoreBtn_;
    
    UIView* loadingView_;
    
    BOOL isDeleteUserState_;//是否是删除用户的状态
    NSMutableArray* deleteBtnArr_;//删除用户的uibutton集合
}

@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        isDeleteUserState_ = NO;
//        [self draw];
        mainView_ = [[UIView alloc] init];
        [mainView_ setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:mainView_];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView_]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView_)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[mainView_(%f)]", [[UIScreen mainScreen] bounds].size.height] options:0 metrics:0 views:NSDictionaryOfVariableBindings(mainView_)]];
        mainConstraints_ = [NSLayoutConstraint constraintWithItem:mainView_ attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self addConstraint:mainConstraints_];
        [self createHeadView];
        [self createOtherView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//        [self loading:YES];
    }
    return self;
}

//- (void) check
//{
//    if (!(self.head)) {
//        self.head = @"identity_man_new.png";//@"default_portrait.png";
//    }
////    if (!(self.user)) {
////        self.user = @"";
////    }
////    if (!(self.pwd)) {
////        self.pwd = @"";
////    }
//}
//
- (void) setHead:(NSString *)head
{
    if (head && ![@"" isEqualToString:head]) {
        [self setImg:head_ image:head];
    }else{
        [self setImg:head_ image:@"identity_man_new.png"];
    }

}
//
- (void) setremPwd:(BOOL)rememberPwd
{
    _rememberPwd = rememberPwd;
    if (rememberPwd) {
        [self setImg:rempwd image:@"moreSelected.png"];
    }else{
        //[rempwd setImage:[self ]];
        [self setImg:rempwd image:@"uncheck.png"];
    }
}
//
- (void) setremInv:(BOOL)invisibleLogin
{
    _invisibleLogin = invisibleLogin;
    if (invisibleLogin) {
        [self setImg:reminv image:@"moreSelected.png"];
    }else{
        //[rempwd setImage:[self ]];
        [self setImg:reminv image:@"uncheck.png"];
    }
}
//
- (void) setImg:(UIImageView*) view image:(NSString *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
            UIImage* img = [UIImage imageWithContentsOfFile:image];
            if (!img) {
                img = [ImageUtil getImageByImageNamed:image Consider:NO];
                if (!img) {
                    img = [UIImage imageNamed:image];
                }
            }
            if (img) {
                [view setImage:img];            
            }

        }
    });
}
//
- (void) setUser:(NSString *)user
{
    _user = user;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (user) {
            [userinput_ setText:user];
        }else{
            [userinput_ setText:@""];
        }
    });
}
//
- (void) setPwd:(NSString *)pwd
{
    _pwd = pwd;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pwd) {
            [pwd_ setText:pwd];
        }else{
            [pwd_ setText:@""];
        }
    });
}

//- (void) draw
//{
//    [self setBackground];
//    centerView_ = [self setCenterView];
//    [self setLoginView];
//    [self check];
//

//}


//
- (UIView*) createSplitLine
{
    UIView* line = [[UIView alloc] init];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    line.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    return line;
}

- (UIView*) createHeadCircleView
{
    UIView* view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor greenColor];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    //164
    UIImageView* outCircle = [[UIImageView alloc] init];//]WithFrame:CGRectMake(0, 0, 82, 82)];
    [outCircle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [outCircle setImage:[ImageUtil getImageByImageNamed:@"headoutcircle.png" Consider:NO]];
    [view addSubview:outCircle];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[outCircle(82)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(outCircle)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[outCircle(82)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(outCircle)]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:outCircle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:outCircle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    head_ = [[UIImageView alloc] init];
    [head_ setTranslatesAutoresizingMaskIntoConstraints:NO];
    [head_ setImage:[UIImage imageNamed:@"identity_man_new.png"]];
    head_.layer.cornerRadius = 75/2.f;
    head_.layer.masksToBounds = YES;
    [view addSubview:head_];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[head_(75)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(head_)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[head_(75)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(head_)]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:head_ attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:head_ attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    return view;
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    if (keyboard_is_show) {
        keyboard_is_show = NO;
        if (is4Inch) {
            top_ += 100;
        }else{
            top_ += 160;
        }
        [UIView animateWithDuration:0.3 animations:^{
            mainConstraints_.constant = top_;
            [self layoutIfNeeded];
        }];
    }
}
//
-(void)keyboardWillShow:(NSNotification *)notification
{
    if (!keyboard_is_show) {
        keyboard_is_show = YES;
        if (is4Inch) {
            top_ -= 100;
        }else{
            top_ -= 160;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            mainConstraints_.constant = top_;
            [self layoutIfNeeded];
        }];
    }
}

- (void) userChanged:(id) sender
{
    [self showDeleteIcon:NO];
    UITextField* text = (UITextField*)sender;
    pwd_.text = @"";
    [self setImg:head_ image:@"identity_man_new.png"];
    [userViewDic_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView* v = (UIView*) obj;
        v.alpha = 0.0;
    }];
    //设置备选头像
    if (userViewDic_) {
        UIView* view = [userViewDic_ objectForKey:text.text];
        if (view) {
            //设置选中状态
            view.alpha = 0.5;
        }
    }
    
    if (self.currentAccount && [self.currentAccount.userName isEqualToString:text.text]) {
        self.user = self.currentAccount.userName;
        self.pwd = self.currentAccount.password;
        self.head = self.currentAccount.headImg;
        self.rememberPwd = self.currentAccount.savePasswd;
        return;
    }else{
        for (AccountInfo* acc in self.moreAccount) {
            if ([acc.userName isEqualToString:text.text]) {
                self.user = acc.userName;
                self.pwd = acc.password;
                self.head = acc.headImg;
                self.rememberPwd = acc.savePasswd;
                return;
            }
        }
    }
    
}
- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//
- (UIView*) createLogBtnView
{
    UIButton* btn = [[UIButton alloc] init];
    [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    btn.backgroundColor = [ImUtils colorWithHexString:@"#2f87b9"];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [btn.titleLabel setFont:font];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setBackgroundImage:[self imageFromColor:[ImUtils colorWithHexString:@"006fad"]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
//
- (void) login:(id) sender
{
    if (isOpenMoreBtn_) {
        [self more:moreUserBtn_];
    }
    [self.delegate login:userinput_.text pwd:pwd_.text savepwd:self.rememberPwd invisible:self.invisibleLogin];
    [userinput_ endEditing:YES];
    [pwd_ endEditing:YES];
}
//
- (UIView*) createExtraView
{
    UIView* view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIButton* lview = [[UIButton alloc] init];
    [lview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:lview];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[lview(==120)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(lview)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lview(==39)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(lview)]];
    [lview addTarget:self action:@selector(rememberPwd:) forControlEvents:UIControlEventTouchUpInside];

    rempwd = [[UIImageView alloc] init];
    [rempwd setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setImg:rempwd image:@"uncheck.png"];
    UILabel* rempwd_label = [[UILabel alloc] init];
    [rempwd_label setText:@"记住密码"];
    rempwd_label.backgroundColor = [UIColor clearColor];
    [rempwd_label setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f]];
    [rempwd_label setTextColor:[ImUtils colorWithHexString:@"#2f87b9"]];
    [rempwd_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lview addSubview:rempwd_label];
    [lview addSubview:rempwd];
//
    [lview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-27-[rempwd(==15)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rempwd)]];
    [lview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[rempwd(15)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rempwd)]];
    [lview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rempwd_label]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rempwd_label)]];
     [lview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rempwd]-10-[rempwd_label]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rempwd, rempwd_label)]];
    
    
    UIButton* rview = [[UIButton alloc] init];
    [rview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:rview];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rview(==120)]-15-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rview)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rview(==39)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(rview)]];
    [rview addTarget:self action:@selector(rememberInv:) forControlEvents:UIControlEventTouchUpInside];

    reminv = [[UIImageView alloc] init];
    [reminv setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setImg:reminv image:@"uncheck.png"];
    [rview addSubview:reminv];
    
    UILabel* reminv_label = [[UILabel alloc] init];
    [reminv_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    reminv_label.backgroundColor = [UIColor clearColor];
    [reminv_label setText:@"隐身登录"];
    [reminv_label setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f]];
    [reminv_label setTextColor:[ImUtils colorWithHexString:@"#2f87b9"]];
    [rview addSubview:reminv_label];

//    [self layoutCenterY:rview subview:reminv_label height:39];
//    [self layoutCenterY:rview subview:reminv height:15];
//    
    [rview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-27-[reminv(==15)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(reminv)]];
    [rview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[reminv]-10-[reminv_label]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(reminv, reminv_label)]];
    [rview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[reminv(15)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(reminv)]];
    [rview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[reminv_label]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(reminv_label)]];

    
    return view;
}
//
- (void) rememberPwd:(id) sender
{
    self.rememberPwd = !self.rememberPwd;
}

- (void) rememberInv:(id) sender
{
    self.invisibleLogin = !self.invisibleLogin;
}

- (void) userClick:(id) sender
{
    UIButton* btn = (UIButton*) sender;
    AccountInfo* user = objc_getAssociatedObject(btn, @"obj_connect_account");
    UIView* head = objc_getAssociatedObject(btn, @"obj_connect_view");
    self.user = user.userName;
    self.pwd = user.password;
    self.rememberPwd = user.savePasswd;
    self.head = user.headImg;
    [userViewDic_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView* v = (UIView*) obj;
        v.alpha = 0.0;
    }];
    head.alpha = 0.5;
}

- (void) longPress:(id) sender
{
    [self showDeleteIcon:YES];
}

- (void) showDeleteIcon:(BOOL) show
{
    isDeleteUserState_ = show;
    for (UIButton* btn in deleteBtnArr_) {
        btn.hidden = !show;
    }
}

- (void) deleteUser:(id) sender
{
    UIButton* btn = (UIButton*) sender;
    AccountInfo* acc = objc_getAssociatedObject(btn, @"obj_delete_account");//objc_setAssociatedObject(view, @"obj_connect_account", user, OBJC_ASSOCIATION_RETAIN);
    [self.delegate deleteAccount:acc.userName];
}
- (UIView*) createOneUserView:(CGRect) rect account:(AccountInfo*) user
{
    UIButton* view = [[UIButton alloc] initWithFrame:rect];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [view addGestureRecognizer:longPress];
    
    UIImageView *head = [[UIImageView alloc] init];
//
    if (user.headImg && ![user.headImg isEqualToString:@""]) {
        [self setImg:head image:user.headImg];
    }else{
        [self setImg:head image:@"identity_man_new.png"];
    }
    head.layer.cornerRadius = 55 / 2.0;
    head.layer.masksToBounds = YES;
    [head setTranslatesAutoresizingMaskIntoConstraints:NO];
    [head setUserInteractionEnabled:NO];
    [view addSubview:head];
    
    
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[head(55)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(head)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[head(55)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(head)]];

    UIView* foreView = [[UIView alloc] init];
    [foreView setTranslatesAutoresizingMaskIntoConstraints:NO];
    foreView.layer.cornerRadius = 55 / 2.0;
    foreView.layer.masksToBounds = YES;
    if ([user.userName isEqualToString:self.currentAccount.userName]) {
        foreView.alpha = 0.5;
    }else{
        foreView.alpha = 0.0;
    }
    foreView.backgroundColor = [UIColor blackColor];
    [head addSubview:foreView];
    [head addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[foreView(55)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(foreView)]];
    [head addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[foreView(55)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(foreView)]];

    [view addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(view, @"obj_connect_account", user, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(view, @"obj_connect_view", foreView, OBJC_ASSOCIATION_RETAIN);
    [userViewDic_ setObject:foreView forKey:user.userName];
    
    
    UIButton* delete = [[UIButton alloc] init];
    objc_setAssociatedObject(delete, @"obj_delete_account", user, OBJC_ASSOCIATION_RETAIN);
    [delete setImage:[UIImage imageNamed:@"delete_button"] forState:UIControlStateNormal];
    [delete setImage:[UIImage imageNamed:@"delete_button_height"] forState:UIControlStateHighlighted];
    [delete setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:delete];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[delete(20)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(delete)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[delete(20)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(delete)]];
    [delete addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
    delete.hidden = !isDeleteUserState_;
    if (!deleteBtnArr_) {
        deleteBtnArr_ = [[NSMutableArray alloc] init];
    }
    [deleteBtnArr_ addObject:delete];
    return view;
}

- (UIView*) createMoreUserViewDetail:(BOOL) isDelete
{
    UIView * view = [[UIView alloc] init];
    userViewDic_ = [[NSMutableDictionary alloc] initWithCapacity:self.moreAccount.count];
    if (isDelete) {
        
    }else{
        //没有删除状态
        if (self.moreAccount){
            if (self.moreAccount.count < 4) {
                //居中
                //55*n+35*（n-1）=90*n-35
                int left = ([[UIScreen mainScreen] bounds].size.width - 90 * (self.moreAccount.count) + 35) / 2;
                for(int i = 0; i < self.moreAccount.count; ++i){
                    AccountInfo* acc = (AccountInfo*)(self.moreAccount[i]);
                    CGRect rect = CGRectMake(left + i * 90, 8, 59, 59);
                    UIView* one = [self createOneUserView:rect account:acc];
                    [view addSubview:one];
                }
            }else{
                //左对齐
                int left = 25;
                int n = self.moreAccount.count;
                UIScrollView* sv = [[UIScrollView alloc] init];
                [sv setTranslatesAutoresizingMaskIntoConstraints:NO];
                sv.showsHorizontalScrollIndicator = NO;
                sv.showsVerticalScrollIndicator = NO;
                sv.contentSize = CGSizeMake(left + 55 * n + (n - 1) * 35 + 10, 79);//CGRectMake(0, 0, left + 55 * n + (n - 1) * 35, 79);
                [view addSubview:sv];
                [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sv]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(sv)]];
                [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sv]-0-|" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(sv)]];
                for(int i = 0; i < self.moreAccount.count; ++i){
                    AccountInfo* acc = (AccountInfo*)(self.moreAccount[i]);
                    CGRect rect = CGRectMake(left + i * 90, 8, 59, 59);
                    UIView* one = [self createOneUserView:rect account:acc];
                    [sv addSubview:one];
                }

            }
        }
    }
    return view;
}
//
- (void) setUsers:(AccountInfo *)currentAccount
{
    _currentAccount = currentAccount;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (inner_MoreUserDetailView_) {
            [inner_MoreUserDetailView_ removeFromSuperview];
        }
        inner_MoreUserDetailView_ = [self createMoreUserViewDetail:NO];
        [inner_MoreUserDetailView_ setTranslatesAutoresizingMaskIntoConstraints:NO];
        [moreUserDetailView_ addSubview:inner_MoreUserDetailView_];
        [moreUserDetailView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[inner_MoreUserDetailView_]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(inner_MoreUserDetailView_)]];
        [moreUserDetailView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inner_MoreUserDetailView_]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(inner_MoreUserDetailView_)]];
        
    });
}

//
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [userinput_ endEditing:YES];
    [pwd_ endEditing:YES];
    [self showDeleteIcon:NO];
}

//头像部分的view
- (UIView*) createHeadView
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [ImUtils colorWithHexString:@"#E6E6E6"];
//    view.backgroundColor = [UIColor yellowColor];
//    CGFloat height = 374/2;
    CGFloat top = 80;
    CGFloat heigth = 90;//头像框大小
    if (isIOS7) {
    }else{
        top -= 20;
    }
    if (is4Inch) {
        top += 44;
    }
    
    headViewExplanHegiht_ = [[UIScreen mainScreen] bounds].size.height;
    headViewShrinkHegiht_ = top * 2 + heigth;
    
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self addSubview:view];
    [mainView_ addSubview:view];
    
    [mainView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [mainView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    //垂直
    if (!headExplanConstrints_) {
        headExplanConstrints_ = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant: headViewShrinkHegiht_];
    }
    
    [mainView_ addConstraint:headExplanConstrints_];
    
    
    UIView* btn = [[UIView alloc] init];
    [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view addSubview:btn];
//    [btn addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn(128)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(btn)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[btn(128)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(btn)]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    UIView* head = [self createHeadCircleView];
    [btn addSubview:head];
    
    [btn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[head(82)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(head)]];
    [btn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[head(82)]" options:0 metrics:Nil views:NSDictionaryOfVariableBindings(head)]];
    [btn addConstraint:[NSLayoutConstraint constraintWithItem:head attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [btn addConstraint:[NSLayoutConstraint constraintWithItem:head attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    loadingView_ = [[UIView alloc] init];
    [loadingView_ setTranslatesAutoresizingMaskIntoConstraints:NO];
    loadingView_.alpha = 0;
    [btn addSubview:loadingView_];
    [btn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[loadingView_]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(loadingView_)]];
    [btn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[loadingView_]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(loadingView_)]];
    
    UIImageView* loading = [[UIImageView alloc] init];
    loading.alpha = 0.0;
    [loading setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loading setImage:[UIImage imageNamed:@"loading"]];
    [loadingView_ addSubview:loading];
    [loadingView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[loading]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(loading)]];
    [loadingView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[loading]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(loading)]];

    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        loading.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    return view;
}
static BOOL is_show_ = NO;
- (void) loading:(BOOL) isshow
{
    if (isshow == is_show_) {
        return;
    }
    if (isshow) {
        [self headViewExpand];
    }else{
        [self headViewShrink];
    }
    is_show_ = isshow;
}


//头像部分扩张，为loading效果
- (void) headViewExpand
{
    [UIView animateWithDuration:0.3 animations:^{
        if (isIOS7) {
            headExplanConstrints_.constant = headViewExplanHegiht_;
        }else{
            headExplanConstrints_.constant = headViewExplanHegiht_ - 20;
        }
        loginConstrinets_.constant = loginHeight_;
        [self layoutIfNeeded];
    }];
    loadingView_.alpha = 1;
}
//头像部分收缩，为正常登录页面效果
- (void) headViewShrink
{
    [UIView animateWithDuration:0.3 animations:^{
        headExplanConstrints_.constant = headViewShrinkHegiht_;
        loginConstrinets_.constant = 0;
        [self layoutIfNeeded];
    }];
    loadingView_.alpha = 0;
}

- (void) createOtherView
{
    [self createLoginView];
    [self createUserTextView];
    [self createMoreUserView];
    [self createPwdAndSavePwdView];
}

- (UIView*) createLoginView
{
    UIView* view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self addSubview:view];
    [mainView_ addSubview:view];
    
//    view.backgroundColor = [UIColor blueColor];
    
    CGFloat bottom;
    if (is4Inch) {
        bottom = 674 / 2;
    }else{
        bottom = 586 / 2;
    }
    loginHeight_ = bottom;
    [mainView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [mainView_ addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:bottom]];
    loginConstrinets_ = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:mainView_ attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [mainView_ addConstraint: loginConstrinets_];
    loginView_ = view;
    return view;
}

- (UIView*) createUserTextView
{
    UIView* view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginView_ addSubview:view];
   
    UIView* sp1 = [self createSplitLine];
    [view addSubview:sp1];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp1]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp1)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sp1(==0.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp1)]];
    [view addSubview:sp1];
    
    UIView* user = [[UIView alloc] init];
    [user setTranslatesAutoresizingMaskIntoConstraints:NO];
    user.backgroundColor = [UIColor whiteColor];
    [view addSubview:user];

    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[user]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(user)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sp1]-0-[user(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp1, user)]];
    
    userinput_ = [[UITextField alloc] init];
    [userinput_ setTranslatesAutoresizingMaskIntoConstraints:NO];
    userinput_.autocorrectionType = UITextAutocorrectionTypeNo;
    userinput_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userinput_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userinput_.textAlignment = NSTextAlignmentCenter;
    [userinput_ setPlaceholder:@"用户名"];
    [userinput_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
    [userinput_ setTextColor:[ImUtils colorWithHexString:@"#262626"]];
    [userinput_ setValue:[ImUtils colorWithHexString:@"#d9d9d9"] forKeyPath:@"_placeholderLabel.textColor"];
    userinput_.backgroundColor = [UIColor whiteColor];
    [userinput_ addTarget:self action:@selector(userChanged:) forControlEvents:UIControlEventEditingChanged];
    [userinput_ addTarget:self action:@selector(userEnter:) forControlEvents:UIControlEventTouchDown];
//
    [user addSubview:userinput_];

    UIButton* more = [[UIButton alloc] init];
    [more setTranslatesAutoresizingMaskIntoConstraints:NO];
    [more setImage:[ImageUtil getImageByImageNamed:@"login_more_close.png" Consider:NO] forState:UIControlStateNormal];
    [more setImage:[ImageUtil getImageByImageNamed:@"login_more_close_click.png" Consider:NO] forState:UIControlStateHighlighted];
    [more addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [user addSubview:more];

    [user addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-45-[userinput_]-0-[more(==45)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(userinput_, more)]];
    [user addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[userinput_]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(userinput_)]];
    [user addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[more]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(more)]];

    UIView* sp2 = [self createSplitLine];
    [view addSubview:sp2];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp2]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sp2)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[user]-0-[sp2(==0.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(user, sp2)]];


    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view(45)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
    
    moreUserBtn_ = more;
    return view;
}

- (void) more:(id) sender
{
    UIButton* more = (UIButton*) sender;
    static BOOL is_open = YES;
    isOpenMoreBtn_ = is_open;
    [UIView animateWithDuration:0.3 animations:^{
        [self openMoreUserView:is_open button:more];
        is_open = !is_open;
    }];
}

- (void) userEnter:(id) sener
{
    [self showDeleteIcon:NO];
}

- (BOOL) openMoreUserView:(BOOL) open button:(UIButton*) btn
{
    [UIView animateWithDuration:0.3 animations:^{
        if (open) {
            moreUserConstrints_.constant = 79.5 + 45;
            [btn setImage:[ImageUtil getImageByImageNamed:@"login_more.png" Consider:NO] forState:UIControlStateNormal];
            [btn setImage:[ImageUtil getImageByImageNamed:@"login_more_click.png" Consider:NO] forState:UIControlStateHighlighted];
            
        }else{
            [btn setImage:[ImageUtil getImageByImageNamed:@"login_more_close.png" Consider:NO] forState:UIControlStateNormal];
            [btn setImage:[ImageUtil getImageByImageNamed:@"login_more_close_click.png" Consider:NO] forState:UIControlStateHighlighted];
            moreUserConstrints_.constant = 45;
        }
        [self layoutIfNeeded];
    }];
    return !open;
}

- (UIView*) createMoreUserView
{
    UIView* view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.backgroundColor = [UIColor whiteColor];
    [loginView_ addSubview:view];

    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];
    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-45-[view(79.5)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(view)]];

    UIView* sp = [self createSplitLine];
    [view addSubview:sp];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sp]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(sp)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sp(0.5)]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(sp)]];
    moreUserDetailView_ = view;
    return view;
}
- (UIView*) createPwdAndSavePwdView
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [ImUtils colorWithHexString:@"#E6E6E6"];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    view.backgroundColor = [UIColor greenColor];
    [loginView_ addSubview:view];
    
    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    [loginView_ addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: @"V:[view(%f)]", loginHeight_ - 45] options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    moreUserConstrints_ = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:loginView_ attribute:NSLayoutAttributeTop multiplier:1 constant:45];
    [loginView_ addConstraint:moreUserConstrints_];
    
    
    
    UIView* p = [[UIView alloc] init];
    [p setTranslatesAutoresizingMaskIntoConstraints:NO];
    p.backgroundColor = [UIColor whiteColor];
    [view addSubview:p];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[p]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(p)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[p(==44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(p)]];
    
    
    
    pwd_ = [[UITextField alloc] init];
    pwd_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pwd_.textAlignment = NSTextAlignmentCenter;
    pwd_.secureTextEntry = YES;
    [pwd_ setTranslatesAutoresizingMaskIntoConstraints:NO];
    [pwd_ setPlaceholder:@"密码"];
    [pwd_ setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
    [pwd_ setTextColor:[ImUtils colorWithHexString:@"#262626"]];
    [pwd_ setValue:[ImUtils colorWithHexString:@"#d9d9d9"] forKeyPath:@"_placeholderLabel.textColor"];
    [pwd_ addTarget:self action:@selector(userEnter:) forControlEvents:UIControlEventTouchDown];
    [p addSubview:pwd_];

    
    [p addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[pwd_]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pwd_)]];
    [p addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pwd_]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pwd_)]];
    
    UIView* login = [self createLogBtnView];
    [view addSubview:login];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[login]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(login)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[p]-10-[login(39)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(p, login)]];
    
    UIView* extra = [self createExtraView];
    [view addSubview:extra];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[extra]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(extra)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[login]-23-[extra(39)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(login, extra)]];
    
    return view;
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
