//
//  CampusNavigationMenuController.h
//  WhistleIm
//
//  Created by liming on 14-3-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericController.h"

typedef enum {
    MenuItem_Cancel = 0,
    MenuItem_MapActivity,
    MenuItem_MapCopon,
    MenuItem_Exit
} CampusMapItem;




@protocol CampusNavigationDelegate <NSObject>

-(void)onItemSelected:(CampusMapItem)itemIndex;

@end



@interface CampusNavigationMenuController : NSObject <GenericeController>

-(id)initWithCampusNavigationDelegate:(id<CampusNavigationDelegate>)delegate;

-(void)showMenu:(void (^)()) callback;

-(void)hideMenu:(void (^)()) callback;

@end
