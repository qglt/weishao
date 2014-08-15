//
//  ImUtils.m
//  WhistleIm
//
//  Created by wangchao on 13-12-10.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "ImUtils.h"
#import "JSONObjectHelper.h"
#import "SmileyParser.h"
#import "FriendInfo.h"
#import "ChatGroupInfo.h"
#import "CrowdInfo.h"
#import "GetFrame.h"
#import "ConversationInfo.h"
#import "RecentAppMessageInfo.h"
#import "MessageManager.h"
#import "Constants.h"
#import "MessageLayoutInfo.h"
#import "MessageImage.h"
#import "ConversationInfo.h"
#import "BizlayerProxy.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LightAppInfo.h"
#import "LightAppMessageInfo.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ImUtils


+(NSString *)formatMessageTime:(NSString *)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}

+(UIImage *)getFullBackgroundImageView:(NSString *)imageName WithCapInsets:(UIEdgeInsets)capInsets hLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    UIImage *image;//气泡图片
    if ([[[UIDevice currentDevice]systemVersion] floatValue] < 5.0) {
        image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }else {
        image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets];
    }
    return image;
}

+(void)downloadPic:(ConversationInfo *)convInfo withCallback:(void (^)(BOOL))callback
{
    [[BizlayerProxy shareInstance] getImage:convInfo.msgInfo.src_id withName:convInfo.msgInfo.src withListener:^(NSDictionary *result) {
        ResultInfo *resultInfo = [[MessageManager shareInstance] parseCommandResusltInfo:result];
        callback(resultInfo.succeed);
    }];
}

+(BOOL) IsOnlineWithFriendInfo:(FriendInfo *)info byJid:(NSString *) inputJid
{
    if([ImUtils getChatType:inputJid] == SessionType_Conversation)
    {
        return [info isOnline];
        
    }

    return [ImUtils getChatType:inputJid] == SessionType_Conversation;
    
}

+(NSString *) md5HexDigest:(NSString *)string
{
    const char *original_str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

+(void) setHeadViewImage:(FriendInfo *)friend withImageView:(UIImageView *)imageView forJid:(NSString *)inputJid
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(friend && [fileManager fileExistsAtPath:friend.head])
    {
        //            imageView.layer.cornerRadius = 8.0f;
        //            imageView.layer.masksToBounds = YES;
        [imageView setImageWithURL:[NSURL fileURLWithPath:friend.head] placeholderImage:[ImUtils getHeadImgByFriendInfo:friend withOnline:[ImUtils IsOnlineWithFriendInfo:friend byJid:inputJid]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            image =[[GetFrame shareInstance] convertImageToGrayScale:image];
        }];
    }
    else
    {
        [imageView setImage:[ImUtils getHeadImgByFriendInfo:friend withOnline:[ImUtils IsOnlineWithFriendInfo:friend byJid:inputJid]]];
    }
    fileManager = nil;
    
}

+(void) resizeContentImageView:(UIImageView *) imageView byImage:(UIImage *)image withMessageImage:(BaseMessageInfo *)baseInfo
{
    
    
    if (image.size.width <= kMaxContentWidth && image.size.height<= kMaxContentHeight) {
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,image.size.width ,image.size.height);
    }else
    {
        if(image.size.width>=image.size.height)
        {
            if(MIN(kMaxContentWidth , kMaxContentWidth*(imageView.image.size.height / imageView.image.size.width))>kMinContentWidth)
            {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,kMaxContentWidth ,kMaxContentWidth*(imageView.image.size.height / imageView.image.size.width));
            }else
            {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,kMinContentWidth ,kMinContentWidth*(imageView.image.size.height / imageView.image.size.width));
            }
            
            if (imageView.frame.size.height<kMinContentHeight) {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, (imageView.frame.size.width/imageView.frame.size.height)*kMinContentHeight,kMinContentHeight);
            }
            
            if (imageView.frame.size.width>kMaxContentWidth) {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, kMaxContentWidth,(imageView.frame.size.height/imageView.frame.size.width)*kMaxContentWidth);
            }
            
        }else
        {
            
            if(MIN(kMaxContentHeight ,kMaxContentHeight*(imageView.image.size.width / imageView.image.size.height) )>kMinContentWidth)
            {
                 imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,kMaxContentHeight*(imageView.image.size.width / imageView.image.size.height) ,kMaxContentHeight);
            }else
            {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,kMinContentWidth ,kMinContentWidth*(imageView.image.size.height / imageView.image.size.width));
            }
            if (imageView.frame.size.height<kMinContentWidth) {
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, kMinContentWidth,(imageView.frame.size.height/imageView.frame.size.width)*kMinContentWidth);
            }
           
        }
    }
    if([baseInfo isKindOfClass:[ConversationInfo class]])
    {
        ((ConversationInfo *)baseInfo).msgInfo.isDownload = YES;
        ((ConversationInfo *)baseInfo).size_ = CGSizeMake(imageView.frame.size.width,imageView.frame.size.height);
    }else
    {
        ((LightAppMessageInfo *)baseInfo).isDownload = YES;
        ((LightAppMessageInfo *)baseInfo).size_ = CGSizeMake(imageView.frame.size.width,imageView.frame.size.height);
    }
    
}

#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


+(NSString *)getVacrdImagePath:(NSString *)name
{
    return [NSString stringWithFormat:@"%@%@%@",[[MessageManager shareInstance] getMainFolder],VCARD,name];
}

+(void)setTableViewFullBackground:(NSString *)imageName inview:(UITableView *)table
{
    table.backgroundView = [[UIView alloc] initWithFrame:table.bounds];
    table.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
}

+(UIImage *)scaleAndRotateImage:(UIImage *)image scaleMaxResolution:(int) kMaxResolution
{
//    int kMaxResolution = [UIScreen mainScreen].bounds.size.width; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+(NSString *)fetchLastMember:(NSDictionary *)jsonobj
{
    NSLog(@"fetchLastMember");
    NSString *lastMember =  [JSONObjectHelper getStringFromJSONObject:jsonobj forKey:KEY_TXT];
    NSString *voice =  [JSONObjectHelper getStringFromJSONObject:jsonobj forKey:KEY_VOICE];
    NSString *msg_extension = [JSONObjectHelper getStringFromJSONObject:jsonobj forKey:KEY_MSG_EXT];
    if(voice != nil)
    {
        lastMember = @"[语音]";
    }else if(lastMember != nil && [lastMember rangeOfString:@"<img"].length !=0)
    {
        
        lastMember = [[SmileyParser parser] pasrePushMessageToSmily:[ImUtils segmentText:lastMember]];
    }
    
    if([msg_extension isEqualToString:@"send_file"])
    {
        lastMember=@"[文件]";
    }
    NSLog(@"lastMember is %@",lastMember);
    NSString *replace = [lastMember stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    return [ImUtils flattenHTML:replace trimWhiteSpace:YES];;
}

+(NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    NSScanner *theScanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    
    // trim off whitespace
    return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
}

+(NSString *)segmentText:(NSString *)textContent
{
    NSString *text = [textContent stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, textContent.length)];
    
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img\\s+src=.+?class=(.+?)style=.+?>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *temp = [regularExpression matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
    if(temp.count >0)
    {
        NSTextCheckingResult *result  = [temp objectAtIndex:0];
        if(result.range.location>0)
        {
            return [text substringToIndex:result.range.location];
        }
        
        return @"[图片]";
    }else
    {
        
        return text;
    }
}

+(ConversationType)getChatType:(NSString *)fromId
{
    if([fromId rangeOfString:@"@discussion"].location != NSNotFound){
        return SessionType_Discussion;
    }else if([fromId rangeOfString:@"@groups"].location != NSNotFound){
        return SessionType_Crowd;
    }else if([fromId rangeOfString:@"@"].location != NSNotFound){
        return SessionType_Conversation;
    }else if([fromId rangeOfString:@"@light"].location != NSNotFound || [fromId rangeOfString:@"@"].location == NSNotFound){
        return SessionType_LightApp;
    }
    
    return SessionType_Conversation;
}

+ (void)drawRosterHeadPic:(FriendInfo *)rosterItem withView:(UIImageView *)view withOnline:(BOOL)flag
{
        view.image = [ImUtils getHeadImgByFriendInfo:rosterItem withOnline:flag];
}

+(UIImage *) getHeadImgByFriendInfo:(FriendInfo *) rosterItem withOnline:(BOOL)flag
{
    UIImage * image = nil;
    if(rosterItem)
    {
        image = [UIImage imageWithContentsOfFile:rosterItem.head];
        if (image == nil) {
            if (rosterItem.identity) {
                if ([rosterItem.sexShow isEqualToString:SEX_GIRL]) {
                    image = [UIImage imageNamed:@"identity_woman.png"];
                } else {
                    image = [UIImage imageNamed:@"identity_man_new.png"];
                }
            }
        }
        
        if (flag && ![rosterItem isOnline]) {
            image = [[GetFrame shareInstance] convertImageToGrayScale:image];
        }
    }else
    {
        image = [UIImage imageNamed:@"identity_man_new.png"];
    }

    return image;
}

+(UIImage *)getDefault:(id)Obj
{
    if ([Obj isKindOfClass:[FriendInfo class]]) {
        FriendInfo *info = Obj;
        
        return [UIImage imageNamed:[info.sexShow isEqualToString:SEX_GIRL]?@"identity_woman.png":@"identity_man_new.png"];

    }else if([Obj isKindOfClass:[BaseAppInfo class]])
    {
        return [UIImage imageNamed:@"app_default.png"];
    }
        
}

/**
 * 将UIColor变换为UIImage
 *
 **/
+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+(NSString *)getIdByObject:(id)inputObject
{
    if([inputObject isKindOfClass:[FriendInfo class]])
    {
        FriendInfo *info = inputObject;
        return info.jid;
    }else if([inputObject isKindOfClass:[CrowdInfo class]])
    {
        CrowdInfo *info = inputObject;
        return info.session_id;
    }else if([inputObject isKindOfClass:[ChatGroupInfo class]])
    {
        ChatGroupInfo *info = inputObject;
        return info.sessionId;
    }else if([inputObject isKindOfClass:[LightAppInfo class]])
    {
        LightAppInfo *info = inputObject;
        NSRange range = [info.appid rangeOfString:@"@lightapp"];
        if(range.location!=NSNotFound)
        {
            return [info.appid substringToIndex:range.location];
        }
        return info.appid;
    }else
    {
        return nil;
    }
  
}

@end
