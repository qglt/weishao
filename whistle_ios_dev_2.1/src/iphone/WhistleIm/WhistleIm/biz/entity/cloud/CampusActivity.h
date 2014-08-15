//
//  CampusActivity.h
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jsonable.h"
#import "Entity.h"
#import <MAMapKit/MAMapKit.h>


@interface CampusActivity : Entity<Jsonable, MAAnnotation>

@property (nonatomic,copy) NSString *game_id;
@property (nonatomic,copy) NSString *creator_jid;
@property (nonatomic,copy) NSString *game_name;
@property (nonatomic,copy) NSString *type;
@property float lon;
@property float lat;
@property int limit_number;
@property int member_number;
@property (nonatomic,copy) NSString *game_desc;
@property (nonatomic,strong) NSMutableArray *attendee;
@property (nonatomic,strong) NSDate *ctime;
@property (nonatomic,strong) NSDate *begin_time;
@property (nonatomic,strong) NSDate *end_time;
//@property (nonatomic,assign) int status;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+(NSString *)getActivityTypeText:(int)type;

@end
