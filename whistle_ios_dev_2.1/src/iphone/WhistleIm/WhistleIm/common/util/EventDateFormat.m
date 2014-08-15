//
//  EventDateFormat.m
//  WhistleIm
//
//  Created by wangchao on 13-8-12.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "EventDateFormat.h"
#define TODAT_STR @"今天"
#define YESTERDAY_STR @"昨天"
#define DAY_BEFORE_YESTERDAY @"前天"

@implementation EventDateFormat
- (id)init
{
    self = [super init];
    if (self) {
        [self initEnvironment];
    }
    return self;
}

+(EventDateFormat *)format
{
    static EventDateFormat* _sp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sp = [[EventDateFormat alloc] init];
    });
    return _sp;
}

-(void)initEnvironment
{
    if(self.dataMap == nil)
    {
        self.dataMap = [NSMutableDictionary dictionary];
    }
    [self.dataMap removeAllObjects];
    NSString *partten = @"yyyy-MM-dd";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:partten];
    NSDate *now = [NSDate date];
    self.todayDate = [format stringFromDate:now];
    [self.dataMap setObject:TODAT_STR forKey:self.todayDate];
    
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:-24*60*60];
    self.yesterdayDate = [format stringFromDate:yesterday];
    [self.dataMap setObject:YESTERDAY_STR forKey:self.yesterdayDate];
    
    NSDate *BeforeYesterday = [[NSDate date] dateByAddingTimeInterval:-48*60*60];
    self.beforeYesterdayDate = [format stringFromDate:BeforeYesterday];
    [self.dataMap setObject:DAY_BEFORE_YESTERDAY forKey:self.beforeYesterdayDate];
    
    format = nil;

}

-(NSString *)getSuitableDataString:(NSString *)data
{
    if([self.dataMap objectForKey:data])
    {
        return [self.dataMap objectForKey:data];
    }
    return data;
}

-(NSString *)parseAnanRecentListTime:(NSString *)time
{
    if(time ==nil || [time isEqualToString:self.oldDate])
    {
        return nil;
    }
    NSString *date = time;
    self.oldDate = time;
    return  date;

}

-(NSString *)parseTime:(NSString *)time
{
    NSRange range = [time rangeOfString:@" "];
    NSString * formatterTime = [time substringToIndex:range.location];
    if ([formatterTime isEqualToString:self.todayDate]) {
        
        return [time substringWithRange:NSMakeRange(range.location+1, 5)];
    }else if ([formatterTime isEqualToString:self.yesterdayDate]) {
        
        return [self.dataMap objectForKey:self.yesterdayDate];
    }else if([formatterTime isEqualToString:self.beforeYesterdayDate])
    {
        return [self.dataMap objectForKey:self.beforeYesterdayDate];
    }else
    {
        NSArray *array = [formatterTime componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@年%@月%@日",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]];
    }
        
        
        
    return time;
}

+(NSString *)formatTime:(NSString *)time
{
   
    
//    if(time == nil  || [time rangeOfString:@":"].location == NSNotFound || ![time rangeOfString:@" "].location == NSNotFound)
//    {
//        return time;
//    }
//
//    int start = [time rangeOfString:@" "].location;
//    int end = [time rangeOfString:@":" options:NSBackwardsSearch].location;
//     NSLog(@"format time startis %i end is %i",start,end);
//    return [time substringWithRange:NSMakeRange(start, end-start)];
}

@end
