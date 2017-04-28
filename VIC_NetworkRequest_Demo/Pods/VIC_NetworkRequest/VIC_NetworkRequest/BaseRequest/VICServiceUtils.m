//
//  VICServiceUtils.m
//  1Home
//
//  Created by zx on 15/9/14.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import "VICServiceUtils.h"
#import <CommonCrypto/CommonCrypto.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#define PUBLIC_KEY @""

@implementation VICServiceUtils
/**
 *  将字典里面的参数按照自然排序拼接，并转化成字符串返回（会对中文进行转码）
 *
 *  @param dict 要转化的字典
 *  @param md5  是否需要md5加密
 *
 *  @return 经过处理后的字符串
 */
+ (NSString *)stringFromDict:(NSDictionary *)dict withMD5:(BOOL)md5
{
    //进行转码并排序之后的字符串
    NSString *str = [self sortStrByKeyFromDict:dict];
    if (md5) {
        return [self md5:str];
    }
    
    return str;
}

+ (NSString *)sortStrByKeyFromDict:(NSDictionary *) dict{
    NSString *str = @"";
    NSArray* arr = [dict allKeys];
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2){
        return [obj1 compare:obj2];
    }];
    for (NSString *key in arr) {
//        if ([[dict valueForKey:key] isKindOfClass:[NSString class]] && [[dict valueForKey:key] hasPrefix:@"http://"]) {
//            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,[self encodeToPercentEscapeString:dict[key] withStr:nil]]];
//        }else{
//            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,dict[key]]];
//        }
        
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@=%@",key,dict[key]]];
    }
    
    return str;
}


+ (NSString *)encodeToPercentEscapeString: (NSString *) input withStr:(NSString *)str
{
    if (str == nil) {
        //服务器端没有处理特殊符号"*"，参数中包含"*"会导致报签名错误，暂时不包含"*"
//        str = @"!'();:&=+$,/?%#[]";
        str = @"!'();:&=+$/?%#[]";
    }
    NSString *inputStr = [NSString stringWithFormat:@"%@",input];
    NSString *outputStr = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge CFStringRef)inputStr,NULL,(CFStringRef)str,kCFStringEncodingUTF8);
    return [outputStr stringByReplacingOccurrencesOfString:@"\%20" withString:@"+"];
}


+ (NSString *)md5:(NSString *)strForMD5
{
    NSString *str = [strForMD5 stringByAppendingString:PUBLIC_KEY];
    
    const char *cStr = [str UTF8String];
    
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    
    return [NSString stringWithFormat:
            
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0], result[1], result[2], result[3],
            
            result[4], result[5], result[6], result[7],
            
            result[8], result[9], result[10], result[11],
            
            result[12], result[13], result[14], result[15]
            ];
}
//URLEncode
+ (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}

+ (NSString *)getIpAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    //retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        //Loop througn linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            //Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                //Get NSString from C String
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    //Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
