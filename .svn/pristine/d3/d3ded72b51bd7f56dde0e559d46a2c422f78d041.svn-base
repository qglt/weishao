//
//  OtherManager.m
//  WhistleIm
//
//  Created by liuke on 13-12-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "OtherManager.h"
#import "BizlayerProxy.h"
#import "RosterManager.h"
#import "JSONObjectHelper.h"

@implementation OtherManager

SINGLETON_IMPLEMENT(OtherManager)

- (void) get:(void(^)(NSString*)) callback
{
    FriendInfo* my = [[RosterManager shareInstance] mySelf];
    NSMutableString* _info = [[NSMutableString alloc] initWithFormat:@"&jid="];
    [_info appendString:my.jid];
    
    //得到name
    [_info appendString:@"&name="];
    [_info appendString:my.name];
    
    //得到系统平台
    [_info appendString:@"&osType="];
    [_info appendString:[[UIDevice currentDevice] systemName]];

    //得到系统版本
    [_info appendString:@"&osVersion="];
    [_info appendString:[[UIDevice currentDevice] systemVersion]];

    //得到whistle版本
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
         ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
         if(resultInfo.succeed){
             NSLog(@"get whistle version success, version is %@", [result objectForKey:@"version"]);
             [_info appendString:@"&whistleVersion="];
             NSString* version = [result objectForKey:@"version"];
             if (version && ![version isEqualToString:@""]) {
                 [_info appendString: version];
             }else{
                 [_info appendString:@"1.0"];
             }
             callback(_info);
         }
    };
    
    [[BizlayerProxy shareInstance] getWhistleVersion: listener];
}

- (void) getFeedback:(NSString *)content WithEmotion:(NSString*)emotion withCallback:(void (^)(NSString *))callback
{
    WhistleCommandCallbackType listener = ^(NSDictionary *result){
        ResultInfo *resultInfo =[self parseCommandResusltInfo:result];
        if(resultInfo.succeed){
            NSString* uri = [result objectForKey:@"feedback_uri"];
            [self get:^(NSString *info) {
                NSMutableString* ret = [[NSMutableString alloc] init];
                [ret appendString:uri];
                [ret appendString:@"&mood="];
                [ret appendString:emotion];
                [ret appendString:@"&content="];
                [ret appendString:content];
                [ret appendString:info];
                LOG_GENERAL_DEBUG(@"意见反馈的uri：%@", ret);
                callback(ret);
            }];

        }else{
            callback(nil);
        }
    };
    [[BizlayerProxy shareInstance] getFeedbackURL:listener];
}

- (void) doUploadImage:(NSString *)path crop_left:(NSUInteger)left crop_right:(NSUInteger)right crop_top:(NSUInteger)top crop_bottom:(NSUInteger)bottom callback:(void(^)(BOOL isSuccess, NSString* uri, NSString* reason, NSString* localImg))callback
{
    if (path) {
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
        if (image) {
            NSUInteger w = image.size.width;
            NSUInteger h = image.size.height;
            [[BizlayerProxy shareInstance] doUploadImage:path width:w height:h crop_left:left crop_right:right crop_top:top crop_bottom:bottom callback:^(NSDictionary *data) {
                ResultInfo* result = [super parseCommandResusltInfo:data];
                if (result.succeed) {
                    NSString* uri = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_URI];
                    NSString* reason = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_REASON];
                    NSString* localImg = [JSONObjectHelper getStringFromJSONObject:data forKey:KEY_LOCAL_IMG];
                    callback(YES, uri, reason, localImg);
                }else{
                    callback(NO, @"", @"", @"");
                }
            }];
        }else{
            callback(NO, @"", @"", @"");
        }
    }else{
        callback(NO, @"", @"", @"");
    }
}

@end
