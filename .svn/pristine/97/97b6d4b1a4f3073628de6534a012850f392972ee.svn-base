//
//  CampusActivityTypeChooser.h
//  WhistleIm
//
//  Created by liming on 14-3-6.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericController.h"

@protocol CampusActivityTypeChooserDelegate <NSObject>

-(void)onTypeSelected:(NSInteger)typeIndex withText:(NSString *)text withNormalImageName:(NSString *)normalName withHighlightImageName:(NSString *)hightlightName;

@end


@interface CampusActivityTypeChooser : NSObject<GenericeController>

-(id)initWithDelegate:(id<CampusActivityTypeChooserDelegate>)delegate;

-(void)showChooser:(void (^)()) callback;

-(void)hideChooser:(void (^)()) callback;

@end
