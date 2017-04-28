//
//  VICBaseService.m
//  BaoYangHuiTechnician
//
//  Created by 攸广欣 on 14-11-3.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

#import "VICBaseService.h"
#import "VICURLFactory.h"
#import "VICServiceUtils.h"
#import <CommonCrypto/CommonDigest.h>

#define AppKey      @"sjappkey"
#define AppSecret   @"123321"

@interface VICBaseService ()

@end

@implementation VICBaseService


#pragma mark - Rest API
+ (void)restApi:(NSString *)api parameters:(NSDictionary *)dict success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock
{
    [VICBaseService restApi:api parameters:dict success:successBlock error:errorBlock showHud:YES];
}

+ (void)restApiWithOutHud:(NSString *)api parameters:(NSDictionary *)dict success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock
{
    [VICBaseService restApi:api parameters:dict success:successBlock error:errorBlock showHud:NO];
}

+ (void)restApi:(NSString *)api parameters:(NSDictionary *)dict success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock showHud:(BOOL)showHud
{
    // 构建请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:dict];
    [params setValue:AppKey forKey:@"key"];
    // 将参数转换成有序字符串并加密
    // operate不参与排序和加密，只是为了兼容以前的接口，用户指定请求类型
    NSString *operate = [params valueForKey:@"operate"];
    [params removeObjectForKey:@"operate"];
    // code不参与排序和加密
    // 修改后code数值参与接口，不需要remove
    NSString *code = [params valueForKey:@"code"];
    /*
    if (code) {
        [params removeObjectForKey:@"code"];
    }
     */
    NSString *sign = [VICServiceUtils stringFromDict:params withMD5:YES];
    if (code) {
        [params setValue:code forKey:@"code"];
    }
    [params setValue:operate forKey:@"operate"];
    [params setValue:sign forKey:@"sign"];
    
    [VICBaseService restApi:api params:params success:successBlock error:errorBlock showHud:showHud];
}

+ (void)restApi:(NSString *)api params:(NSDictionary *)params success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock showHud:(BOOL)showHud
{
    NSAssert(api, @"\u274C api为空");
    if ([api hasSuffix:@"/"]) {
        api = [api substringToIndex:(api.length - 1)];
    }

    UIWindow *window;
    MBProgressHUD *hud;

    // 加载数据
    if (showHud) {
        window = [VICBaseService sharedWindow];
        hud = [VICBaseService sharedHud];
        hud.alpha = 1.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!hud.superview) {
                [window addSubview:hud];
            }
            hud.label.text = @"";
            hud.detailsLabel.text = @"";
            hud.mode = MBProgressHUDModeIndeterminate;
        });
        
    }

    VICHTTPSessionManager *manager = [[VICHTTPSessionManager alloc] initWithBaseURL:[[VICURLFactory shardFactoryHandle] relativeBaseURL]];
    [manager restApi:api parameters:params success:^(NSDictionary *responseDic) {
        NSInteger code = [[responseDic valueForKey:@"returnCode"] integerValue];
        if (code == 0) {    // 成功
            if (showHud) {
                [hud hideAnimated:YES];
            }
            
            if (successBlock) {
                successBlock(responseDic);
            }
            
        }else{        // 失败
            NSLog(@"返回错误信息：\n%@",responseDic);
            if (showHud) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.label.text = @"";
                    hud.mode = MBProgressHUDModeText;
                    hud.detailsLabel.text = [NSString stringWithFormat:@"%@",[responseDic valueForKey:@"result"]];
                    [hud hideAnimated:YES afterDelay:1.0];
                    
                });
            }
            
            if (errorBlock) {
                NSError *error = [NSError errorWithDomain:[[[VICURLFactory shardFactoryHandle] relativeBaseURL] absoluteString] code:code userInfo:@{NSLocalizedDescriptionKey:[responseDic valueForKey:@"result"]}];
                errorBlock(error);
            }
        }
    } error:^(NSError *error) {
        NSLog(@"error %@",[error localizedDescription]);
        if (showHud) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
                if (errorMsg && ![errorMsg isEqualToString:@""]) {
                    errorMsg = [errorMsg stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",./<>?`~!@#$%^&*()_+／。，｀！@＃¥％……&＊（）——＋《》？"]];
                }else{
                    errorMsg = [NSString stringWithFormat:@"系统异常：code：%ld",(long)error.code];
                }

                hud.label.text = @"";
                hud.detailsLabel.text = [NSString stringWithFormat:@"%@",errorMsg];
                hud.mode = MBProgressHUDModeText;
                [hud hideAnimated:YES afterDelay:1.0];
                
            });
        }

        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

#pragma mark - download

+ (void)downloadFile:(NSString *)fileName success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    [VICBaseService downloadFile:fileName
                          AtPath:[VICBaseService defalutDownloadFilePath]
                         success:successBlock
                           error:errorBlock
                        progress:progressBlock];
}

+ (void)downloadFileWithDictionary:(NSDictionary *)dict success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    NSString *fileName = dict[@"file_name"];
    NSString *filePath = dict[@"file_path"];

    [VICBaseService downloadFile:fileName
                          AtPath:filePath
                         success:successBlock
                           error:errorBlock
                        progress:progressBlock];
}

+ (void)downloadFile:(NSString *)fileName AtPath:(NSString *)filePath success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    // 验证传入文件名，文件路径
    NSAssert(fileName, @"\u274C 传入文件名为空");
    NSAssert(filePath, @"\u274C 传入文件路径为空");

    // 拼URL
    NSString *url = [VICBaseService setupDownloadURL:fileName];

    // 文件完整路径
    NSString *fullPath = [filePath stringByAppendingPathComponent:fileName];

    VICHTTPSessionManager *manager = [[VICHTTPSessionManager alloc] initWithBaseURL:[[VICURLFactory shardFactoryHandle] relativeBaseURL]];
    [manager downloadFileWithURL:url AtPath:fullPath success:successBlock error:errorBlock progress:progressBlock];
}

#pragma mark - upload
+ (void)uploadImageByData:(NSData *)imageData success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    NSAssert(imageData.length > 0, @"\u274C 传入Data为空");
    
    NSString *url = [self setupUploadURL];
    
    VICHTTPSessionManager *manager = [[VICHTTPSessionManager alloc] initWithBaseURL:[[VICURLFactory shardFactoryHandle]  uploadRelativeBaseURL]];
    [manager.requestSerializer setValue:@"Basic d2luZToxMjM0NTY=" forHTTPHeaderField:@"Authorization"];
    [manager uploadImageData:imageData
               withURLString:url
              parameters:nil
                 success:^(NSDictionary *responseDic) {
                     if (successBlock) {
                         successBlock(responseDic);
                     }
                 }
                   error:^(NSError *error) {
                       if (errorBlock) {
                           errorBlock(error);
                       }
                   }
                progress:^(CGFloat progress) {
                    if (progressBlock) {
                        progressBlock(progress);
                    }
                }];
}

+ (void)uploadByPaths:(NSArray *)fullPaths success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    NSAssert(fullPaths.count > 0, @"\u274C 传入文件路径为空");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in fullPaths) {
        BOOL isExist = [fileManager fileExistsAtPath:filePath];
        NSString *errorInfo = [NSString stringWithFormat:@"\u274C 文件路径不存在：%@",filePath];
        NSAssert(isExist, errorInfo);
    }

    NSString *url = [self setupUploadURL];

    VICHTTPSessionManager *manager = [[VICHTTPSessionManager alloc] initWithBaseURL:[[VICURLFactory shardFactoryHandle] uploadRelativeBaseURL]];
    [manager.requestSerializer setValue:@"Basic d2luZToxMjM0NTY=" forHTTPHeaderField:@"Authorization"];
    [manager uploadFiles:fullPaths
           withURLString:url
              parameters:nil
                 success:^(NSDictionary *responseDic) {
                     if (successBlock) {
                         successBlock(responseDic);
                     }
              }
                   error:^(NSError *error) {
                       if (errorBlock) {
                           errorBlock(error);
                       }
              }
                progress:^(CGFloat progress) {
                    if (progressBlock) {
                        progressBlock(progress);
                    }
              }];
}

#pragma mark - Utils

+ (NSString *)defalutDownloadFilePath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"download/"];
}

+ (NSString *)defalutUploadFilePath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload/"];
}

+ (NSString *)setupDownloadURL:(NSString *)fileName
{
    if (!fileName) {
        return nil;
    }
    // 拼下载URL
    NSString *url = @"";
    url = [url stringByAppendingString:[[[VICURLFactory shardFactoryHandle] relativeBaseURL] absoluteString]];
    url = [url stringByAppendingPathComponent:@"api/files"];
    url = [url stringByAppendingString:@"?lang=zh&operate=GET&request_content=download&"];
    url = [url stringByAppendingFormat:@"file_name=%@",fileName];

    return url;
}

+ (NSString *)setupUploadURL
{
    // 拼上传URL
    NSString *url = @"";
    url = [url stringByAppendingString:[[[VICURLFactory shardFactoryHandle]  uploadRelativeBaseURL] absoluteString]];
    url = [url stringByAppendingPathComponent:@"ueditor/imageUpload.do"];
    return url;
}

#pragma mark - shared instance
+ (MBProgressHUD *)sharedHud
{
    static MBProgressHUD *hud = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[MBProgressHUD alloc] initWithFrame:[VICBaseService sharedWindow].bounds];
        hud.label.text = nil;
        hud.detailsLabel.text = nil;
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
    });
    
    return hud;
}

+ (UIWindow *)sharedWindow
{
    static UIWindow *window = nil;
    if (!window) {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    return window;
}
@end
