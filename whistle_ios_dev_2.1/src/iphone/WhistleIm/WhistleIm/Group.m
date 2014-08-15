//
//  Group.m
//  WhistleIm
//
//  Created by 移动组 on 13-12-18.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Group.h"
#import "RemoteConfigInfo.h"
@implementation Group
- (NSMutableArray *)dataSource:(NSArray *)array
{

    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *keyArray = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    NSMutableArray *infoArray = [NSMutableArray arrayWithArray:array];
    for (int i = 0; i < [keyArray count]; i++) {
        Group *group = [[Group alloc] init];
        NSMutableArray *arrayGroup = [[NSMutableArray alloc] initWithCapacity:2];
        NSString *key = keyArray[i];
        for (int j = 0; j < infoArray.count; j++) {
            RemoteConfigInfo *info = infoArray[j];
            NSString *pinYing = [info.pinyin substringWithRange:NSMakeRange(0, 1)];
            if ([key isEqualToString:pinYing]) {
                group.groupName = key;
                [arrayGroup addObject:info];
                [infoArray removeObject:info];
            }
        }
        group.array = arrayGroup;
        if (group.array.count != 0) {
            [dataArray addObject:group];
        }
    }
    return dataArray;
}
@end
