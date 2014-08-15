//
//  CloudAccountManager.h
//  WhistleIm
//
//  Created by liming on 14-1-24.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Manager.h"
#import "RosterManager.h"
#import "ASIFormDataRequest.h"

typedef void (^httpstringresult)(NSString *);



@interface CloudAccountManager : NSObject<RosterDelegate>

SINGLETON_DEFINE(CloudAccountManager)


-(BOOL)isCloudAvaible;

-(BOOL)isCloudOpen;

-(void)reset;

-(NSString *)getSession;

-(NSString *)getMyJid;

-(void)appendCommonHeader:(ASIFormDataRequest *)request;

-(void)doCheckUserStatus:(httpstringresult)result;

-(void)doUserRegister:(httpstringresult)result;

-(void)doUserLogin:(httpstringresult)result;

//-(void)listNearbyActivities:(httpstringresult)result;

@end
