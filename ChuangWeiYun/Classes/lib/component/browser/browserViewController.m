//
//  browserViewController.m
//  yunPai
//
//  Created by LuoHui on 13-7-16.
//
//

#import "browserViewController.h"
#import "Common.h"
#import "PopShareView.h"
#import "FileManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageScale.h"
#import "cloudLoadingView.h"
#import "NetworkFail.h"

#define IMAGE_WIDTH  294
#define IMAGE_HEIGHT 294

@interface browserViewController () <NetworkFailDelegate>
{
    NetworkFail *failView;
}

@end

@implementation browserViewController
@synthesize webView;
@synthesize url;
@synthesize webTitle;
@synthesize shareImage;
@synthesize cloudLoading;
@synthesize isHideToolBar = _isHideToolBar;
@synthesize isFromList = _isFromList;
@synthesize listInfoId;
@synthesize delegate;
@synthesize isFromAbout = _isFromAbout;
@synthesize isFromService;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.webTitle;
    
    UIImage *btnImgNormal = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_yunplus_s" ofType:@"png"]];
    
    if (_isFromList == YES) {
        UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
        vi.backgroundColor = [UIColor clearColor];
        vi.userInteractionEnabled = YES;
        
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0.0f, 44/2 - btnImgNormal.size.height/2, btnImgNormal.size.width, btnImgNormal.size.height);
        [addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage:btnImgNormal forState:UIControlStateNormal];
        [vi addSubview:addButton];
        addButton.enabled = NO;
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:vi];
        self.navigationItem.rightBarButtonItem = barButton;
        [barButton release];
        [vi release];
    }
    
	CGFloat fixHeight = self.view.frame.size.height - 44.0f;
	
	UIWebView *tempWebView = [[UIWebView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, fixHeight)];
	self.webView = tempWebView;
	webView.delegate = self;
	webView.scalesPageToFit = YES;
    webView.scrollView.delegate = self;
	[self.view addSubview:webView];
	[tempWebView release];
	if ([self.url length] > 1)
	{
		//开始请求连接
		NSURL *webUrl =[NSURL URLWithString:self.url];
		NSURLRequest *request =[NSURLRequest requestWithURL:webUrl];
		[webView loadRequest:request];
	}
    
    if (!_isHideToolBar)
    {
        [self showToolBar];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar_bright.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar_dark.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//工具栏
-(void)showToolBar
{
    toolBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44 - 44, 320, 44)];
	UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg_browserbar_bright" ofType:@"png"]];
	toolBarView.image = image;
	toolBarView.userInteractionEnabled = YES;
	//[image release];
	[self.view addSubview:toolBarView];
    
    //添加按钮
    int fixWidth = (320 - 44 * 4) / 7;
    
    lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lastBtn.frame = CGRectMake(fixWidth - 10, 0, 44, 44);
    [lastBtn addTarget:self action:@selector(lastAction) forControlEvents:UIControlEventTouchUpInside];
    [lastBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_disabled" ofType:@"png"]] forState:UIControlStateNormal];
//    [lastBtn setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_normal" ofType:@"png"]] forState:UIControlStateNormal];
//    [lastBtn setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_clicked" ofType:@"png"]] forState:UIControlStateHighlighted];
    [toolBarView addSubview:lastBtn];
    
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(CGRectGetMaxX(lastBtn.frame) + fixWidth * 2, 0, 44, 44);
    [nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_disabled" ofType:@"png"]] forState:UIControlStateNormal];
//    [nextBtn setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_normal" ofType:@"png"]] forState:UIControlStateNormal];
//    [nextBtn setImage:[[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_clicked" ofType:@"png"]] forState:UIControlStateHighlighted];
    [toolBarView addSubview:nextBtn];
    
    shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.enabled = NO;
    shareBtn.frame = CGRectMake(CGRectGetMaxX(nextBtn.frame) + fixWidth * 2, 0, 44, 44);
    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_share_normal" ofType:@"png"]] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_share_pressed" ofType:@"png"]] forState:UIControlStateHighlighted];
    [toolBarView addSubview:shareBtn];
    
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(CGRectGetMaxX(shareBtn.frame) + fixWidth * 2, 0, 44, 44);
    [refreshBtn addTarget:self action:@selector(reloadAction) forControlEvents:UIControlEventTouchUpInside];
    [refreshBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_refresh_normal" ofType:@"png"]] forState:UIControlStateNormal];
    [refreshBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_refresh_pressed" ofType:@"png"]] forState:UIControlStateHighlighted];
    [toolBarView addSubview:refreshBtn];
}

- (void)viewDidUnload {
    [super viewDidUnload];
 
    self.webView = nil;
	self.url = nil;
    self.webTitle = nil;
    self.shareImage = nil;
	self.cloudLoading = nil;
    [progressHUDTmp release];
    progressHUDTmp.delegate = nil;
}


- (void)dealloc {
	self.webView = nil;
	self.url = nil;
    self.webTitle = nil;
    self.shareImage = nil;
	self.cloudLoading = nil;
    [loadingLabel release];
    [toolBarView release];
    [progressHUDTmp release];
    progressHUDTmp.delegate = nil;
    if (failView) {
        [failView release], failView = nil;
    }
    [super dealloc];
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    if ([self.url length] > 1)
	{
		//开始请求连接
		NSURL *webUrl =[NSURL URLWithString:self.url];
		NSURLRequest *request =[NSURLRequest requestWithURL:webUrl];
		[webView loadRequest:request];
	}
}

#pragma mark webView委托

//当网页视图被指示载入内容而得到通知
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*) reuqest navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *reuqestString = [NSString stringWithFormat:@"%@",reuqest.URL];
    
    if (isFromService == YES) {
        if ([self.url rangeOfString:reuqestString].location == NSNotFound) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.webView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        }else{
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.webView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
    }

    NSString *appleDownUrl1 = @"https://itunes.apple.com/";
    NSString *appleDownUrl2 = @"http://itunes.apple.com/";
    if ([reuqestString rangeOfString:appleDownUrl1 options:NSCaseInsensitiveSearch].location == NSNotFound && [reuqestString rangeOfString:appleDownUrl2 options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        return YES;
    }
    else
    {
        [[UIApplication sharedApplication] openURL:reuqest.URL];
        return NO;
    }
    
}

//当网页视图已经开始加载一个请求后，得到通知。
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [self.cloudLoading removeFromSuperview];
    cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(self.view.frame.size.width / 2+10, self.view.frame.size.height / 2 - 20.0f)];
    self.cloudLoading = tempLoadingView;
    [self.view insertSubview:self.cloudLoading atIndex:1];
    [tempLoadingView release];
}

//当网页视图结束加载一个请求之后，得到通知。
- (void)webViewDidFinishLoad:(UIWebView*)webView
{
	[self.cloudLoading removeFromSuperview];
    
    [self performSelector:@selector(saveData) withObject:nil afterDelay:0.5];
}

- (void)saveData
{
    NSString *photoname = [Common encodeBase64:(NSMutableData *)[self.url dataUsingEncoding: NSUTF8StringEncoding]];
    UIImage *img = [FileManager getPhoto:photoname];
    if (img != nil) {
        [FileManager removeFile:photoname];
    }
    
    UIImage *photo = [self imageWithView:self.webView];
    
    float imageWidth = photo.size.width;
    float imageHeight = photo.size.height;
    CGSize size = CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT);
    
    float scale = (size.width/imageWidth < size.height/imageHeight) ? size.width/imageWidth : size.height/imageHeight;
    CGSize newSize = CGSizeMake(imageWidth * scale, imageHeight * scale);
    //CGSize newSize = CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT);
    UIImage *scaledImage = [self imageWithImage:photo scaledToSize:newSize];
    
    [FileManager savePhoto:photoname withImage:scaledImage];
    
    //----------------------------------------
    if (self.shareImage == nil) {
        self.shareImage = [self imageWithView:self.webView];
    }
    
    if (self.webTitle == nil) {
        NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.title = str;
        self.webTitle = str;
    }
    
    //判断记录是否存在
//    NSArray *arr = [DBOperate queryData:T_SCAN_CONTENT theColumn:@"info" theColumnValue:self.url withAll:NO];
//    
//    if ([arr count] > 0) {
//        int infoId = [[[arr objectAtIndex:0] objectAtIndex:scan_content_infoId] intValue];
//        if (infoId == 0) {
//            [DBOperate updateData:T_SCAN_CONTENT tableColumn:@"title" columnValue:self.webTitle conditionColumn:@"info" conditionColumnValue:self.url];
//        }
//    }
    
    addButton.enabled = YES;
    shareBtn.enabled = YES;
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

//当在请求加载中发生错误时，得到通知。会提供一个NSSError对象，以标识所发生错误类型。
//-(void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.cloudLoading removeFromSuperview];
    self.title = @"创维云GO";
    if ([Common connectedToNetwork]) {
        // 网络繁忙，请重新再试
        [self failViewCreate:CwTypeViewNoRequest];
    } else {
        // 当前网络不可用，请重新再试
        [self failViewCreate:CwTypeViewNoNetWork];
    }
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentOffsetY = scrollView.contentOffset.y;

    if (scrollView.dragging == YES && scrollView.decelerating == NO)
    {
        if (scrollView.contentSize.height > self.view.frame.size.height + 44.0f)
        {
            if (isAnimation)
            {
                if (currentOffsetY - lastContentOffsetY > 10)
                {
                    isAnimation = NO;
                    lastContentOffsetY = scrollView.contentOffset.y;
                    [self hideTabBar:YES];
                    
                }
                else if (lastContentOffsetY - currentOffsetY > 10)
                {
                    isAnimation = NO;
                    lastContentOffsetY = scrollView.contentOffset.y;
                    [self hideTabBar:NO];
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    lastContentOffsetY = scrollView.contentOffset.y;
    isAnimation = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - scrollView.contentOffset.y ==  self.webView.frame.size.height)
    {
        [self hideTabBar:NO];
    }
}

- (void)hideTabBar:(BOOL)hide
{
//    if (hide)
//    {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
//    else
//    {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }

    CGRect toolBarViewFrame = hide ? CGRectMake( toolBarView.frame.origin.x , self.view.frame.size.height , toolBarView.frame.size.width , toolBarView.frame.size.height) : CGRectMake( toolBarView.frame.origin.x , self.view.frame.size.height - toolBarView.frame.size.height, toolBarView.frame.size.width , toolBarView.frame.size.height);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    toolBarView.frame = toolBarViewFrame;
    [UIView commitAnimations];
}

#pragma mark 当前view的截屏
- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.width), view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - ShareAPIActionDelegate
- (NSDictionary *)shareApiActionReturnValue
{
//    if (_isFromAbout == YES) {
//        //content = [NSString stringWithFormat:@"%@   %@",MORE_SHARE_CONTENT,self.url];;
//    }else {
        NSString *content = [NSString stringWithFormat:@"我用云+扫到了 #%@# ，内容非常精彩，推荐给您…  %@",self.webTitle,self.url];
//    }
    NSDictionary *shareDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.url,ShareUrl,
                               content,ShareContent,
                               self.webTitle,ShareTitle,
                               self.shareImage,ShareImage,nil];
    return shareDict;
}

#pragma mark --- methods ---
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

//添加到云桌面
- (void)addAction
{
    progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.delegate = self;
    progressHUDTmp.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_ok_normal.png"]] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1.5];
    progressHUDTmp.labelText = @"已添加到云桌面";
    
    self.navigationItem.rightBarButtonItem = nil;
    if (delegate != nil && [delegate respondsToSelector:@selector(addToContent:)]) {
        [delegate addToContent:self.listInfoId];
    }
}

- (void)btnCanClick:(int)value
{
    if (value == 1) {
        if ([webView canGoBack]) {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_normal" ofType:@"png"]];
            [lastBtn setImage:img forState:UIControlStateNormal];
            [img release], img = nil;
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_clicked" ofType:@"png"]];
            [lastBtn setImage:img forState:UIControlStateHighlighted];
            [img release], img = nil;
        }else {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_back_disabled" ofType:@"png"]];
            [lastBtn setImage:img forState:UIControlStateDisabled];
            [img release], img = nil;
        }
    }else {
        if ([webView canGoForward]) {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_normal" ofType:@"png"]];
            [nextBtn setImage:img forState:UIControlStateNormal];
            [img release], img = nil;
            img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_clicked" ofType:@"png"]];
            [nextBtn setImage:img forState:UIControlStateHighlighted];
            [img release], img = nil;
        }else {
            UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btn_next_disabled" ofType:@"png"]];
            [nextBtn setImage:img forState:UIControlStateDisabled];
            [img release], img = nil;
        }
    }
}

//上一个
- (void)lastAction
{
    [webView goBack];
    [self btnCanClick:1];
}

//下一个
- (void)nextAction
{
    [webView goForward];
    [self btnCanClick:2];
}

//分享
-(void)shareAction
{
    //NSLog(@"self.url === %@",self.url);
    if([self.url rangeOfString:@"yunlai.cn"].location != NSNotFound)
    {
        //_isNoShowDesk = NO;
    }
    else
    {
        //_isNoShowDesk = YES;
    }
    //_isNoShowPhone = NO;
    [[PopShareView defaultExample] showPopupView:self.navigationController delegate:self];
}

//刷新
-(void)reloadAction
{
	[webView reload];
}

@end
