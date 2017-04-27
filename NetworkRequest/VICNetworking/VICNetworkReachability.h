//
//  VICNetworkReachability.h
//  BaoYangHuiTechnician
//
//  Created by ygx on 14-11-4.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICNetworkReachability : NSObject



/**
 *  网络是否可以连接
 */
+ (BOOL)isReachable;

/**
 *  WiFi是否可以连接
 */
+ (BOOL)isReachableViaWiFi;

/**
 *  WWAN是否可以连接
 */
+ (BOOL)isReachableViaWWAN;

@end
