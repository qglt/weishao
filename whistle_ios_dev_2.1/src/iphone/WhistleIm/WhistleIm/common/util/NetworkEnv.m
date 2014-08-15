//
//  NetworkEnv.m
//  WhistleIm
//
//  Created by liuke on 13-10-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NetworkEnv.h"
#import "Reachability.h"
#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK

static BOOL _isConnectByWifi = NO;
static BOOL _isConnectByWlan = NO;

@implementation NetworkEnv


+ (BOOL) isConnectionNetwork {
    Reachability* r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            _isConnectByWifi = NO;
            _isConnectByWlan = NO;
            NSLog(@"联网失败");
            return NO;
            
        case ReachableViaWiFi:
            _isConnectByWifi = YES;
            _isConnectByWlan = NO;
            NSLog(@"使用WIFI联网成功");
            return YES;
            
        case ReachableViaWWAN:
            _isConnectByWifi = NO;
            _isConnectByWlan = YES;
            NSLog(@"使用WLAN联网成功");
            return YES;
            
        default:
            _isConnectByWifi = NO;
            _isConnectByWlan = NO;
            NSLog(@"不知道怎么联网的");
            return NO;
    }
    return NO;
}

+ (BOOL) isConnectedByWlan {
    return _isConnectByWlan;
}

+ (BOOL) isConnectedByWifi {
    return _isConnectByWifi;
}

+ (BOOL) isLocalWifiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
    	if (cursor -> ifa_addr -> sa_family == AF_INET
    		&& !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
    	{
    		// Check for WiFi adapter
    		if (strcmp(cursor -> ifa_name, "en0") == 0) {
    			wiFiAvailable = YES;
    			break;
    		}
    	}
    	cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}


@end
