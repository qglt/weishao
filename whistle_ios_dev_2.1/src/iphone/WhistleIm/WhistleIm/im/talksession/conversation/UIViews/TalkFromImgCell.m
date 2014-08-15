//
//  TalkFromImgCell.m
//  WhistleIm
//
//  Created by wangchao on 13-9-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "TalkFromImgCell.h"
#import "MessageLayoutInfo.h"
#import "MessageImage.h"
#import "MessageManager.h"
#import "ImUtils.h"
#import "FriendInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TalkFromImgCell
@synthesize headImageView;
@synthesize imageBgView;
@synthesize contentImg;
@synthesize indicator;
@synthesize timeImage;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        headImageView =[[UIImageView alloc] initWithFrame:CGRectMake(10,10, 40, 40)];
        headImageView.layer.cornerRadius = 20.0f;
        headImageView.layer.masksToBounds = YES;
        headImageView.userInteractionEnabled = YES;
        
        imageBgView =[[UIImageView alloc] initWithFrame:CGRectMake(55,10,102, 91)];
        contentImg =[[UIImageView alloc] initWithFrame:CGRectMake(66,16,75, 75)];
        
        indicator= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        
        
        
        contentImg.image = [UIImage imageNamed:@"talk_def_image.png"];
        contentImg.contentMode = UIViewContentModeScaleAspectFill;
        
        contentImg.layer.cornerRadius = 20.0f;
        contentImg.layer.masksToBounds = YES;
        contentImg.userInteractionEnabled = YES;
        
        imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(25,29,25,19) hLeftCapWidth:23 topCapHeight:23];
        imageBgView.highlightedImage = [ImUtils getFullBackgroundImageView:@"chat_cell_time_left.png"WithCapInsets:UIEdgeInsetsMake(25,29,25,19) hLeftCapWidth:24 topCapHeight:24];
        imageBgView.userInteractionEnabled = YES;
        
        indicator.center = CGPointMake(contentImg.center.x, contentImg.center.y);
        [indicator stopAnimating];
        
        timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time_left.png"]];
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor colorWithRed:80.0f/ 255.0f green:80.0f/ 255.0f blue:80.0f/ 255.0f alpha:1.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
      
        [self addSubview:imageBgView];
        [self addSubview:contentImg];
        [self addSubview:indicator];
        [self addSubview:timeImage];
        [self addSubview:timeLabel];
        
        

        [self addSubview:headImageView];
//        self.selected = NO;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_left.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}

-(void)layoutSubviews
{
    
    timeImage.frame = CGRectMake(72,23+contentImg.frame.size.height, 10, 10);
    timeLabel.frame = CGRectMake(timeImage.frame.origin.x+15, timeImage.frame.origin.y-2, timeLabel.frame.size.width, timeLabel.frame.size.height);
    CGFloat w = contentImg.frame.size.width+17<102?102:contentImg.frame.size.width+17;
    imageBgView.frame = CGRectMake(55,10, w, contentImg.frame.size.height+37);
}

-(void) setupCell:(ConversationInfo *)convInfo withCallback:(void (^)(void))callback
{
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    
    NSString *path = [ImUtils getVacrdImagePath:convInfo.msgInfo.src];
    NSLog(@"convInfo.msgInfo.src is %@",convInfo.msgInfo.src);
    
    indicator.center = CGPointMake(contentImg.center.x, contentImg.center.y);
    [indicator stopAnimating];
    if([fileManager fileExistsAtPath:path] || convInfo.status == MSG_RECV_SUCCUSS )
    {
        __weak UIImageView *tempContentView = contentImg;
        CGSize size = convInfo.size_.height >0?convInfo.size_:CGSizeMake(70, 70);
        
        contentImg.frame =CGRectMake(66,16,size.width,size.height);
        
        [contentImg setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[UIImage imageNamed:@"talk_def_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error) {
                image = tempContentView.image = [UIImage imageNamed:@"talk_def_breaked.png"];
            }
            if (!convInfo.msgInfo.isDownload) {
                [ImUtils resizeContentImageView:tempContentView byImage:image withMessageImage:convInfo];
                callback();
            }
            
        }];
    }else if(convInfo.status == MSG_RECV_FAILURE)
    {
        contentImg.image = [UIImage imageNamed:@"talk_def_breaked.png"];
    }else if(convInfo.status == MSG_RECVING)
    {
            [indicator startAnimating];
    }
    
    timeLabel.text = [ImUtils formatMessageTime:[NSString stringWithFormat:@"%ld",convInfo.msgInfo.stdtime]];
    
    [timeLabel sizeToFit];
}

-(void)dealloc
{
    headImageView =nil;
    imageBgView = nil;
    contentImg = nil;
    indicator = nil;
    timeImage = nil;
    timeLabel = nil;
}

@end
