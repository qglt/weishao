//
//  Entity.h
//  WhistleIm
//
//  Created by liuke on 13-11-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultInfo.h"
#import "Jsonable.h"

#define ENCODE(CLASS) do{NSMutableDictionary* tmp = [[NSMutableDictionary alloc] initWithCapacity:30]; \
                        [tmp addEntriesFromDictionary:[super encode]];\
                        [tmp addEntriesFromDictionary:[self encode:self classType:[CLASS class]]];\
                        return tmp;}while(0);

@protocol ToStringDelegate <NSObject>

@optional
- (NSString*) toString;

@end

@interface Entity : NSObject<ToStringDelegate>

- (ResultInfo*) parseCommandResusltInfo:(id)result;


- (NSString*) toString:(id) obj;

- (NSDictionary*) encode:(id) obj classType:(Class) classType;

- (NSDictionary*) encode;

- (void) decode:(NSDictionary*) data obj:(id) obj;

- (BOOL) isNull:(id) obj;

//- (BOOL) merge:(id) dest src:(id) src;
@end
