//
//  VICBaseService.h
//  BaoYangHuiTechnician
//
//  Created by 攸广欣 on 14-11-3.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

/**
 *  1. Rest Api提供四个接口, restApi(默认有Hud)、restApiWithoutHud(自己管理Hud)、restApiWithID(参数中包含特殊的ID参数)、restApiWithoutHud(自己管理Hud)
 *  2. download提供两个接口，下载文件到默认文件夹(tmp/download)、下载文件夹到指定文件夹(需传入包含file_name/file_path的字典)
 *  3. upload提供两个接口，根据文件路径上传、根据NSData上传
 */

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "VICNetworkKit.h"

@interface VICBaseService : NSObject
#pragma mark - Rest Request

/**
 *  请求数据，默认有Hud
 *
 *  @param api          api地址
 *  @param dict         请求参数
 *  @param successBlock 请求成功回调
 *  @param errorBlock   请求失败回调
 */
+ (void)restApi:(NSString *)api
     parameters:(NSDictionary *)dict
        success:(SuccessBlock)successBlock
          error:(ErrorBlock)errorBlock;
/**
 *  请求数据，没有Hud
 *
 *  @param api          api地址
 *  @param dict         请求参数
 *  @param successBlock 请求成功回调
 *  @param errorBlock   请求失败回调
 */
+ (void)restApiWithOutHud:(NSString *)api
               parameters:(NSDictionary *)dict
                  success:(SuccessBlock)successBlock
                    error:(ErrorBlock)errorBlock;

+ (void)restApi:(NSString *)api
     parameters:(NSDictionary *)dict
        success:(SuccessBlock)successBlock
          error:(ErrorBlock)errorBlock
        showHud:(BOOL)showHud;
#pragma mark - download

/**
 *  下载文件到默认文件夹 tmp/download/
 *
 *  @param fileName      文件名
 *  @param successBlock  下载成功回调
 *  @param errorBlock    下载失败回调
 *  @param progressBlock 进度回调
 */
+ (void)downloadFile:(NSString *)fileName
             success:(SuccessBlock)successBlock
               error:(ErrorBlock)errorBlock
            progress:(ProgressBlock)progressBlock;

/**
 *  下载文件到指定文件夹
 *
 *  @param fileName      文件名
 *  @param filePath      文件夹位置
 *  @param successBlock  下载成功回调
 *  @param errorBlock    下载失败回调
 *  @param progressBlock 进度回调
 */
+ (void)downloadFile:(NSString *)fileName
              AtPath:(NSString *)filePath
             success:(SuccessBlock)successBlock
               error:(ErrorBlock)errorBlock
            progress:(ProgressBlock)progressBlock;

#pragma mark - upload
/**
 *  上传图片文件，提供图片文件data
 *
 *  @param imageData     文件Data
 *  @param params        其它参数
 *  @param successBlock  成功回调
 *  @param errorBlock    失败回调
 *  @param progressBlock 进度回调
 */
+ (void)uploadImageByData:(NSData *)imageData success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock;

/**
 *  批量上传文件，提供文件路径
 *
 *  @param fullPaths     文件全路径
 *  @param params        其它参数
 *  @param successBlock  成功回调
 *  @param errorBlock    失败回调
 *  @param progressBlock 进度回调
 */
+ (void)uploadByPaths:(NSArray *)fullPaths success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock;

/**
 *  获取文件下载的url
 *
 *  @param fileName 下载的文件名
 *
 *  @return 文件完整的url路径
 */
+ (NSString *)setupDownloadURL:(NSString *)fileName;

/**
 *  获取默认下载路径
 *
 *  @return tmp/download/
 */
+ (NSString *)defalutDownloadFilePath;

+ (MBProgressHUD *)sharedHud;
+ (UIWindow *)sharedWindow;
@end
