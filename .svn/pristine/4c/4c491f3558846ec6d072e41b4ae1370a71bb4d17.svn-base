//
//  TalkToTextCell.m
//  WhistleIm
//
//  Created by wangchao on 13-9-13.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "TalkToTextCell.h"
#import "OHAttributedLabel.h"
#import "MessageLayoutInfo.h"
#import "MessageText.h"
#import "ImUtils.h"

@implementation TalkToTextCell

@synthesize warning;
@synthesize textBg;
@synthesize textView;
@synthesize headImageview;
@synthesize timeLabel;
@synthesize timeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        warning =[[UIImageView alloc] initWithFrame:CGRectZero];
        textBg =[[UIImageView alloc] initWithFrame:CGRectZero];

        headImageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50, 10, 40, 40)];
        headImageview.layer.cornerRadius = 20.0f;
        headImageview.layer.masksToBounds = YES;
        headImageview.userInteractionEnabled = YES;
        
        textView = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(84,22,0,0)];
        textView.autoresizingMask = UIViewAutoresizingNone;
        textView.centerVertically = NO;
        textView.automaticallyAddLinksForType = NO;
        //        txtView.delegate = self;
//        textView.highlightedTextColor = [UIColor whiteColor];
        
        
        textView.backgroundColor = [UIColor clearColor];
        textBg.backgroundColor = [UIColor clearColor];
        [warning setHidden:YES];
        
        self.selected = NO;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time.png"]];
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor colorWithRed:237.0f/ 255.0f green:237.0f/ 255.0f blue:237.0f/ 255.0f alpha:1.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = UITextAlignmentLeft;
        
        textBg.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24, 24,24) hLeftCapWidth:24 topCapHeight:24];
        textBg.highlightedImage = [ImUtils getFullBackgroundImageView:@"chat_cell_right_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
        
        [self addSubview:warning];
        [self addSubview:textBg];
        [self addSubview:textView];
        [self addSubview:headImageview];
        [self addSubview:timeLabel];
        [self addSubview:timeImage];
        
    }
     self.backgroundColor = [UIColor clearColor];
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    textBg.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    textBg.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    textBg.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}

-(void)layoutSubviews
{
    timeLabel.frame = CGRectMake(self.frame.size.width-67-timeLabel.frame.size.width,27+textView.frame.size.height, timeLabel.frame.size.width, timeLabel.frame.size.height);
    timeImage.frame = CGRectMake(timeLabel.frame.origin.x-15,timeLabel.frame.origin.y+2, 10, 10);
    CGFloat w = textView.frame.size.width+29<99?99:textView.frame.size.width+29;

    textBg.frame = CGRectMake(self.frame.size.width-w-55,10,w, textView.frame.size.height+39);
}

-(void)setupCell:(NSAttributedString *)content withSTDtime:(NSString *)time withSize:(CGSize)size withRowHeight:(CGFloat)height
{
    
    textView.attributedText = content;
    textView.frame= CGRectMake(self.frame.size.width-72- size.width,22, size.width,size.height+2);

    timeLabel.text = [ImUtils formatMessageTime:time];
    [timeLabel sizeToFit];
}

-(void)dealloc
{
    textBg = nil;
    textView.attributedText = nil;
    textView = nil;
}

@end
