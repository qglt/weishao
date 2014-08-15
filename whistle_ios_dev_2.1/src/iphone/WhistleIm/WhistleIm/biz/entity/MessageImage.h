//
//  MessageImage.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "MessageText.h"

@class FICDPhoto;

@interface MessageImage : MessageText


@property (nonatomic, copy)   NSString *imageId;

@property (nonatomic, copy)   NSString *name;

@property (nonatomic, copy)   NSString *imagePath;

@property (nonatomic, assign) Boolean   isDownLoad;

@property (nonatomic, assign) int       imageHeight;

@property (nonatomic, assign) int       imageWidth;

@end
