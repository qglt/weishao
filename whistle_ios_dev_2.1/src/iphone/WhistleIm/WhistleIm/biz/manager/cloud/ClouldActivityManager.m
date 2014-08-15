//
//  ClouldActivityManager.m
//  WhistleIm
//
//  Created by liming on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ClouldActivityManager.h"
#import "CloudConstant.h"
#import "CloudAccountManager.h"
#import "JSONObjectHelper.h"
#import "CampusActivity.h"
#import "CloudAccountManager.h"

@interface ClouldActivityManager()

@property (nonatomic,strong) NSMutableArray *activityList;
@property (nonatomic,strong) NSMutableArray *activityListeners;

@end

@implementation ClouldActivityManager

SINGLETON_IMPLEMENT(ClouldActivityManager)


-(id)init
{
    self = [super init];
    if(self){
        self.activityListeners = [[NSMutableArray alloc] init];
        self.activityList = [[NSMutableArray alloc] init];
        self.cachedCenterPoint = nil;
    }
    return self;
}

-(void)reset
{
    self.cachedCenterPoint = nil;
    [self.activityList removeAllObjects];
    [self.activityListeners removeAllObjects];
}

-(void)addActivityListListener:(id<ActivityListDelegate>)listener
{
    if([self.activityListeners indexOfObject:listener] == NSNotFound){
        NSLog(@"add listener for activity");
        [self.activityListeners addObject:listener];
    }
}

-(void)removeActivityListener:(id<ActivityListDelegate>)listener
{
    [self.activityListeners removeObject:listener];
}

-(void)createActivity:(NSString *)jid withTitle:(NSString *)title withType:(NSString *)type withDesc:(NSString *)desc withDescIcon:(NSString *)src stratTime:(NSString *)stratTime endTime:(NSString *)endTime limitNumber:(NSInteger)limit longitude:(NSString *)longitude latitude:(NSString *)latitude coordinateName:(NSString *)coordinate_name callback:(void (^)(BOOL))callback
{
    if([[CloudAccountManager shareInstance] getSession] == nil){
        NSLog(@"no session ready!");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kCreateActivity)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [[CloudAccountManager shareInstance] appendCommonHeader:request];
    
    [request setPostValue:jid forKey:@"jid"];
    [request setPostValue:title forKey:@"title"];
    [request setPostValue:@"school" forKey:@"school"];
    [request setPostValue:type forKey:@"type"];
    [request setPostValue:desc forKey:@"desc"];
    [request setFile:src forKey:@"desc_icon"];
    [request setPostValue:stratTime forKey:@"begin_time"];
    [request setPostValue:endTime forKey:@"end_time"];
    [request setPostValue:[NSNumber numberWithInteger:limit] forKey:@"limit_number"];
    [request setPostValue:[CloudAccountManager shareInstance].getSession forKey:@"verify"];
    [request setPostValue:@"ios" forKey:@"device_type"];
    
    [request setPostValue:longitude forKey:@"lon"];
    [request setPostValue:latitude forKey:@"lat"];
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSLog(@"list back %@",[request responseString]);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:[request responseString]];
        NSString *value = [paraJson valueForKey:@"errmsg"];
        callback([value isEqualToString:@"ok"]);
        
        
    }];
    [request setFailedBlock:^{
        callback(NO);
    }];
    [request startAsynchronous];
    
}

-(void)listMyRelatedActivities:(int)page withType:(NSInteger)typeIndex
{
    NSLog(@"listNearbyActivities");
    if([[CloudAccountManager shareInstance] getSession] == nil){
        NSLog(@"no session ready!");
        return;
    }
    
    if(self.cachedCenterPoint == nil){
        NSLog(@"no location yet!");
        return ;
    }
    
    CLLocation *location = [self.cachedCenterPoint location];
    //location
    NSLog(@"listNearbyActivities ready for location <%f,%f>",location.coordinate.longitude,location.coordinate.latitude);
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kListAllMyActivityNearby)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [[CloudAccountManager shareInstance] appendCommonHeader:request];
    
    //[request setPostValue:[NSNumber numberWithFloat:116.299722f] forKey:@"lon"];
    //[request setPostValue:[NSNumber numberWithFloat:39.9075f] forKey:@"lat"];
    [request setPostValue: [[CloudAccountManager shareInstance] getMyJid] forKey:@"jid"];
    [request setPostValue:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"lon"];
    [request setPostValue:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithInt:2000] forKey:@"range"];
    //if(page > 0){
    [request setPostValue:[NSNumber numberWithInt:page] forKey:@"hits"];
    //}
    if(typeIndex != 0){
        [request setPostValue:[NSNumber numberWithInt:typeIndex] forKey:@"type"];
    }
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSLog(@"list back %@",[request responseString]);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:[request responseString]];
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            
            if(((NSNumber *)value).intValue == 0){
                NSArray *data = [paraJson valueForKey:@"data"];
                NSMutableArray *activities = [[NSMutableArray alloc] init];
                for (NSDictionary *obj in data) {
                    CampusActivity *act = [[CampusActivity alloc] initFromJsonObject:obj];
                    [act setCoordinate:CLLocationCoordinate2DMake(act.lat,act.lon)];
                    NSLog(@"get activity for point <%f,%f>",act.coordinate.longitude,act.coordinate.latitude);
                    [activities addObject:act];
                }
                
                NSLog(@"listener counts %d",[self.activityListeners count]);
                
                for (id<ActivityListDelegate> listener in self.activityListeners){
                    [listener onActivityListRefreshed:activities forPage:page];
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                
                //});
                
            }else{
                
            }
        }
        
        //result([request responseString]);
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        
        
    }];
    [request setFailedBlock:^{
        //NSLog(@"register failed with %@",[error description]);
        //result([[request error] description]);
        
    }];
    [request startAsynchronous];
    

}

-(void)listNearbyActivities:(int)page withType:(NSInteger)typeIndex
{
    NSLog(@"listNearbyActivities");
    if([[CloudAccountManager shareInstance] getSession] == nil){
        NSLog(@"no session ready!");
        return;
    }
    
    if(self.cachedCenterPoint == nil){
        NSLog(@"no location yet!");
        return ;
    }
    
    CLLocation *location = [self.cachedCenterPoint location];
    //location
    NSLog(@"listNearbyActivities ready for location <%f,%f>",location.coordinate.longitude,location.coordinate.latitude);
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kListAllActivityNearby)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [[CloudAccountManager shareInstance] appendCommonHeader:request];
    //[request setPostValue:[NSNumber numberWithFloat:116.299722f] forKey:@"lon"];
    //[request setPostValue:[NSNumber numberWithFloat:39.9075f] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"lon"];
    [request setPostValue:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"lat"];
    [request setPostValue:[NSNumber numberWithInt:2000] forKey:@"range"];
    //if(page > 0){
        [request setPostValue:[NSNumber numberWithInt:page] forKey:@"hits"];
    //}
    if(typeIndex != 0){
        [request setPostValue:[NSNumber numberWithInt:typeIndex] forKey:@"type"];
    }
    
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSLog(@"list back %@",[request responseString]);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:[request responseString]];
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            
            if(((NSNumber *)value).intValue == 0){
                NSArray *data = [paraJson valueForKey:@"data"];
                NSMutableArray *activities = [[NSMutableArray alloc] init];
                for (NSDictionary *obj in data) {
                    CampusActivity *act = [[CampusActivity alloc] initFromJsonObject:obj];
                    [act setCoordinate:CLLocationCoordinate2DMake(act.lat,act.lon)];
                    NSLog(@"get activity for point <%f,%f>",act.coordinate.longitude,act.coordinate.latitude);
                    [activities addObject:act];
                }
                
                NSLog(@"listener counts %d",[self.activityListeners count]);
                
                for (id<ActivityListDelegate> listener in self.activityListeners){
                    [listener onActivityListRefreshed:activities forPage:page];
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                    
                //});
                
            }else{
                
            }
        }
       
        //result([request responseString]);
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        
        
    }];
    [request setFailedBlock:^{
        //NSLog(@"register failed with %@",[error description]);
        //result([[request error] description]);
        
    }];
    [request startAsynchronous];
    
    
}
#pragma mark - 参加活动
-(void)participateInActivities:(BOOL)if_participate toActivity:(NSString *)activity_id
{
    NSURL *url;
    
    if (if_participate){
        
        url = [NSURL URLWithString:GETSERVERCOMMAND(KGameJoin)];
    }
    else{
        
        url = [NSURL URLWithString:GETSERVERCOMMAND(KGameQuit)];
    }
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [[CloudAccountManager shareInstance] appendCommonHeader:request];
    
    [request setPostValue: [[CloudAccountManager shareInstance] getMyJid] forKey:@"jid"];
    [request setPostValue:activity_id forKey:@"game_id"];
    
    NSLog(@"request = %@",request.postBody);
    [request setCompletionBlock:^{

        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:[request responseString]];
        NSLog(@"%@",paraJson);
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            
            if(((NSNumber *)value).intValue == 0){
                NSArray *data = [paraJson valueForKey:@"data"];
                
                NSLog(@"%@",data);
                
                
            }else{
                
            }
        }
        
    }];
    [request setFailedBlock:^{
        //NSLog(@"register failed with %@",[error description]);
        //result([[request error] description]);
        
    }];
    [request startAsynchronous];

}
@end
