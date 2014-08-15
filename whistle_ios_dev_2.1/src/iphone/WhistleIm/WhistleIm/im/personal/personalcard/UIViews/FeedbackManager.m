//
//  FeedbackManager.m
//  WhistleIm
//
//  Created by liuke on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FeedbackManager.h"
#import "Whistle.h"
#import "FriendInfo.h"
#import "RosterManager.h"

//http://whistle.ruijie.com.cn:1099/report/?module=feedback&jid=123@wuyiu.edu.cn&name=无名
//&school=武夷学院&device=pc-win7-1.06.100001&mood=开心&title=测试标题&content=测试内容

@interface FeedbackManager()
{
    NSURL* _url;
    NSMutableURLRequest* _request;
    NSString* _info;
    UIAlertView* alert;
}

@end

@implementation FeedbackManager

@synthesize delegate = _delegate;

- (id) init: (NSDictionary*) json
{
    self = [super init];
    return self;
}


- (void) sendContent:(NSString *)info
{
//    NSString* str = [[NSString alloc] initWithString: url];
////    NSString* str = [[NSString alloc] initWithString: @"1"];
//    str = [str stringByAppendingString:@"&mood="];
//    str = [str stringByAppendingString:emotion];
//    str = [str stringByAppendingString:@"&content="];
//    str = [str stringByAppendingString:content];
//    str = [str stringByAppendingString:_info];
    
//    NSLog(@"post url string : %@", str);
    
    _url = [NSURL URLWithString:[info stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _request = [[NSMutableURLRequest alloc] initWithURL:_url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:1000];

    [_request setHTTPMethod:@"POST"];
    [_request setHTTPBody:[info dataUsingEncoding:NSUTF8StringEncoding]];


    NSOperationQueue *queue = [[NSOperationQueue alloc]init];

    [NSURLConnection sendAsynchronousRequest:_request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if ([data length] >0 && error == nil)
        {
            NSLog(@"意见反馈发送成功");
            [[self delegate] sucessed];
        }
        else if ([data length] == 0 && error == nil)
        {
            NSLog(@"意见反馈信息为空");
            [[self delegate] failure:data WithError:error];
        }
        else if (error != nil){
            NSLog(@"意见反馈信息发送出现错误： %@", error);
            [[self delegate] failure:data WithError:error];
        }
    }];
}

@end
