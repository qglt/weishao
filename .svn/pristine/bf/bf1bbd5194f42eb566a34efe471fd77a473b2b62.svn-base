//
//  TalkToImgCell.m
//  WhistleIm
//
//  Created by wangchao on 13-9-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "TalkToImgCell.h"
#import "ImUtils.h"
#import "MessageImage.h"
#import "MessageLayoutInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LightAppMessageInfo.h"

@implementation TalkToImgCell



@synthesize imageBgView;
@synthesize contentImg;
@synthesize headImageview;
@synthesize timeLabel;
@synthesize timeImage;

//@synthesize indicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int width = self.frame.size.width;
        
        headImageview = [[UIImageView alloc] initWithFrame:CGRectMake(width -50, 10, 40, 40)];
        headImageview.layer.cornerRadius = 20.0f;
        headImageview.layer.masksToBounds = YES;
        headImageview.userInteractionEnabled = YES;
        imageBgView =[[UIImageView alloc] initWithFrame:CGRectMake(width-147,10,92,103)];//72
        contentImg =[[UIImageView alloc] initWithFrame:CGRectMake(width-141,16,75, 75)];//66
//        indicator= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        contentImg.image = [UIImage imageNamed:@"talk_def_image.png"];
        contentImg.contentMode = UIViewContentModeScaleAspectFill;
        contentImg.layer.cornerRadius = 20.0f;
        contentImg.layer.masksToBounds = YES;
        contentImg.userInteractionEnabled = YES;
        
        imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
        imageBgView.highlightedImage = [ImUtils getFullBackgroundImageView:@"chat_cell_right_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];

//        indicator.center = CGPointMake(contentAutoView.center.x, contentAutoView.center.y);
//        indicator.stopAnimating;
        
        timeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_cell_time.png"]];
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor colorWithRed:237.0f/ 255.0f green:237.0f/ 255.0f blue:237.0f/ 255.0f alpha:1.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
        
        
        [self addSubview:imageBgView];
        [self addSubview:contentImg];
        [self addSubview:headImageview];
        [self addSubview:timeImage];
        [self addSubview:timeLabel];

        self.selected = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
       
    }
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right_pre.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    imageBgView.image = [ImUtils getFullBackgroundImageView:@"chat_cell_right.png"WithCapInsets:UIEdgeInsetsMake(24,24,24,24) hLeftCapWidth:24 topCapHeight:24];
}

-(void)layoutSubviews
{
    timeLabel.frame = CGRectMake(self.frame.size.width-67-timeLabel.frame.size.width,21+contentImg.frame.size.height, timeLabel.frame.size.width, timeLabel.frame.size.height);
    timeImage.frame = CGRectMake(timeLabel.frame.origin.x-15,timeLabel.frame.origin.y+2, 10, 10);
    CGFloat w = MAX(contentImg.frame.size.width+17, 12);
    imageBgView.frame = CGRectMake(contentImg.frame.origin.x-6,10, w, contentImg.frame.size.height+33);
}

-(void)setupCell:(ConversationInfo *)convInfo withCallback:(void (^)(void))callback
{
    timeLabel.text = [ImUtils formatMessageTime:[NSString stringWithFormat:@"%ld",convInfo.msgInfo.stdtime]];
    [timeLabel sizeToFit];
    
    NSString *path = [ImUtils getVacrdImagePath:convInfo.msgInfo.src];
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] || convInfo.status == MSG_SEND_SUCCUSS )
    {
        __weak UIImageView *tempContentView = contentImg;
        
        CGSize size = convInfo.size_.height >0?convInfo.size_:CGSizeMake(75, 75);
        contentImg.frame =CGRectMake(self.frame.size.width-66-size.width,contentImg.frame.origin.y,size.width, size.height);
        [contentImg setImageWithURL:[NSURL fileURLWithPath:path isDirectory:NO] placeholderImage:[UIImage imageNamed:@"talk_def_image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if(error)
            {
                UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:path];
                if(!image)
                {
                    image  = [UIImage imageWithContentsOfFile:path];
                    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:path toDisk:YES];
                }
                tempContentView.image = image;
            }
            if(!convInfo.msgInfo.isDownload || (convInfo.size_.width==0 && convInfo.size_.height ==0))
            {
                 [ImUtils resizeContentImageView:tempContentView byImage:image withMessageImage:convInfo];
                 callback();
            }
            
        }];
      
    }else if(convInfo.status == MSG_SEND_FAILURE)
    {
        contentImg.image = [UIImage imageNamed:@"talk_def_breaked.png"];
    }
    else if(convInfo.status == MSG_SENDING)
    {
        contentImg.image = [UIImage imageNamed:@"talk_def_image.png"];
    }
}


-(void)setupLightCell:(LightAppMessageInfo *)lightInfo withCallback:(void (^)(void))callback
{
    timeLabel.text = [ImUtils formatMessageTime:lightInfo.ntime];
    [timeLabel sizeToFit];
    
    NSString *path = [ImUtils getVacrdImagePath:lightInfo.image];
    if( [[NSFileManager defaultManager] fileExistsAtPath:path] || lightInfo.status == MSG_SEND_SUCCUSS )
    {
        __weak UIImageView *tempContentView = contentImg;
        
        CGSize size = lightInfo.size_.height >0?lightInfo.size_:CGSizeMake(70, 70);
        contentImg.frame =CGRectMake(self.frame.size.width-66-size.width,contentImg.frame.origin.y,size.width, size.height);
        [contentImg setImageWithURL:[NSURL fileURLWithPath:path isDirectory:NO] placeholderImage:[UIImage imageNamed:@"talk_def_image.png"] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if(error)
            {
                UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:path];
                if(!image)
                {
                    image  = [UIImage imageWithContentsOfFile:path];
                    [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:path toDisk:YES];
                }
                tempContentView.image = image;
            }
            
            if(!lightInfo.isDownload || (lightInfo.size_.width==0 && lightInfo.size_.height ==0))
            {
                [ImUtils resizeContentImageView:tempContentView byImage:image withMessageImage:lightInfo];
                callback();
            }
        }];
        
    }else if(lightInfo.status == MSG_SEND_FAILURE)
    {
        contentImg.image = [UIImage imageNamed:@"talk_def_breaked.png"];
    }
    else if(lightInfo.status == MSG_SENDING)
    {
        contentImg.image = [UIImage imageNamed:@"talk_def_image.png"];
    }
}



-(void)dealloc
{
    imageBgView = nil;
    contentImg = nil;
}

@end
