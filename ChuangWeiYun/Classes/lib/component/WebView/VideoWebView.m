//
//  VideoWebView.m
//  cw
//
//  Created by yunlai on 13-12-7.
//
//

#import "VideoWebView.h"

@implementation VideoWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webView = [[UIWebView alloc]initWithFrame:self.bounds];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self addSubview:_webView];
        
        UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
        scrollView.bounces = NO;
        
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        CGFloat indicatorWidth = 50.f;
        
        indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.frame = CGRectMake(width/2 - indicatorWidth/2, height/2 - indicatorWidth/2, indicatorWidth, indicatorWidth);
        indicatorView.hidesWhenStopped = YES;
        [self addSubview:indicatorView];
        [indicatorView startAnimating];
    }
    return self;
}

- (void)dealloc
{
    [_webView release], _webView = nil;
    [indicatorView release], indicatorView = nil;
    [super dealloc];
}

- (void)setWebViewUrl:(NSString *)urlstr
{
    NSURL *url = [NSURL URLWithString:urlstr];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"request = %@",request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad webView = %@",webView);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad webView = %@",webView);

//    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=0.1"];
    NSString *meta = @"document.getElementsByName(\"viewport\")[0].content = \"minimum-scale=0.5, maximum-scale=1.0, initial-scale=1.0, width=90.0, user-scalable=yes\"";
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
    [indicatorView stopAnimating];

    UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    scrollView.bounces = NO;
    
    CGFloat height = scrollView.contentSize.height / 2;
    
    CGFloat X = 0.f;
    CGFloat Y = 0.f;

    if (scrollView.frame.size.height < height) {
        Y = height - scrollView.frame.size.height + 70.f / 2;
    }
    
    scrollView.contentOffset = CGPointMake(X, Y);
    scrollView.scrollEnabled = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError webView = %@",webView);
    [indicatorView stopAnimating];
}

@end
