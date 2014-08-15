//
//  GetFrame.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "GetFrame.h"
#import "WhistleAppDelegate.h"
#define ISO7_HEIGHT 64.0f
//#define IS_RETINA       (CC_CONTENT_SCALE_FACTOR() == 2)
#define IS_RETINA       ([[CCDirector sharedDirector] contentScaleFactor] == 2)

#import "FriendInfo.h"
#import "CrowdInfo.h"

@interface GetFrame ()

@end

@implementation GetFrame

+ (id)shareInstance
{
    static GetFrame * mySelf = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[GetFrame alloc] init];
    });
    return mySelf;
}


- (BOOL)isIOS7Version
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9f) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)is4InchScreen
{
    BOOL result = NO;
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (frame.size.height > 480.0f) {
        result = YES;
    }
    return result;
}

- (void)setNavigationBarForController:(UIViewController *)controller
{
    UIImage * image = [UIImage imageNamed:@"navigationbar_default.png"];
    [controller.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    controller.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [controller.navigationController.navigationBar setTintColor:[UIColor colorWithRed:31 /255.0f green:137 /255.0f blue:91 /255.0f alpha:1.0f]];
}
- (BOOL) isRetinaScreen
{
    if ([UIScreen mainScreen].scale > 1) {
        return YES;
    }
    return NO;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
   // CFRelease(imageRef);
    
    CGImageRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;

}

- (UIImage *)getFriendHeadImageWithFriendInfo:(FriendInfo *)friendInfo convertToGray:(BOOL)isGray
{
    UIImage * image = nil;
    
    if ([friendInfo.head length] > 0) {
        image = [UIImage imageWithContentsOfFile:friendInfo.head];
    }

    if (image == nil) {
        if ([friendInfo.sexShow isEqualToString:SEX_GIRL]) {
            image = [UIImage imageNamed:@"identity_woman.png"];
        } else {
            image = [UIImage imageNamed:@"identity_man_new.png"];
        }
    }
    
    if (isGray) {
        if (![friendInfo isOnline]) {
            image = [self convertImageToGrayScale:image];
        }
    }
   
    return image;
}

@end
