//
//  QQSendMessage.h
//  cw
//
//  Created by yunlai on 13-8-22.
//
//

#import <Foundation/Foundation.h>

#import <TencentOpenAPI/QQApiInterface.h>

@interface QQSendMessage : NSObject

/*
 *   分享文本
 *   text 文本内容，必填，最长1536个字符
 */       
- (QQApiSendResultCode)sendTextMessageForQQ:(NSString *)text;

/*
 *   分享图片  
 *   最大5M字节
 *   image ThumbImage 预览图像，最大1M字节
 *   title 标题，最长128个字符
 *   description 简要描述，最长512个字符
 */
- (QQApiSendResultCode)sendImageMessageForQQ:(UIImage *)image ThumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description;

/*
 *   分享带链接的数据
 *   urlstr URL地址,必填，最长512个字符
 *   image 预览图像数据，最大1M字节
 *   title 标题，最长128个字符
 *   description 简要描述，最长512个字符
 */
- (QQApiSendResultCode)sendUrlMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description;

/*
 *   分享音频
 *   urlstr URL地址,必填，最长512个字符
 *   image 预览图像数据，最大1M字节
 *   title 标题，最长128个字符
 *   description 简要描述，最长512个字符
 */
- (QQApiSendResultCode)sendAudioMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description;

/*
 *   分享视频
 *   urlstr URL地址,必填，最长512个字符
 *   image 预览图像数据，最大1M字节
 *   title 标题，最长128个字符
 *   description 简要描述，最长512个字符
 */
- (QQApiSendResultCode)sendVideoMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description;

@end
