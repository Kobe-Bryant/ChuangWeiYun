//
//  DataManager.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CmdOperation;

@interface NetManager : NSObject
{
    CmdOperation *commandOperation;
}

// 单例模式创建实例
+ (NetManager *)sharedManager;

/*  执行请求
 *  reqdic      请求的字典数据
 *  data        图片数据，如果为nil，则执行get请求，不为空，执行post请求
 *  commandID   根据此ID，判断请求数据
 *  accAddr     请求的地址
 *  theDelegate 委托
 *  param
 */
- (void)accessService:(NSMutableDictionary*)reqdic
                 data:(NSData *)data
              command:(int)commandID
         accessAdress:(NSString*)accAddr
             delegate:(id)theDelegate
            withParam:(NSMutableDictionary*)param;

@end
