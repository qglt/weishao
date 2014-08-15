//
//  CampusActivity.m
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivity.h"



@implementation CampusActivity

-(id)initFromJsonObject:(NSDictionary *)jsonObj
{
    self = [self init];
    if(self){
        self.game_id = [jsonObj objectForKey:@"game_id"];
        self.creator_jid = [jsonObj objectForKey:@"creator_jid"];
        self.game_name = [jsonObj objectForKey:@"game_name"];
        self.type = [jsonObj objectForKey:@"type"];
        id value = [jsonObj valueForKey:@"lon"];
        NSNumber *num = value;
        CLLocationDegrees longtitude = 116;//[num floatValue];
        self.lon = [num floatValue];
        NSLog(@"pass lon for %f, %f",longtitude,self.lon);
        num = [jsonObj valueForKey:@"lat"];
        self.lat = [num floatValue];
        CLLocationDegrees latitude = 39;//[num floatValue];
        NSLog(@"pass lat for %f, %f",latitude,self.lat);
        num = [jsonObj valueForKey:@"limit_number"];
        self.limit_number = [num integerValue];
        num = [jsonObj valueForKey:@"member_number"];
        self.member_number = [num integerValue];
        num = nil;
        self.game_desc = [jsonObj objectForKey:@"game_desc"];
        NSString *dateString = [jsonObj valueForKey:@"ctime"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
        self.ctime = [dateFormat dateFromString:dateString];
        dateString = [jsonObj valueForKey:@"begin_time"];
        self.begin_time = [dateFormat dateFromString:dateString];
        dateString = [jsonObj valueForKey:@"end_time"];
        self.end_time = [dateFormat dateFromString:dateString];
        dateString = nil;
        dateFormat = nil;
        
        self.coordinate = CLLocationCoordinate2DMake(self.lat,self.lon);
        
        //[self setCoordinate:CLLocationCoordinate2DMake(self.lat,self.lon)];
        NSLog(@"parse point < %f, %f >",self.coordinate.longitude,self.coordinate.latitude);
    }
    
    return self;

}


-(NSString *)title
{
    return self.game_name;
}

-(NSString *)subtitle
{
    return [NSString stringWithFormat:@"发起人：%@",self.creator_jid];
}

+(NSString *)getActivityTypeText:(int)type
{
    return [NSString stringWithFormat:@"type%d",type];
}

@end
