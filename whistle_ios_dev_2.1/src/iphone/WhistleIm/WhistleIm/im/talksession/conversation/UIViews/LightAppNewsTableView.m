//
//  LightAppNewsTableView.m
//  WhistleIm
//
//  Created by LI on 14-3-5.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "LightAppNewsTableView.h"
#import "LightAppMessageInfo.h"
#import "ImUtils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVWebViewController.h"
#import "ChatPopViewController.h"

#define LightAppNewsTableViewCellvHeight 50

@interface LightAppNewsTableViewCell()

@property(nonatomic,strong) UIImageView *img;
@property(nonatomic,strong) UILabel *title;

-(void) setUpCell:(LightAppNewsMessageInfo *)info;

@end

@implementation LightAppNewsTableViewCell
@synthesize title;
@synthesize img;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createView];
        self.backgroundColor = [UIColor whiteColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void) createView
{
    title                               = [[UILabel alloc] initWithFrame:CGRectMake(17, 14, 162, 22)];
    title.font                          = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    title.textColor                     = [ImUtils colorWithHexString:@"#262626"];
    title.numberOfLines                 = 2;
    title.backgroundColor               = [UIColor clearColor];
    title.highlightedTextColor          = [UIColor whiteColor];
    [self addSubview:title];
    
    img                                 = [[UIImageView alloc] initWithFrame:CGRectMake(185, 6, 38, 38)];
    img.layer.cornerRadius              = 10;
    img.layer.masksToBounds             = YES;
    [self addSubview:img];
    
    UIView *div                         = [[UIView alloc] initWithFrame:CGRectMake(0,LightAppNewsTableViewCellvHeight-1 , self.frame.size.width,1)];
    div.backgroundColor                 = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self addSubview:div];
}

-(void)setUpCell:(LightAppNewsMessageInfo *)info
{
    [img setImageWithURL:[NSURL URLWithString:info.picUrl] placeholderImage:nil];
    title.text = info.description;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [ImUtils colorWithHexString:@"#cccccc"];
    title.highlighted    = YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.backgroundColor = [UIColor whiteColor];
    title.highlighted    = NO;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   self.backgroundColor = [UIColor whiteColor];
    title.highlighted    = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



@interface LightAppNewsTableView()<UITableViewDataSource,UITableViewDelegate>



@end


@implementation LightAppNewsTableView

@synthesize data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSeparatorColor:[UIColor clearColor]];
        self.data = [NSMutableArray array];
        self.scrollEnabled = NO;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LightAppNewsTableViewCellvHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LightAppNewsMessageInfo *info = [data objectAtIndex:indexPath.row];
    LightAppNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LightAppNewsTableViewCell"];
    if(!cell)
    {
        cell = [[LightAppNewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LightAppNewsTableViewCell"];
        [self addTapGestureToNewsView:cell];
    }
    
    [cell setUpCell:info];
    
    return cell;
}

- (void)addTapGestureToNewsView:(UIView *)view {
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCellNewsView:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[view addGestureRecognizer:tapRecognizer];
}

-(void)showCellNewsView:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint                     point                   = [gestureRecognizer locationInView:self];
    NSIndexPath *               indexPath               = [self indexPathForRowAtPoint:point];
    LightAppNewsMessageInfo *   news                    = [data objectAtIndex:indexPath.row];
    SVWebViewController *       controller              = [[SVWebViewController alloc] init];
    controller.URL                                      = [NSURL URLWithString:news.url];
    
    id object = [self nextResponder];
    
    while (![object isKindOfClass:[UIViewController class]] &&
           
           object != nil) {
        
        object = [object nextResponder];
        
    }
    
    UIViewController *uc=(UIViewController*)object;
    
    [uc.navigationController pushViewController:controller animated:NO];
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LightAppNewsMessageInfo *info = [data objectAtIndex:indexPath.row];
//    NSLog(@"target is url: %@",info.url);
//    
//    
//    SVWebViewController *web = [[SVWebViewController alloc] init];
//    uc.navigationController.hidesBottomBarWhenPushed = YES;
//    web.URL = [NSURL URLWithString:info.url];
//    [uc.navigationController pushViewController:web animated:YES];
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

