//
//  ClouldActivityManager.h
//  WhistleIm
//
//  Created by liming on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manager.h"
#import <MAMapKit/MAMapKit.h>


@protocol ActivityListDelegate <NSObject>

-(void)onActivityListRefreshed:(NSArray *)newList forPage:(int)page;

@end

@interface ClouldActivityManager : NSObject


@property (nonatomic,strong) MAUserLocation* cachedCenterPoint;
@property (nonatomic,strong) MAUserLocation* lastUserLocation;


SINGLETON_DEFINE(ClouldActivityManager)

-(void)addActivityListListener :(id<ActivityListDelegate>)listener;

-(void)removeActivityListener:(id<ActivityListDelegate>)listener;

-(void)listNearbyActivities:(NSInteger)page withType:(NSInteger)typeIndex /*forLocation:(CLLocationCoordinate2D)location*/;

-(void)listMyRelatedActivities:(NSInteger)page withType:(NSInteger)typeIndex;
-(void)createActivity:(NSString *)jid  withTitle:(NSString*)title withType:(NSString*)type withDesc:(NSString*)desc withDescIcon:(NSString*)src stratTime:(NSString*)stratTime endTime:(NSString*)endTime limitNumber:(NSInteger) limit longitude:(NSString*)longitude latitude:(NSString*)latitude coordinateName:(NSString*)coordinate_name callback:(void(^)(BOOL))callback;

-(void)reset;

-(void)participateInActivities:(BOOL)if_participate toActivity:(NSString *)activity_id;
@end
