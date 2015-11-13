//
//  VideoWebViewController.h
//  cw
//
//  Created by yunlai on 13-12-5.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    WebViewNetVideo,
    WebViewLocVideo,
    WebViewV
}WebViewEnum;

@interface VideoWebViewController : UIViewController

// 类型
@property (assign, nonatomic) WebViewEnum webType;
// websize的高度和宽度，网络视频需要传送
@property (assign, nonatomic) CGSize webSize;
// 链接
@property (retain, nonatomic) NSString *urlStr;

@end
