 //
//  QQSendMessage.m
//  cw
//
//  Created by yunlai on 13-8-22.
//
//

#import "QQSendMessage.h"

@implementation QQSendMessage

// 分享文本
- (QQApiSendResultCode)sendTextMessageForQQ:(NSString *)text
{
    QQApiTextObject *txt = [QQApiTextObject objectWithText:text];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txt];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    return sent;
}
 
// 分享图片
- (QQApiSendResultCode)sendImageMessageForQQ:(UIImage *)image ThumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSData *thumbdata = UIImageJPEGRepresentation(thumbImage, 1.0);
	
    QQApiImageObject *img = [QQApiImageObject objectWithData:data previewImageData:thumbdata title:title description:description];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    return sent;
}

// 分享带链接的数据
- (QQApiSendResultCode)sendUrlMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
	NSURL *url = [NSURL URLWithString:urlstr];
	
    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:title description:description previewImageData:data];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    NSLog(@"....... sent = %d",sent);
    
    return sent;
}

// 分享音频 
- (QQApiSendResultCode)sendAudioMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
	NSURL *url = [NSURL URLWithString:urlstr];
    
    QQApiAudioObject *img = [QQApiAudioObject objectWithURL:url title:title description:description previewImageData:data];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    return sent;
}

// 分享视频 
- (QQApiSendResultCode)sendVideoMessageForQQ:(UIImage *)image url:(NSString *)urlstr title:(NSString *)title description:(NSString *)description
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
	NSURL *url = [NSURL URLWithString:urlstr];
	
    QQApiVideoObject* img = [QQApiVideoObject objectWithURL:url title:title description:description previewImageData:data];
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    
    return sent;
}

@end
