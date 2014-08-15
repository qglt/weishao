//
//  MessageImage.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "MessageImage.h"

@implementation MessageImage

@synthesize imageId;
@synthesize name;
@synthesize isDownLoad;
@synthesize imagePath;

@synthesize yourcls;
@synthesize style;
@synthesize time;
@synthesize txt;


-(void)dealloc
{
    imageId = nil;
    name = nil;
    yourcls = nil;
    style = nil;
    time = nil;
    imagePath =nil;
}

@end
