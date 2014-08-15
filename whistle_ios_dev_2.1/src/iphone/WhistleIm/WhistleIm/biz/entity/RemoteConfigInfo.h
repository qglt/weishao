//
//  RemoteConfigInfo.h
//  WhistleIm
//
//  Created by liuke on 13-12-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "Entity.h"
#import "Jsonable.h"

@interface RemoteConfigInfo : Entity<Jsonable>

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* domain;
@property (strong, nonatomic) NSString* pinyin;
@property (nonatomic, readonly) BOOL isRecommand;

//@property (strong, nonatomic) NSString* http_root;
//@property (strong, nonatomic) NSString* server;
//@property (strong, nonatomic) NSString* port;
//@property (strong, nonatomic) NSString* eportal_explorer_url;

@end
