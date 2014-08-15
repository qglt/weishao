//
//  CrowdSystemView.m
//  WhistleIm
//
//  Created by liuke on 13-11-5.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CrowdSystemView.h"
#import "UISpanableLabel.h"
#import "Whistle.h"
#import "ImUtils.h"
//#import "NetworkBrokenAlert.h"

@interface CrowdSystemView()
{
    CGFloat contentLabelY;//群消息内容label的最后一行y值
    NSDictionary* contentDic_;
    CGRect frame_;
}

@end

@implementation CrowdSystemView

@synthesize crowdSystemDelegate = _crowdSystemDelegate;
@synthesize photo = _photo;
@synthesize name = _name;
@synthesize crowd_no = _crowd_no;
@synthesize reason = _reason;
@synthesize content = _content;

//@synthesize contentDic = _contentDic;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        frame_ = frame;
//        self.name = @"发广告工工在有基基有基有";
//        self.crowd_no = @"12312312312";
//        self.content = @"霜工工工工工工工工工工工工工工工工工 式 ";//工工工工工工工 式 工工工工工工工工工工工工工工工 工工 工地 地地地地";
//        self.reason = @"霜工工工工工工工工工工工工工工工工工 式 工工工工工工工工工工工工工工工 工工 工地 地地地地";
        
    }
    return self;
}

- (void) createViewIsReason:(BOOL) isreason isButton:(BOOL) isHasBtn IsNeedAnswer:(BOOL) isAnswer
{
    LOG_GENERAL_INFO(@"dic in content init: %@", contentDic_);
    [self addSubview:[self createPhotoSection:CGRectMake(132.5, 15, 55, 55)]];
    [self addSubview:[self createCrowdNameSection:CGRectMake(0, 76, frame_.size.width, 15)]];
    [self addSubview:[self createCrowdNOSection:CGRectMake(0, 97, frame_.size.width, 12)]];

    [self addSubview:[self createContentSection:CGRectMake(0,139, frame_.size.width, 15)]];
    
    if (isreason) {
        [self addSubview:[self createReasonSection:CGRectMake(0, isAnswer?contentLabelY+21:contentLabelY, frame_.size.width, 12)]];
    }

    if (isHasBtn) {
        [self addSubview:[self createButton:CGRectMake(0,contentLabelY + 30, frame_.size.width, 100)]];//frame.size.height - 91 - 44
    }
    if (isAnswer) {
        [self addSubview:[self createAnswerInviteTip:CGRectMake(0, contentLabelY > 160 ? contentLabelY : 160, frame_.size.width, 15)]];
    }
}

//创建群头像信息
- (UIView *) createPhotoSection: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [imgview setImage:self.photo];
    imgview.layer.masksToBounds = YES; //没这句话它圆不起来
    imgview.layer.cornerRadius = 27.5; //设置图片圆角的尺度。
    imgview.layer.masksToBounds = YES;
    [view addSubview:imgview];
//    view.backgroundColor = [UIColor redColor];
    return view;
}

- (UIView*) createCrowdNameSection: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [label setText:self.name];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
//    view.backgroundColor = [UIColor yellowColor];
    return view;
}

- (UIView*) createCrowdNOSection: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [label setText:[NSString stringWithFormat:@"群号:%@", self.crowd_no]];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return view;
}

//创建理由区
- (UIView *) createReasonSection: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [label setText:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"reason", nil),self.reason.length>0?self.reason:NSLocalizedString(@"null", nil)]];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 3;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize maximumSize = CGSizeMake(rect.size.width, 9999);
    //    NSString *dateString = @"The date today is January 1st, 1999";
    //    UIFont *dateFont = [UIFont fontWithName:@"Helvetica" size:14];
    CGSize dateStringSize = [self.reason sizeWithFont:label.font
                                    constrainedToSize:maximumSize
                                        lineBreakMode:label.lineBreakMode];
    CGRect dateFrame = CGRectMake(0, 0, rect.size.width, dateStringSize.height);
    label.frame = dateFrame;
    
    [view addSubview:label];
//    view.backgroundColor = [UIColor redColor];
    return view;
}
//创建内容区
- (UIView *) createContentSection: (CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UISpanableLabel* label = [[UISpanableLabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    
    NSMutableAttributeStringWithClick * click = [self getAttributedStringFromCrowdInfo: contentDic_];
    
    [label setText:self.content];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.numberOfLines = 3;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGSize maximumSize = CGSizeMake(rect.size.width, 9999);
    CGSize dateStringSize = [self.content sizeWithFont:label.font
                                   constrainedToSize:maximumSize
                                       lineBreakMode:label.lineBreakMode];
    CGRect dateFrame = CGRectMake(0, 0, rect.size.width, dateStringSize.height);
    label.frame = dateFrame;
    LOG_GENERAL_INFO(@"dic in content: %@", contentDic_);
    
    [label setAttributedTextWithClick:click];
    
    [view addSubview:label];
//    view.backgroundColor = [UIColor orangeColor];
    view.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, dateStringSize.height);
    
    contentLabelY = rect.origin.y + dateStringSize.height;
    
    
    return view;
}


- (UIView *) createButton:(CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    CGFloat h = 39;
    UIButton* agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 1, rect.size.width, h)];
    [agreeBtn setTitle:NSLocalizedString(@"agree", nil) forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(pressDown_AllowBtn:)
       forControlEvents:UIControlEventTouchUpInside];
    
    agreeBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    
    [agreeBtn setBackgroundImage:[ImUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [agreeBtn setBackgroundImage:[ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#cccccc"]] forState:UIControlStateHighlighted];
    
    [agreeBtn setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState: UIControlStateNormal];
    [agreeBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateHighlighted];
    [view addSubview:agreeBtn];
    
    UIView *separatorViewTop1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, 1)];
    separatorViewTop1.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [view addSubview:separatorViewTop1];
    
    UIView *separatorViewBottom1 = [[UIView alloc] initWithFrame:CGRectMake(0,40,rect.size.width, 1)];
    separatorViewBottom1.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [view addSubview:separatorViewBottom1];
    

    UIButton* rejectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,49, rect.size.width, h)];
    [rejectBtn addTarget:self action:@selector(pressDown_RejectBtn:)
       forControlEvents:UIControlEventTouchUpInside];
    [rejectBtn setTitle:NSLocalizedString(@"reject", nil) forState:UIControlStateNormal];
    rejectBtn.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];

    [rejectBtn setBackgroundImage:[ImUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [rejectBtn setBackgroundImage:[ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#cccccc"]] forState:UIControlStateHighlighted];

    [rejectBtn setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState: UIControlStateNormal];
    [rejectBtn setTitleColor:[UIColor whiteColor] forState: UIControlStateHighlighted];
    [view addSubview:rejectBtn];
    
    UIView *separatorViewTop2 = [[UIView alloc] initWithFrame:CGRectMake(0,48,rect.size.width, 1)];
    separatorViewTop2.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [view addSubview:separatorViewTop2];
    
    UIView *separatorViewBottom2 = [[UIView alloc] initWithFrame:CGRectMake(0,88,rect.size.width, 1)];
    separatorViewBottom2.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [view addSubview:separatorViewBottom2];
    return view;
}

- (UIView*) createAnswerInviteTip:(CGRect) rect
{
    UIView* view = [[UIView alloc] initWithFrame:rect];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    if (self.isAgree) {
        [label setText: @"你已经同意该邀请"];
    }else{
        [label setText: @"你已经拒绝该邀请"];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:label];
    //    view.backgroundColor = [UIColor yellowColor];
    return view;
}

- (NSMutableAttributeStringWithClick*) getAttributedStringFromCrowdInfo:(NSDictionary*) dic
{
    if (!dic) {
        return nil;
    }
    NSMutableAttributeStringWithClick* clickString = [[NSMutableAttributeStringWithClick alloc] init];
    
    NSString* result = [dic objectForKey:@"result"];
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"\\$[0-9]"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSArray *arr = [regularexpression matchesInString:result options:NSMatchingReportProgress range:NSMakeRange(0, result.length)];
    
    NSMutableString* tmpResult = [result mutableCopy];
    
    NSUInteger step = 0;
    for (NSTextCheckingResult *match in arr) {
        NSRange matchRange = [match range];
        NSString* param = [result substringWithRange:matchRange];
        NSDictionary* d = [dic objectForKey:param];
        NSString* txt = [d objectForKey:@"txt"];
        NSString* jid = [d objectForKey:@"jid"];
        
        [tmpResult replaceCharactersInRange:matchRange withString:txt];
    
        [clickString addClickAttribute:NSForegroundColorAttributeName
                                 value:[UIColor blueColor]
                                 range:NSMakeRange(matchRange.location + step, [txt length])
                            ClickEvent: ^{
                                LOG_GENERAL_INFO(@"测试txt:%@,jid:%@", txt, jid);
                                [self.crowdSystemDelegate clickLabel:jid];
        }];
        
        step += [txt length] - matchRange.length;
    }
    self.content = tmpResult;
    return clickString;
}

- (void) setContentDictionary:(NSDictionary *)contentDic
{
    LOG_GENERAL_INFO(@"setcontnetdic:%@", contentDic);
    contentDic_ = contentDic;
}

- (void) pressDown_AllowBtn: (id) sender
{
//    if ([NetworkBrokenAlert isShowAlert:self]) {
//        return;
//    }
    [self.crowdSystemDelegate pushAgreeBtn];
}

- (void) pressDown_RejectBtn: (id) sender
{
//    if ([NetworkBrokenAlert isShowAlert:self]) {
//        return;
//    }
    [self.crowdSystemDelegate pushRejectBtn];
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
