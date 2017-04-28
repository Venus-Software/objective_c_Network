//
//  VICURLFactory.m
//  CommonAPI
//
//  Created by qianyb on 15/4/10.
//  Copyright (c) 2015年 qianyb. All rights reserved.
//

#import "VICURLFactory.h"
#import <objc/runtime.h>

static NSString *baseURLKey = @"baseURLKey";
static NSString *uploadBaseURLKey = @"uploadBaseURLKey";

@implementation VICURLFactory
static VICURLFactory *factoryHandle = nil;

+ (VICURLFactory *)shardFactoryHandle{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (factoryHandle == nil) {
            factoryHandle = [[self alloc] init];
        }
    });
    return factoryHandle;
    
}




- (NSURL *)uploadRelativeBaseURL{
    return [NSURL URLWithString:self.uploadBaseURL];
}
//内网测试
- (NSURL *)relativeBaseURL{
    
    return [NSURL URLWithString:self.baseURL];
}

- (void)setBaseURL:(NSString *)baseURL{
    objc_setAssociatedObject(self, &baseURLKey, baseURL,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.baseURL) {
        [[VICURLFactory shardFactoryHandle] relativeBaseURL];
    }
}

- (NSString *)baseURL{
    return objc_getAssociatedObject(self, &baseURLKey);
}

- (void)setUploadBaseURL:(NSString *)uploadBaseURL{
    objc_setAssociatedObject(self, &uploadBaseURLKey, uploadBaseURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.relativeBaseURL) {
        [[VICURLFactory shardFactoryHandle] uploadRelativeBaseURL];
    }
}

- (NSString *)uploadBaseURL{
    return objc_getAssociatedObject(self, &uploadBaseURLKey);
}

@end
