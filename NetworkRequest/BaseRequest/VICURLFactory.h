//
//  VICURLFactory.h
//  CommonAPI
//
//  Created by qianyb on 15/4/10.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICURLFactory : NSObject

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *uploadBaseURL;


+ (VICURLFactory *)shardFactoryHandle;

/**
 *  返回URL地址
 *
 *  @return 服务端API的URL地址
 */
- (NSURL *)relativeBaseURL;
/**
 *  返回URL地址
 *
 *  @return 服务端上传文件的URL地址
 */
- (NSURL *)uploadRelativeBaseURL;


@end
