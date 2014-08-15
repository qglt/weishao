//
//  EventDateFormat.h
//  WhistleIm
//
//  Created by wangchao on 13-8-12.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventDateFormat : NSObject

@property(nonatomic,strong) NSString *todayDate;
@property(nonatomic,strong) NSString *yesterdayDate;
@property(nonatomic,strong) NSString *beforeYesterdayDate;
@property(nonatomic,strong) NSString *oldDate;
@property(nonatomic,strong) NSMutableDictionary *dataMap;
@property(nonatomic,strong) NSString * checkDateChangeStr;


+(EventDateFormat *) format;
//-(void) reset;
-(NSString *) getSuitableDataString:(NSString *)data;
-(NSString *)parseAnanRecentListTime:(NSString *)time;
-(NSString *)parseTime:(NSString *)time;
+(NSString *)formatTime:(NSString *)time;

@end
