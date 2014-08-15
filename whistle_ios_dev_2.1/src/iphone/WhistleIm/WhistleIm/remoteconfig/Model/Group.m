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
    NSArray *keyArray = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",
                          @"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
    //不可变数据转为可变数组
    NSMutableArray *infoArray = [NSMutableArray arrayWithArray:array];
    for (int i = 0; i < [keyArray count]; i++) {
        
        Group *group = [[Group alloc] init];
        NSMutableArray *arrayGroup = [[NSMutableArray alloc] initWithCapacity:2];
        NSString *key = keyArray[i];
        //遍历得到的数据
        for (int j = 0; j < infoArray.count; j++) {
            RemoteConfigInfo *info = infoArray[j];
            NSString *pinYing = [info.pinyin substringWithRange:NSMakeRange(0, 1)];
            if ([key isEqualToString:pinYing]) {
                group.groupName = key;
                [arrayGroup addObject:info];
//                [infoArray removeObject:info];//有漏洞，只比较了第一个字母
            }
        }
        group.array = arrayGroup;
        if (group.array.count != 0) {
            [dataArray addObject:group];
        }
    }
//    for (Group *group in dataArray) {
//        for (RemoteConfigInfo *info in group.array) {
//            LOG_GENERAL_INFO(@"info.name = %@",info.name);
//        }
//    }
    return dataArray;
}
@end
