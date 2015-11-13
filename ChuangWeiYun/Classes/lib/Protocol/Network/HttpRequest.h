//
//  HttpRequest.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "ASIFormDataRequest.h"

#define CwRequestFail @"cwRequestFail"
#define CwRequestTimeout @"cwRequestTimeout"
#define CwRequestTip @"服务器繁忙，请稍后重试"

@protocol HttpRequestDelegate <NSObject>

@required
/*
 此方法是数据接收完成后，将数据传回页面，
 参数一：参数类型为id类型，有可能是字典或者数组
 参数二：是一个commadid，代表请求类型
 参数三：版本号
 */
- (void)didFinishCommand:(NSMutableArray *)resultArray cmd:(int)commandid withVersion:(int)ver;

@end

@interface HttpRequest : ASIFormDataRequest
{
    id <HttpRequestDelegate> httpDelegate;
    NSMutableDictionary *param;
    Class requestClass;
}

@property (assign, nonatomic) id <HttpRequestDelegate> httpDelegate;
@property (retain, nonatomic) NSMutableDictionary *param;

- (id)initWithURL:(NSURL *)newURL delegate:(id)adelegate;

- (void)httpDelegateRequest:(NSString *)data type:(int)type;

@end
