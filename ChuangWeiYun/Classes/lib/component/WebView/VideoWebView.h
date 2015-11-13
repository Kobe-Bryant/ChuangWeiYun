//
//  VideoWebView.h
//  cw
//
//  Created by yunlai on 13-12-7.
//
//

#import <UIKit/UIKit.h>

@interface VideoWebView : UIView <UIWebViewDelegate>
{
    UIWebView *_webView;
    UIActivityIndicatorView *indicatorView;
}

- (void)setWebViewUrl:(NSString *)urlstr;

@end
