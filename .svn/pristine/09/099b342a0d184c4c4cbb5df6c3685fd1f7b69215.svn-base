//
//  CloudAccountManager.m
//  WhistleIm
//
//  Created by liming on 14-1-24.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CloudAccountManager.h"
#import "ASIFormDataRequest.h"
#import "RosterManager.h"
#import "FriendInfo.h"
#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"
#import "CloudConstant.h"

@interface CloudAccountManager()
@property (assign) BOOL cloudAvaible;
@property (assign) BOOL cloudOpen;
@property (assign) int activityHits;
@property (copy, nonatomic) NSString *session;
@property (copy, nonatomic) NSString *selfJid;

@end

#define MyselfInfo  [[RosterManager shareInstance] mySelf]

@implementation CloudAccountManager

SINGLETON_IMPLEMENT(CloudAccountManager)

-(id)init
{
    self = [super init];
    if(self){
        self.cloudAvaible = NO;
        self.selfJid = nil;
        self.session = nil;
        self.activityHits = 0;
        
    }
    
    return self;
}

-(BOOL)isCloudAvaible
{
    return self.cloudAvaible;
}

-(BOOL)isCloudOpen
{
    return self.cloudOpen;
}

-(NSString *)getSession
{
    return self.session;
}

-(NSString *)getMyJid
{
    return self.selfJid;
}

-(void)reset
{
    self.cloudAvaible = NO;
    self.cloudOpen = NO;
    self.selfJid = nil;
    self.session = nil;
    self.activityHits = 0;
}

-(void)getRosterFinish:(NSMutableArray *)friendGroupList
{
    if(self.selfJid == nil){
        self.selfJid = MyselfInfo.jid;
        httpstringresult callback = ^(NSString *result){
            if(self.cloudOpen){
                httpstringresult loginCallback = ^(NSString *result){
                    NSLog(@"=======> cloudLogin ok!");
                };
                [self doUserLogin:loginCallback];
            }
        };
        
        [self doCheckUserStatus:callback];
    }
}
-(void)doCheckUserStatus:(httpstringresult)result
{
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kRegisterStatusUrl)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    
    
    [request setPostValue:MyselfInfo.jid forKey:@"jid"];
    NSLog(@"jid:%@",MyselfInfo.jid);
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        NSLog(@"-------------->doCheckUserStatus %@",responseString);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:responseString];;
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            NSLog(@"ret value is NSNumber %d",((NSNumber *)value).intValue);
            self.cloudAvaible = YES;
            if(((NSNumber *)value).intValue == 0){
                self.cloudOpen = YES;
            }else{
                self.cloudOpen = NO;
                httpstringresult callback = ^(NSString *result){
                };
                [self doUserRegister:callback];
            }
        }

        result(responseString);
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        self.cloudAvaible = NO;
        
        result([error description]);
        
    }];
    [request startAsynchronous];
    
}


-(void)doUserRegister:(httpstringresult)result
{
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kRegisterUrl)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    
    [request setPostValue:MyselfInfo.jid forKey:@"jid"];
    [request setPostValue:MyselfInfo.aid forKey:@"aid"];
    [request setPostValue:[[BizlayerProxy shareInstance] getDomain] forKey:@"school"];
    [request setPostValue:MyselfInfo.username forKey:@"username"];
    [request setPostValue:MyselfInfo.name forKey:@"name"];
    [request setPostValue:@"ios" forKey:@"device_type"];
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        NSLog(@"register response %@",responseString);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:responseString];;
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            
            if(((NSNumber *)value).intValue == 0){
                self.cloudOpen = YES;
                
            }else{
                
            }
        }

        
        result(responseString);
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        //NSLog(@"register failed with %@",[error description]);
        result([error description]);
        
    
    }];
    [request startAsynchronous];
    
}

-(void)doUserLogin:(httpstringresult)result
{
    NSURL *url = [NSURL URLWithString:GETSERVERCOMMAND(kLoginUrl)];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    
    [request setPostValue:MyselfInfo.jid forKey:@"jid"];
    [request setPostValue:@"ios" forKey:@"device_type"];
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        NSLog(@"login return %@",responseString);
        NSDictionary *paraJson = [JSONObjectHelper decodeJSON:responseString];;
        id value = [paraJson valueForKey:@"ret"];
        if([value isKindOfClass:[NSNumber class]]){
            
            if(((NSNumber *)value).intValue == 0){
                NSDictionary *data = [paraJson valueForKey:@"data"];
                self.session = [data valueForKey:@"verify"];
                
            }else{
                
            }
        }
        
        result(responseString);
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        //NSLog(@"register failed with %@",[error description]);
        result([error description]);
        
        
    }];
    [request startAsynchronous];
    
}

-(void)appendCommonHeader:(ASIFormDataRequest *)request
{
    [request setPostValue:self.session forKey:@"verify"];
    [request setPostValue:@"ios" forKey:@"device_type"];

}


@end
