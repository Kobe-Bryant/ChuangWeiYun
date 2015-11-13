//
//  HttpRequest.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "HttpRequest.h"
#import "CmdOperationParser.h"

// 数据返回时需要此锁
static NSRecursiveLock *dataLock = nil;

Class object_getClass(id object);

@implementation HttpRequest

@synthesize httpDelegate;
@synthesize param;

- (id)initWithURL:(NSURL *)newURL delegate:(id)adelegate
{
    if (self = [super initWithURL:newURL]) {
        self.httpDelegate = adelegate;
        if (dataLock == nil) {
            dataLock = [[NSRecursiveLock alloc]init];
        }
        requestClass = object_getClass(adelegate);
    }
    return self;
}

- (void)httpDelegateRequest:(NSString *)data type:(int)type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSMutableArray *resultArray = nil;
    int ver = 0;
    
    // 加锁
    [dataLock lock];
    
    if (data.length > 0 && ![data isEqual:[NSNull null]]) {
        //数据解析处理
        resultArray = [CmdOperationParser parser:type withJsonResult:data withVersion:&ver withParam:self.param];

        if (object_getClass(httpDelegate) == requestClass) {
            // 委托将数据返回到页面
            if ([httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:)]) {
                [httpDelegate didFinishCommand:resultArray cmd:type withVersion:ver];
            }
        }
    } else {
        if (object_getClass(httpDelegate) == requestClass) {
            resultArray = [NSMutableArray arrayWithObjects:CwRequestFail, nil];
            // 委托将数据返回到页面
            if ([httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:)]) {
                [httpDelegate didFinishCommand:resultArray cmd:type withVersion:ver];
            }
        }
    }

    // 解锁
    [dataLock unlock];
    
    [pool release];
}

- (void)dealloc
{
    self.httpDelegate = nil;
    self.param = nil;
    
    [super dealloc];
}
@end
