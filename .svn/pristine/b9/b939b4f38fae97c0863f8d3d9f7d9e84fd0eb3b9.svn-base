//
//  LightAppNewsCell.m
//  WhistleIm
//
//  Created by LI on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LightAppNewsCell.h"
#import "ImUtils.h"
#import "LightAppNewsTableView.h"
#import "LightAppMessageInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface LightAppNewsCell()

@property(nonatomic,strong) UIImageView *background;
@property(nonatomic,strong) UIButton *title;
@property(nonatomic,strong) UIImageView *contentImage;
@property(nonatomic,strong) UIImageView *timeIcon;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UIView *div;
@property(nonatomic,strong) LightAppNewsTableView *table;

@end


@implementation LightAppNewsCell

@synthesize background;
@synthesize title;
@synthesize contentImage;
@synthesize timeLabel;
@synthesize timeIcon;
@synthesize div;
@synthesize table;
@synthesize titleView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createBg];
        [self createFirstNewsView];
        [self createOtherNewsView];
        self.backgroundColor = [UIColor clearColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)createBg
{
    background                          = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 240,252)];
    [background setImage:[ImUtils createImageWithColor:[UIColor whiteColor]]];
    background.layer.masksToBounds      = YES;
    background.layer.cornerRadius       = 15;
    background.userInteractionEnabled   = YES;
    [self addSubview:background];
    
    titleView                           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240,136)];
    titleView.backgroundColor           = [UIColor clearColor];
    [background addSubview:titleView];
}


-(void)createFirstNewsView
{
    contentImage                        = [[UIImageView alloc] initWithFrame:CGRectMake(17, 15, 206, 110)];
    contentImage.layer.masksToBounds    = YES;
    contentImage.layer.cornerRadius     = 15;
    [titleView addSubview:contentImage];
    
    title                               = [UIButton buttonWithType:UIButtonTypeCustom];
    [title setFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15]];
    [title setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState:UIControlStateNormal];
    [title setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [title setBackgroundImage:[ImUtils createImageWithColor:[UIColor colorWithWhite:0 alpha:0.4]] forState:UIControlStateNormal];
    title.frame                         = CGRectMake(0, 80, 206, 30);
    [contentImage addSubview:title];
    
    div                                 = [[UIView alloc] initWithFrame:CGRectMake(0, 137, 240, 1)];
    div.backgroundColor                 = [ImUtils colorWithHexString:@"e1e1e1"];
    [background addSubview:div];
    
    timeIcon                            = [[UIImageView alloc] initWithFrame:CGRectMake(152, 242, 10, 10)];
    timeIcon.image                      = [UIImage imageNamed:@"chat_cell_time_left.png"];
    [background addSubview:timeIcon];
    
    timeLabel                           = [[UILabel alloc] initWithFrame:CGRectMake(168,242,31, 22)];
    timeLabel.backgroundColor           = [UIColor clearColor];
    timeLabel.font                      = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    timeLabel.textColor                 = [ImUtils colorWithHexString:@"#262626"];
    timeLabel.highlightedTextColor      = [UIColor whiteColor];
    [background addSubview:timeLabel];
}

-(void)createOtherNewsView
{
    table                               = [[LightAppNewsTableView alloc] initWithFrame:CGRectMake(0, 138, 240, 50)];
    table.backgroundColor               = [UIColor clearColor];
    [background addSubview:table];
}

-(void)setUpCell:(LightAppMessageInfo *)info
{
    table.frame                         = CGRectMake(0, 138, 240, 50*(info.articleCount-1));
    timeIcon.frame                      = CGRectMake(132,[LightAppNewsCell getCellHeightWithCount:info.articleCount]-32,10,10);
    timeLabel.frame                     = CGRectMake(158,[LightAppNewsCell getCellHeightWithCount:info.articleCount]-32,31, 22);
    background.frame                    = CGRectMake(40, 10, 240,[LightAppNewsCell getCellHeightWithCount:info.articleCount]-10);
    
    LightAppNewsMessageInfo *newsInfo   = [info.articles objectAtIndex:0];
    [contentImage setImageWithURL:[NSURL URLWithString:newsInfo.picUrl] placeholderImage:nil];
    CGSize size                         = [newsInfo.title sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15] constrainedToSize:CGSizeMake(206, 120)];
    title.frame                         = CGRectMake(0, 80, 206,size.height>15?44:30);
    [title setTitle:newsInfo.title forState:UIControlStateNormal];
    
    timeLabel.text                      = [ImUtils formatMessageTime:info.ntime];
    [timeLabel sizeToFit];
    timeLabel.frame                     = CGRectMake(150,[LightAppNewsCell getCellHeightWithCount:info.articleCount]-32,timeLabel.frame.size.width, timeLabel.frame.size.height);
    [table.data removeAllObjects];
    [table.data addObjectsFromArray:[info.articles subarrayWithRange:NSMakeRange(1, info.articles.count-1)]];
    [table reloadData];
}


+(CGFloat) getCellHeightWithCount:(NSInteger) count
{
    return 148+50*(count-1)+34;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
