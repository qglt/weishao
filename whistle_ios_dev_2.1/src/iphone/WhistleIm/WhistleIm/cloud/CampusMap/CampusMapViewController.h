//
//  CampusMapViewController.h
//  WhistleIm
//
//  Created by liming on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "ClouldActivityManager.h"

@interface CampusMapViewController : UIViewController <MAMapViewDelegate, AMapSearchDelegate, ActivityListDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end
