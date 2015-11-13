//
//  ShareAPIAction.m
//  ShareDemo
//
//  Created by yunlai on 13-7-11.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ShareAPIAction.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "SendMsgToWeChat.h"
#import "CallInfoApp.h"
#import "UIImageScale.h"
#import "WeiboViewController.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import "QQSendMessage.h"

#define WXDownAddress @"http://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"

@implementation ShareAPIAction

@synthesize delegate;
@synthesize shareDict;
@synthesize callApp;

// QQ分享
- (void)QQShareDict:(NSDictionary *)shareDic
{
    if (![QQApi isQQInstalled]) {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"使用QQ可以方便、免费的与好友分享图片、新闻"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"下载QQ",nil];
        alertView.tag = 1;
        [alertView show];
        [alertView release];
    } else {
        if (![QQApi isQQSupportApi]) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:@"您的QQ版本不支持分享，请下载最新的QQ版本"
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      otherButtonTitles:@"下载QQ",nil];
            alertView.tag = 2;
            [alertView show];
            [alertView release];
        } else {
            // 发送数据实例创建
            QQSendMessage *sendQQMsg = [[QQSendMessage alloc] init];
            // 得到标题
            NSString *title = [shareDic objectForKey:ShareTitle];
            // 得到所有内容
            NSString *content = [shareDic objectForKey:ShareContent];
            // 得到URL链接
            NSString *url = [shareDic objectForKey:ShareUrl];
            // 得到图片
            UIImage *image = [shareDic objectForKey:ShareImage];
            
            // 图片缩小到WX接受的范围内
            UIImage *imagesss = nil;
            if (url.length == 0) {
                if (image) {
                    imagesss = image;
                } else {
                    imagesss = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"icon" ofType:@"png"]];
                }
                // 只分享图片
                [sendQQMsg sendImageMessageForQQ:imagesss ThumbImage:[imagesss fillSize:CGSizeMake(57, 57)] title:title description:content];
            } else {
                if (image) {
                    imagesss = [image scaleToSize:CGSizeMake(57, 57)];
                } else {
                    imagesss = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"icon" ofType:@"png"]];
                }
                // 分享数据到微信好友
                [sendQQMsg sendUrlMessageForQQ:imagesss url:url title:title description:content];
            }
            [sendQQMsg release];
        }
    }
}

// 微信 分享
- (void)WXShareInt:(int)intWX dict:(NSDictionary *)shareDic
{
    // 是否安装微信
    if(![WXApi isWXAppInstalled]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"使用微信可以方便、免费的与好友分享图片、新闻"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"下载微信",nil];
        alertView.tag = 0;
        [alertView show];
        [alertView release];
    }else {
        // 发送数据实例创建
        SendMsgToWeChat *sendMsg = [[SendMsgToWeChat alloc] init];
        // 得到标题
        NSString *title = [shareDic objectForKey:ShareTitle];
        // 得到所有内容
        NSString *content = [shareDic objectForKey:ShareContent];
        // 得到URL链接
        NSString *url = [shareDic objectForKey:ShareUrl];
        // 得到图片
        UIImage *image = [shareDic objectForKey:ShareImage];

        // 图片缩小到WX接受的范围内
        UIImage *imagesss = nil;
        if (url.length == 0) {
            if (image) {
                imagesss = image;
            } else {
                imagesss = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"icon" ofType:@"png"]];
            }
            // 只分享图片
            [sendMsg sendImageContent:imagesss ThumbImage:[image fillSize:CGSizeMake(57, 57)] type:intWX];
        } else {
            if (image) {
                imagesss = [image scaleToSize:CGSizeMake(57, 57)];
            } else {
                imagesss = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"icon" ofType:@"png"]];
            }
            // 分享数据到微信好友
            [sendMsg sendNewsContent:title newsDescription:content newsImage:imagesss newUrl:url shareType:intWX];
        }
        [sendMsg release];
    }
}

// 微博 分享
- (void)weiboShareWeiboEnum:(WEIBOENUM)WeiboEnum dict:(NSDictionary *)shareDic
{
    UIImage *shareImage = [shareDict objectForKey:ShareImage];
    NSString *content = [shareDict objectForKey:ShareContent];
    
    weiboView = [[WeiboViewController alloc]init];
    weiboView.weiboText = content;
    weiboView.weiboImage = shareImage;
    weiboView.type = WeiboEnum;
    UINavigationController *navPushView = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navPushView pushViewController:weiboView animated:YES];
}

// 手机短信 分享
- (void)phoneShareDict:(NSDictionary *)shareDic
{
    NSString *content = [shareDict objectForKey:ShareContent];
    
    CallInfoApp *callAppc = [[CallInfoApp alloc]init];
    self.callApp = callAppc;
    [callAppc release];
    
    [self.callApp sendMessageTo:@"" withContent:content];
}

// 开始分享
- (void)startShare:(id <ShareAPIActionDelegate>)adelegate shareEnum:(SHAREENUM)share
{
    self.delegate = adelegate;
    
    if ([delegate respondsToSelector:@selector(shareApiActionReturnValue)]) {
        self.shareDict = [delegate shareApiActionReturnValue];
    }
    NSLog(@"self.shareDict = %@",self.shareDict);
    
    if (self.shareDict) {
        switch (share) {
            case ShareWXFriendCircle:   // 朋友圈
                [self WXShareInt:0 dict:self.shareDict];
                break;
            case ShareWXFriend:         // 朋友
                [self WXShareInt:1 dict:self.shareDict];
                break;
            case ShareSina:             // 新浪
                [self weiboShareWeiboEnum:WeiboEnumSina dict:shareDict];
                break;
            case ShareTencent:          // 腾讯
                [self weiboShareWeiboEnum:WeiboEnumTencent dict:shareDict];
                break;
            case SharePhone:            // 手机短信
                [self phoneShareDict:shareDict];
                break;
            case ShareQQ:               // QQ分享
                NSLog(@"ShareQQ");
                [self QQShareDict:self.shareDict];
                break;
                
            default:
                break;
        }
    }
    
    self.shareDict = nil;
    self.delegate = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            // 微信如果没有安装，从此处跳到安装目录
            NSURL *url = [NSURL URLWithString:WXDownAddress];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else if (alertView.tag == 1) {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            // QQ如果没有安装，从此处跳到安装目录
            NSURL *url = [NSURL URLWithString:[QQApi getQQInstallURL]];
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        if(buttonIndex != alertView.cancelButtonIndex)
        {
            // QQ API不支持，从此处跳到下载目录
            NSURL *url = [NSURL URLWithString:[QQApi getQQInstallURL]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)dealloc
{
    NSLog(@"dealloc = .......");
    self.shareDict = nil;
    self.callApp = nil;
    [weiboView release], weiboView = nil;
    
    [super dealloc];
}
@end
