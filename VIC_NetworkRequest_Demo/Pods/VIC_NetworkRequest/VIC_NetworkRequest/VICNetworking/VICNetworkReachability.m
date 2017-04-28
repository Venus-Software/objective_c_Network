//
//  VICNetworkReachability.m
//  BaoYangHuiTechnician
//
//  Created by ygx on 14-11-4.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

#import "VICNetworkReachability.h"
#import "AFNetworkReachabilityManager.h"

@implementation VICNetworkReachability

+ (BOOL)isReachable
{
    // Instances of AFNetworkReachabilityManager must be started with
    // startMonitoring before reachability status can be determined.
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    BOOL reachable = manager.reachable;
    [manager stopMonitoring];

    return reachable;
}

+ (BOOL)isReachableViaWiFi
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    BOOL reachable = manager.reachableViaWiFi;
    [manager stopMonitoring];

    return reachable;
}

+ (BOOL)isReachableViaWWAN
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    BOOL reachable = manager.reachableViaWWAN;
    [manager stopMonitoring];
    
    return reachable;
}

@end
