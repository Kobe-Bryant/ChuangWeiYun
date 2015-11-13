//
//  CommandOperation.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RequestTypeKey           @"commonid"

@class ASINetworkQueue;

@interface CmdOperation : NSObject
{
    ASINetworkQueue *queue;
}

@property (retain, nonatomic) ASINetworkQueue *queue;

- (BOOL)isRunning;
// 开始
- (void)start;
// 暂停
- (void)pause;
// 取消暂停
- (void)resume;
// 取消队列
- (void)cancel;

// 将http请求添加到队列
- (void)addOperationHTTPRequest:(NSURL *)url type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

// 将POST请求添加到队列
- (void)addOperationPostRequest:(NSURL *)url data:(NSData *)imageData type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

@end
