//
//  CampusActivityEntryController.h
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CampusActivity.h"
#import "ClouldActivityManager.h"
#import "GenericController.h"

@protocol CampusActivityListDelegate <NSObject>

-(void)onSelectedActivity:(CampusActivity *)activity;

@end

@interface CampusActivityListController : NSObject <GenericeController, UITableViewDataSource,UITableViewDelegate, ActivityListDelegate>


@property (nonatomic,strong) id<CampusActivityListDelegate> pushDalegate;

-(void)loadData;

@end
