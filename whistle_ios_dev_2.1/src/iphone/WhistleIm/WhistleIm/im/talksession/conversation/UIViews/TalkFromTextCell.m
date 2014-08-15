//
//  TalkFromTextCell.m
//  WhistleIm
//
//  Created by wangchao on 13-9-9.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "TalkFromTextCell.h"
#import "OHAttributedLabel.h"
#import "MessageLayoutInfo.h"
#import "MessageText.h"
#import "ImUtils.h"

@implementation TalkFromTextCell
@synthesize headImageView;
@synthesize txtBgView;
@synthesize txtView;
@synthesize timeLabel;
@synthesize timeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headImageView =[[UIImageView alloc] initWithFrame:CGRectMake(10,10, 40, 40)];
        headImageView.layer.cornerRadius = 20.0f;
        headImageView.layer.masksToBounds = YES;
        headImageView.userInteractionEnabled = YES;
        
        txtBgView =[[UIImageView alloc] initWithFrame:CGRectMake(55,10,15, 15)];

        txtView = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(72,22,0,0)];
        txtView.autoresizingMask = UIViewAutoresizingNone;
        txtView.centerVertically = NO;
        txtView.automaticallyAddLinksForType = NO;
//        txtView.delegate = self;
        txtView.textColor = [ImUtils colorWithHexString:@"#262626"];
        txtView.highlightedTextColor = [UIColor whiteColor];
        txtView.backgroundColor = [UIColor clearColor];
        
        txtBgView.backgroundColor = [UIColor clearColor];
        
        timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time_left.png"]];
        timeImage.backgroundColor = [UIColor clearColor];
        timeLabel = [[UILabel alloc] init];
        
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor colorWithRed:80.0f/ 255.0f green:80.0f/ 255.0f blue:80.0f/ 255.0f alpha:1.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:headImageView];
        [self addSubview:txtBgView];
//        [self addSubview:txtView];
        [self addSubview:timeImage];
        [self addSubview:timeLabel];
        [self addSubview:txtView];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundColor = [UIColor clearColor];
        
        txtBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
        txtBgView.highlightedImage = [ImUtils getFullBackgroundImageView:@"chat_cell_left_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
//        txtBgView.userInteractionEnabled = YES;

    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}
-(void)layoutSubviews
{
    timeImage.frame = CGRectMake(72, txtView.frame.origin.y+txtView.frame.size.height+6, 10, 10);
    timeLabel.frame = CGRectMake(timeImage.frame.origin.x+timeImage.frame.size.width+5, timeImage.frame.origin.y-2, timeLabel.frame.size.width, timeLabel.frame.size.height);
    
    CGFloat w = 0;
    if (txtView.frame.size.width < timeImage.frame.size.width+timeLabel.frame.size.width+5) {
        w = timeImage.frame.size.width+timeLabel.frame.size.width+34<99?99:timeImage.frame.size.width+timeLabel.frame.size.width+34;
    }else
    {
        w = txtView.frame.size.width+29<99?99:txtView.frame.size.width+29;
    }
    txtBgView.frame = CGRectMake(55, 10, w, txtView.frame.size.height+39);
    
    [super layoutSubviews];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    txtBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    txtBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    txtBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}

-(void)setupCell:(NSAttributedString *)content withSTDtime:(NSString *)time withSize:(CGSize)size withRowHeight:(CGFloat)height
{
    txtView.attributedText = content;
    txtView.frame = CGRectMake(72,22,size.width+18,size.height+2);
    timeLabel.text = [ImUtils formatMessageTime:time];
    
    [timeLabel sizeToFit];
}

-(void)dealloc
{
    headImageView = nil;
    txtBgView = nil;
    txtView.attributedText = nil;
    txtView = nil;
    timeImage = nil;
    timeLabel = nil;

}

@end
