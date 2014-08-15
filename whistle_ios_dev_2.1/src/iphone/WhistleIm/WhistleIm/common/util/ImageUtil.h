//
//  ImageUtil.h
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtil : NSObject
+ (UIImage*) getImageByImageNamed:(NSString*) path Consider:(BOOL)isConsider4InchScreen;
@end
