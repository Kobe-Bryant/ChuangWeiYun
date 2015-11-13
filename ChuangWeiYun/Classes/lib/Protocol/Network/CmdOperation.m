//
//  CommandOperation.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "CmdOperation.h"
#import "HttpRequest.h"
#import "ASINetworkQueue.h"
#import "Global.h"

@implementation CmdOperation

@synthesize queue;

// 初始化 ASINetworkQueue
- (id)init
{
    if (self = [super init]) {
        queue = [[ASINetworkQueue alloc]init];
        [queue setDelegate:self];
        [queue setRequestDidFailSelector:@selector(requestDidFail:)];
        [queue setRequestDidFinishSelector:@selector(requestDidFinish:)];
        [queue setShouldCancelAllRequestsOnFailure:NO];
        [queue setShowAccurateProgress:YES];
    }
    return self;
}

- (BOOL)isRunning
{
    return ![queue isSuspended];
}

// 开始
- (void)start
{
    if ([queue isSuspended]) {
        [queue go];
    }
}

// 暂停
- (void)pause
{
    [queue setSuspended:YES];
}

// 取消暂停
- (void)resume
{
    [queue setSuspended:NO];
}

// 取消队列
- (void)cancel
{
    [queue cancelAllOperations];
}

// 将http请求添加到队列
- (void)addOperationHTTPRequest:(NSURL *)url type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param
{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    [request setParam:param];
    [queue addOperation:request];
    [request release];
}

// 将POST请求添加到队列
- (void)addOperationPostRequest:(NSURL *)url data:(NSData *)imageData type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param
{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    [request setParam:param];
    [request addData:imageData withFileName:@"xx.jpg" andContentType:@"image/jpeg" forKey:@"photos"];
    [queue addOperation:request];
    [request release];
}

// 设置ASIHTTPRequest userInfo
- (void)setUserInfo:(HttpRequest *)request type:(int)commonID url:(NSString *)str
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:commonID], RequestTypeKey,
                          str, @"url", nil];
    [request setUserInfo:dict];
}

// 联网失败后  信息反馈
- (void)requestDidFail:(HttpRequest *)request
{
    [[Global sharedGlobal].netWorkQueueArray removeObject:[[request userInfo] objectForKey:@"url"]];

    NSLog(@"requestDidFail:%@,%@,",request.responseString,[request.error localizedDescription]);
    
    int commonid = [[[request userInfo] objectForKey:RequestTypeKey] intValue];
    NSLog(@"requestDidFail commonid = %d",commonid);
    
    [request httpDelegateRequest:nil type:commonid];
}

// 联网成功后  返回数据
- (void)requestDidFinish:(HttpRequest *)request
{
    [[Global sharedGlobal].netWorkQueueArray removeObject:[[request userInfo] objectForKey:@"url"]];

    // 得到请求的commonid
    int commonid = [[[request userInfo] objectForKey:RequestTypeKey] intValue];
    NSLog(@"requestDidFinish commonid = %d",commonid);
    
    // 得到请求的数据
    NSString *resultStr = [request responseString];
    NSLog(@"requestDidFinish resultStr = %@",resultStr);
    
    [request httpDelegateRequest:resultStr type:commonid];
}

@end
