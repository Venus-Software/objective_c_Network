//
//  VICHTTPSessionManager.m
//  BaoYangHuiTechnician
//
//  Created by ygx on 14-11-4.
//  Copyright (c) 2014年 VIC. All rights reserved.
//

#import "VICHTTPSessionManager.h"
#import "VICURLFactory.h"

#define ResponseSuccess [[responseDict valueForKey:@"code"] integerValue] == 0

@implementation VICHTTPSessionManager
- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
//        // 服务器的ContentTypes是text/html，添加到self.acceptableContentTypes中
//        NSMutableSet *contentTypes = [self.responseSerializer.acceptableContentTypes mutableCopy];
//        [contentTypes addObject:@"text/html"];
//        self.responseSerializer.acceptableContentTypes = contentTypes;
    }

    return self;
}

#pragma mark - Rest Api

- (NSURLSessionDataTask *)restApi:(NSString *)apiPath
                       parameters:(NSDictionary *)parameters
                          success:(void (^)(NSURLSessionDataTask *task, id responseObj))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSAssert(apiPath, @"\u274C api为空");
    NSAssert(parameters[@"operate"], @"\u274C operate为空");
    
    // 判断HTTP请求方式
    VICRequestMethod requestMethod;
    NSString *method = parameters[@"operate"];
    if ([method isEqualToString:@"GET"]) {
        requestMethod = VICRequestMethodGet;
    } else if ([method isEqualToString:@"POST"]) {
        requestMethod = VICRequestMethodPost;
    } else if ([method isEqualToString:@"PUT"]) {
        requestMethod = VICRequestMethodPut;
    } else if ([method isEqualToString:@"HEAD"]) {
        requestMethod = VICRequestMethodHead;
    } else if ([method isEqualToString:@"DELETE"]) {
        requestMethod = VICRequestMethodDelete;
    } else {
        requestMethod = VICRequestMethodError;
    }

    //请求方式必须为下面几种之一
    NSAssert((requestMethod != VICRequestMethodError), @"\u274C HTTP请求方式必须为GET、POST、PUT、HEAD、DELETE其中一种");
    
    //确定了请求方式之后，移除不在有用的operate参数
    NSMutableDictionary *paramsTemp = [parameters mutableCopy];
    [paramsTemp removeObjectForKey:@"operate"];
    
    NSURLSessionDataTask *task;

    NSString *url = [[[NSURL alloc] initWithString:apiPath relativeToURL:self.baseURL] absoluteString];
    switch (requestMethod) {
        case VICRequestMethodGet:
        {
            task = [self GET:url parameters:paramsTemp success:success failure:failure];
            break;
        }
        case VICRequestMethodPost:
        {
            task = [self POST:url parameters:paramsTemp success:success failure:failure];
            break;
        }
        case VICRequestMethodHead:
        {
            // TODO: HEAD method may be not work
            void (^temp)();
            void (^headSuccess)(NSURLSessionDataTask *task);
            temp = success;
            headSuccess = temp;
            task = [self HEAD:url parameters:paramsTemp success:headSuccess failure:failure];
            break;
        }
        case VICRequestMethodPut:
        {
            task = [self PUT:url parameters:paramsTemp success:success failure:failure];
            break;
        }
        case VICRequestMethodDelete:
        {
            task = [self DELETE:url parameters:paramsTemp success:success failure:failure];
            break;
        }
        case VICRequestMethodError:
        default:
            NSLog(@"God help me.");
            break;
    }

    return task;
}

- (void)restApi:(NSString *)apiPath parameters:(NSDictionary *)parameters success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock
{
    // success transe to successBlock
    void (^success)(NSURLSessionDataTask *task, id responseObj) = ^(NSURLSessionDataTask *task, id responseObj) {
        if (responseObj) {
            responseObj = [NSJSONSerialization JSONObjectWithData:responseObj options:NSJSONReadingAllowFragments error:nil];
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                if (successBlock) { // 只要有返回结果，就传给上层根据code处理
                    successBlock(responseObj);
                }
            } else {
                NSLog(@"返回信息不是字典格式.");
            }
        } else {
            NSLog(@"返回信息为空!");
        }

    };

    void (^failure)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
        NSLog(@"请求失败：error = %@",error);
    };

    [self restApi:apiPath parameters:parameters success:success failure:failure];
}

#pragma mark - download

- (void)downloadFileWithURL:(NSString *)url AtPath:(NSString *)fullPath success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock
{
    NSAssert(url, @"\u274C url为空");
    NSAssert(fullPath, @"\u274C path为空");

    // 创建下载路径
    NSString *upperPath = [fullPath stringByDeletingLastPathComponent];
    NSLog(@"%@",fullPath);
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:upperPath isDirectory:&isDirectory]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:upperPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"\u274C 创建下载路径失败! Error %@",error);
        }else{
            if (error) {
                if (errorBlock) {   errorBlock(error);  }
            }
            return;
        }
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
         return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            if (errorBlock) {   errorBlock(error);  }
        } else {
            if (successBlock)   {   successBlock(nil);  }
        }
    }];
    
    [self setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"task %@",downloadTask);
        if (progressBlock) {
            progressBlock((CGFloat)totalBytesWritten / totalBytesExpectedToWrite);
        }
    }];

    [downloadTask resume];
    
    // TODO: 现在无法获取每个downloadTask的progress，UIProgressView+AFNetworking中提供了一种解决方法，不过太麻烦
    // 还有另外一种方法获取downloadTask的progress，监听NSProgress的fractionCompleted属性
    // http://stackoverflow.com/questions/19145093/how-to-get-download-progress-in-afnetworking-2-0
}

#pragma mark - upload
- (void)uploadImageData:(NSData *)data withURLString:(NSString *)URLString parameters:(NSDictionary *)params success:(SuccessBlock)successBlock error:(ErrorBlock)errorBlock progress:(ProgressBlock)progressBlock{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"files" fileName:@"image.png" mimeType:@"image/jpeg"];
    } error:nil];
    
    // TODO: progressBlock
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [self uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (errorBlock) {   errorBlock(error);  }
        } else {
            // TODO: responseObject
            if (![responseObject isKindOfClass:[NSDictionary class]]) {
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
            if (successBlock)   {   successBlock(responseObject);  }
        }
    }];
    
    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if (progressBlock) {
            progressBlock(1.0*totalBytesSent/totalBytesExpectedToSend);
        }
    }];
    
    [uploadTask resume];
}

- (void)uploadFiles:(NSArray *)filePaths
      withURLString:(NSString *)URLString
         parameters:(NSDictionary *)params
            success:(SuccessBlock)successBlock
              error:(ErrorBlock)errorBlock
           progress:(ProgressBlock)progressBlock{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // filename必须有后缀
        for (NSString *filePath in filePaths) {
            NSInteger location = [filePath rangeOfString:@"/" options:NSBackwardsSearch].location;
            
            [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath] name:@"files" fileName:[filePath substringFromIndex:location+1] mimeType:@"image/jpeg"];
        }
    } error:nil];
    
    // TODO: progressBlock
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [self uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (errorBlock) {   errorBlock(error);  }
        } else {
            // TODO: responseObject
            if (![responseObject isKindOfClass:[NSDictionary class]]) {
                responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
            if (successBlock)   {   successBlock(responseObject);  }
        }
    }];
    
    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if (progressBlock) {
            progressBlock(1.0*totalBytesSent/totalBytesExpectedToSend);
        }
    }];
    
    [uploadTask resume];
}
@end
