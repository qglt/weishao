//
//  NativeAppInfo.h
//  WhistleIm
//
//  Created by liuke on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "Entity.h"
#import "BaseAppInfo.h"
/**
 *  本地应用app的实体类，指在App Store上的应用
 */

@interface NativeAppInfo : BaseAppInfo

@property (nonatomic, strong) NSString* customInfo;
@property (nonatomic, strong) NSString* version;
//应用的定制化信息
@property (nonatomic, strong) NSString* redirect;
@property (nonatomic, strong) NSString* templates;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSString* packageName;
@property (nonatomic, strong) NSString* package;
@property (nonatomic, strong) NSString* packageSize;

@end
