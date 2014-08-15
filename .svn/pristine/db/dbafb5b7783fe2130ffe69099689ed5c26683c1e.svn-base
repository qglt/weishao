//
//  TalkSingleNewsCell.m
//  WhistleIm
//
//  Created by LI on 14-3-5.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "TalkSingleNewsCell.h"
#import "ImUtils.h"
#import "LightAppMessageInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TalkSingleNewsCell()

@property(nonatomic,strong) UILabel *title;

@property(nonatomic,strong) UIImageView *contentImage;

@property(nonatomic,strong) UILabel *contentLabel;

@property(nonatomic,strong) UIImageView *timeIcon;

@property(nonatomic,strong) UILabel *timeLabel;

@property(nonatomic,strong) UIView *div;

@property(nonatomic,strong) UILabel *viewLabel;

@property(nonatomic,strong) UIImageView *viewImage;


@end

@implementation TalkSingleNewsCell

@synthesize background;

@synthesize title;

@synthesize contentImage;

@synthesize contentLabel;

@synthesize timeIcon;

@synthesize timeLabel;

@synthesize viewLabel;

@synthesize div;

@synthesize viewImage;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createBg];
        [self createContent];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)createBg
{
    background = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 240,252)];
    [background setImage:[ImUtils createImageWithColor:[UIColor whiteColor]]];
    [background setHighlightedImage:[ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#cccccc"]]];
    background.layer.masksToBounds = YES;
    background.layer.cornerRadius = 15;
    background.userInteractionEnabled = YES;
    [self addSubview:background];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self viewHighlighted:YES];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self viewHighlighted:NO];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self viewHighlighted:NO];
}

-(void) viewHighlighted:(BOOL)highlighted
{
    background.highlighted              = highlighted;
    title.highlighted                   = highlighted;
    contentLabel.highlighted            = highlighted;
    timeLabel.highlighted               = highlighted;
    viewLabel.highlighted               = highlighted;
    viewImage.highlighted               = highlighted;
}

-(void)createContent
{
    title                               = [[UILabel alloc] initWithFrame:CGRectMake(0,12, 100, 15)];
    title.font                          = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    title.textColor                     = [ImUtils colorWithHexString:@"#262626"];
    title.backgroundColor               = [UIColor clearColor];
    title.highlightedTextColor          = [UIColor whiteColor];
    [background addSubview:title];
    
    contentImage                        = [[UIImageView alloc] initWithFrame:CGRectMake(17, 39, 206, 112)];
    contentImage.layer.masksToBounds    = YES;
    contentImage.layer.cornerRadius     = 15;
    [background addSubview:contentImage];
    
    contentLabel                        = [[UILabel alloc] initWithFrame:CGRectMake(17,163, 206, 22)];
    contentLabel.font                   = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    contentLabel.textColor              = [ImUtils colorWithHexString:@"#262626"];
    contentLabel.backgroundColor        = [UIColor clearColor];
    contentLabel.highlightedTextColor   = [UIColor whiteColor];
    [background addSubview:contentLabel];
    
    viewLabel                           = [[UILabel alloc] initWithFrame:CGRectMake(17, 197, 100, 22)];
    viewLabel.text                      = NSLocalizedString(@"view_news",nil);
    viewLabel.font                      = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    viewLabel.textColor                 = [ImUtils colorWithHexString:@"#262626"];
    viewLabel.highlightedTextColor      = [UIColor whiteColor];
    [background addSubview:viewLabel];
    
    viewImage                           = [[UIImageView alloc] initWithFrame:CGRectMake(218, 207, 5, 8)];
    viewImage.image                     = [UIImage imageNamed:@"light_view.png"];
    viewImage.highlightedImage          = [UIImage imageNamed:@"light_view_pre.png"];
    [background addSubview:viewImage];
    
    div                                 = [[UIView alloc] initWithFrame:CGRectMake(0, 229, 240, 1)];
    div.backgroundColor                 = [ImUtils colorWithHexString:@"e1e1e1"];
    [background addSubview:div];
    
    timeIcon                            = [[UIImageView alloc] initWithFrame:CGRectMake(152, 236, 10, 10)];
    timeIcon.image                      = [UIImage imageNamed:@"chat_cell_time_left.png"];
    [background addSubview:timeIcon];
    
    timeLabel                           = [[UILabel alloc] initWithFrame:CGRectMake(168,236,31, 22)];
    timeLabel.backgroundColor           = [UIColor clearColor];
    timeLabel.font                      = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    timeLabel.textColor                 = [ImUtils colorWithHexString:@"#262626"];
    timeLabel.highlightedTextColor      = [UIColor whiteColor];
    [background addSubview:timeLabel];
}

-(void)layoutSubviews
{
    title.frame =  CGRectMake((background.frame.size.width-  title.frame.size.width)/2, title.frame.origin.y,  title.frame.size.width,  title.frame.size.height);
}

-(void)setupCellWith:(LightAppMessageInfo *)info
{
    LightAppNewsMessageInfo *newsInfo   = info.articles.lastObject;
    title.text                          = newsInfo.title;
    contentLabel.text                   = newsInfo.description;
    [contentImage setImageWithURL:[NSURL URLWithString:newsInfo.picUrl] placeholderImage:nil];
    [title sizeToFit];
    timeLabel.text = [ImUtils formatMessageTime:info.dt];
    [timeLabel sizeToFit];
    timeLabel.frame                     =  CGRectMake(168,236,timeLabel.frame.size.width, timeLabel.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
