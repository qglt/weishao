//
//  ImageUtil.m
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "ImageUtil.h"
#import "GetFrame.h"

@implementation ImageUtil

+ (UIImage*) getImageByImageNamed:(NSString*) path Consider:(BOOL)isConsider4InchScreen
{
    
    NSString* fileName = nil;
    NSString* ext = nil;
    NSRange range = [path rangeOfString:@"."];
    NSLog(@"range : %d, %d", range.location, range.length);
    if (range.length > 0) {
        fileName = [path substringWithRange:NSMakeRange(0, range.location)];
        ext = [path substringWithRange:NSMakeRange(range.location + 1, path.length - range.location - 1)];
        if (!fileName || !ext) {
            return nil;
        }
    }else{
        return nil;
    }
    NSLog(@"filename:%@,ext:%@", fileName, ext);
    if ([[GetFrame shareInstance] isRetinaScreen]) {
        if(isConsider4InchScreen && [[GetFrame shareInstance] is4InchScreen])
        {
            NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-568h@2x",fileName] ofType:ext];
            NSLog(@"file:%@", file);
            UIImage* img = [UIImage imageWithContentsOfFile:file];
            if (img) {
                return img;
            }
        }
        NSString *file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@2x",fileName] ofType:ext];
        NSLog(@"file:%@", file);
        UIImage* img = [UIImage imageWithContentsOfFile:file];
        if (img) {
            return img;
        }
        file = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@2X",fileName] ofType:ext];
        NSLog(@"file:%@", file);
        return [UIImage imageWithContentsOfFile:file];
        
        
    }else{
        NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
        NSLog(@"file:%@", file);
        return [UIImage imageWithContentsOfFile:file];
    }
    return nil;
}


@end
