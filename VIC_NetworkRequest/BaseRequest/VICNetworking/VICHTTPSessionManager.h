//
//  VICHTTPSessionManager.h
//  BaoYangHuiTechnician
//
//  Created by ygx on 14-11-4.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

#import "AFHTTPSessionManager.h"

//请求失败后调用此block，包含一个NSError参数
typedef void (^ErrorBlock) (NSError *error);

//请求过程中进度发生改变时调用此block，包含一个double参数
typedef void (^ProgressBlock) (CGFloat progress);

//请求成功后调用此block，包含一个NSDictionary参数
typedef void (^SuccessBlock) (NSDictionary *responseDic);

typedef NS_ENUM(NSUInteger, VICRequestMethod) {
    VICRequestMethodGet,
    VICRequestMethodPut,
    VICRequestMethodPost,
    VICRequestMethodHead,
    VICRequestMethodDelete,
    VICRequestMethodError,
};

/**
 *  http://objccn.io/issue-5-4/
 *  iOS7之后，Apple 推出了NSURLSession，用来取代NSURLConnection
 *  AFHTTPSessionManager 基于 NSURLSession
 *  AFHTTPRequestOperationManager 基于 NSURLConnection
 */
@interface VICHTTPSessionManager : AFHTTPSessionManager

/**
 *  Api 请求数据
 *
 *  @param apiPath      Api
 *  @param parameters   参数
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
- (void)restApi:(NSString *)apiPath parameters:(NSDictionary *)parameters success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock;

/**
 *  下载文件
 *
 *  @param url           文件URL
 *  @param fullPath      文件保存位置
 *  @param successBlock  成功回调
 *  @param errorBlock    失败回调
 *  @param progressBlock 进度回调
 */
- (void)downloadFileWithURL:(NSString *)url
                     AtPath:(NSString *)fullPath
                    success:(SuccessBlock)successBlock
                      error:(ErrorBlock)errorBlock
                   progress:(ProgressBlock)progressBlock;

/**
 *  上传图片Data
 *
 *  @param data             要上传的Data
 *  @param url              请求url地址
 *  @param params           参数
 *  @param successBlock     成功回调
 *  @param errorBlock       失败回调
 *  @param progressBlock    进度回调
 */
- (void)uploadImageData:(NSData *)data withURLString:(NSString *)URLString parameters:(NSDictionary *)params success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock;
/**
 *  批量上传文件
 *
 *  @param filePaths        要上传的文件路径数组
 *  @param url              请求url地址
 *  @param params           参数
 *  @param successBlock     成功回调
 *  @param errorBlock       失败回调
 *  @param progressBlock    进度回调
 */
- (void)uploadFiles:(NSArray *)filePaths
      withURLString:(NSString *)URLString
         parameters:(NSDictionary *)params
            success:(SuccessBlock)successBlock
              error:(ErrorBlock)errorBlock
           progress:(ProgressBlock)progressBlock;


@end
