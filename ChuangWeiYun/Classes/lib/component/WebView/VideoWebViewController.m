//
//  VideoWebViewController.m
//  cw
//
//  Created by yunlai on 13-12-5.
//
//

#import "VideoWebViewController.h"
#import "Common.h"

@interface VideoWebViewController () <UIWebViewDelegate, UIScrollViewDelegate>
{
    UIWebView *_webView;
    
    UIActivityIndicatorView *indicatorView;
}

@end

@implementation VideoWebViewController

@synthesize webType;
@synthesize urlStr;
@synthesize webSize;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width;
    CGFloat height = [UIScreen mainScreen].applicationFrame.size.height - 44.f;
    CGFloat indicatorWidth = 50.f;
    
    _webView = [[UIWebView alloc]init];
    if (self.webType == WebViewNetVideo) {
        if (self.webSize.height == 0.000000 || self.webSize.width == 0.000000) {
            _webView.frame = CGRectMake(0.f, 0.f, width, height);
        } else {
            self.webSize = [UIImage fitsize:self.webSize size:CGSizeMake(width, height)];
        }
//        CGFloat x = (width - self.webSize.width) / 2;
//        CGFloat y = (height - self.webSize.height + 60.f) / 2;
//        _webView.frame = CGRectMake(x, y, self.webSize.width, self.webSize.height - 60.f);
        CGFloat y = (height - 250.f) / 2;
        _webView.frame = CGRectMake(0.f, y, 320.f, 250.f);
    } else if (self.webType == WebViewLocVideo) {
        _webView.frame = CGRectMake(0.f, 0.f, width, height);
    }
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    scrollView.bounces = NO;
    
    indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.frame = CGRectMake(width/2 - indicatorWidth/2, height/2 - indicatorWidth/2, indicatorWidth, indicatorWidth);
    indicatorView.hidesWhenStopped = YES;
    [_webView addSubview:indicatorView];

    if (self.urlStr.length > 0) {
        [indicatorView startAnimating];
        NSURL *url = [NSURL URLWithString:self.urlStr];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_webView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_webView release], _webView = nil;
    [indicatorView release], indicatorView = nil;
    
    self.urlStr = nil;
    
    [super dealloc];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"navigationType = %d",navigationType);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

//- (void)ddddddd
//{
//    //_webView.scrollView.contentSize
//    NSLog(@"height: %@", [_webView stringByEvaluatingJavaScriptFromString: @"document.location.href"]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString * requestDurationString = @"document.documentElement.getElementsByTagName(\"video\")[0].duration.toFixed(1)";
//        NSString * result = [_webView stringByEvaluatingJavaScriptFromString:requestDurationString];
//        NSLog(@"+++ Web Video Duration:%@",result);
//    });
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicatorView stopAnimating];
//    NSString *lHtml1 = [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"body\").iframe(0)"];
//    NSString *lHtml2 = [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('main').style.height='%fpx';",210.f]];
//    NSLog(@"lHtml1 = %@",lHtml1);
//    NSLog(@"lHtml2 = %@",lHtml2);
//    NSString *height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
//    int height = [height_str intValue];
//    webView.frame = CGRectMake(0,0,320,height);
//    NSLog(@"height: %@", [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"]);
    
//    [self performSelector:@selector(ddddddd) withObject:nil afterDelay:0.3];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}



@end
