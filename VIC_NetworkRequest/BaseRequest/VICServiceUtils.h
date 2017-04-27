//
//  VICServiceUtils.h
//  1Home
//
//  Created by zx on 15/9/14.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICServiceUtils : NSObject

/**
 *  将字典里面的参数按照自然排序拼接，并转化成字符串返回（会对中文进行转码）
 *
 *  @param dict 要转化的字典
 *  @param md5  是否需要md5加密
 *
 *  @return 经过处理后的字符串
 */
+ (NSString *)stringFromDict:(NSDictionary *)dict withMD5:(BOOL)md5;


/*
 *  URLEncode
 */
+ (NSString*)urlEncodedString:(NSString *)string;

/**
 *  获取本机Ip
 *
 *  @return ip
 */
+ (NSString *)getIpAddress;

@end
