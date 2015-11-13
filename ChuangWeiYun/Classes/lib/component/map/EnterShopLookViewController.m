//
//  EnterShopLookViewController.m
//  cw
//
//  Created by yunlai on 13-10-21.
//
//

#import "EnterShopLookViewController.h"

#import "Common.h"
#import "FileManager.h"
#import "IconDownLoader.h"
#import "cwAppDelegate.h"
#import "IconPictureProcess.h"
#import "UIImageView+WebCache.h"

@interface EnterShopLookViewController ()
{
    UIButton *leftBtn;
    UIButton *rightBtn;
}
@end

@implementation EnterShopLookViewController
@synthesize pageControl=_pageControl;
@synthesize adsArray;
@synthesize pics;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"店面环境";
    
    NSLog(@"店面图片字符串:%@",self.pics);
    self.adsArray = [self.pics componentsSeparatedByString:@","];
    NSLog(@"店面图片数组:%@",self.adsArray);
    
    if ([self.pics isEqualToString:@""]||[self.pics isEqualToString:@"<null>"]) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, 30)];
        label.text = @"该店还没有上传店面照片哦~";
        label.textColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.center = self.view.center;
        [self.view addSubview:label];
        [label release], label = nil;
        self.view.backgroundColor = KCWViewBgColor;
    }else{
       
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -44, KUIScreenWidth, KUIScreenHeight)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
        self.view.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f];
    }
    
     NSLog(@"adscount%d",[self.adsArray count]);
    
    [_scrollView setContentSize:CGSizeMake(KUIScreenWidth * [self.adsArray count], KUIScreenHeight)];

    
    for (int i = 0; i < [self.adsArray count]; i++) {
        _zoomScrollView = [[MRZoomScrollView alloc]init];
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0;
        _zoomScrollView.frame = frame;
        _zoomScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_zoomScrollView];
        
       
        //图片
        NSString *picUrl = [self.adsArray objectAtIndex:i];
        
        [_zoomScrollView.imageView setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageCwNamed:@"default_320x180.png"]];
     
    }
    
    // 视图左右按钮
    UIImage *img = [UIImage imageNamed:@"icon_left_sliding.png"];
    leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(5.f, KUIScreenHeight/2-img.size.height-img.size.height/2, img.size.width-3, img.size.height);
    [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
    leftBtn.alpha = 0.8;
    leftBtn.tag = 0;
    [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];

    img = [UIImage imageNamed:@"icon_right_sliding.png"];
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(KUIScreenWidth-img.size.width-5, KUIScreenHeight/2-img.size.height-img.size.height/2, img.size.width-3, img.size.height);
    [rightBtn setBackgroundImage:img forState:UIControlStateNormal];
    rightBtn.tag = 1;
    rightBtn.alpha = 0.8;
    [rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];

    [self setBtnHide];
    
    
    CGRect rect = self.view.bounds;
    rect.origin.y = rect.size.height - 120;
    rect.size.height = 30;
    _pageControl = [[UIPageControl alloc] initWithFrame:rect];
    _pageControl.userInteractionEnabled = NO;
    
    [self.view addSubview:_pageControl];
    
    _curPage = 0;
    _totalPages = 0;
    
    if ([self.adsArray count]>1) {
        _totalPages=[self.adsArray count];
    }
    
    
    _pageControl.currentPage = _curPage;
    _pageControl.numberOfPages = _totalPages;
    
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [singleFingerOne setDelegate:self];
    [_scrollView addGestureRecognizer:singleFingerOne];
}


- (void)setPageControlPage:(BOOL)isNext
{
    CGPoint point = _scrollView.contentOffset;
    
    if (isNext) {
        if (_pageControl.currentPage == self.adsArray.count - 1) {
            _pageControl.currentPage = self.adsArray.count - 1;
        } else {
            _pageControl.currentPage++;
            _scrollView.contentOffset = CGPointMake(point.x + _zoomScrollView.frame.size.width, 0.f);
            
        }
    } else {
        if (_pageControl.currentPage == 0) {
            _pageControl.currentPage = 0;
        } else {
            _pageControl.currentPage--;
            _scrollView.contentOffset = CGPointMake(point.x - _scrollView.frame.size.width, 0.f);
        }
    }
    
    if (_curPage != _pageControl.currentPage) {
        _curPage = _pageControl.currentPage;

        [self setBtnHide];
    }
}

- (void)btnClick:(UIButton *)btn
{
    if (btn.tag == 0) {
        [self setPageControlPage:NO];
    } else {
        [self setPageControlPage:YES];
    }
}

- (void)setBtnHide
{
    int count = self.adsArray.count;
    
    if (count == 1) {
        rightBtn.hidden = YES;
        leftBtn.hidden = YES;
    }else if (count - 1 == _curPage) {
        rightBtn.hidden = YES;
        leftBtn.hidden = NO;
    } else if (0 == _curPage) {
        rightBtn.hidden = NO;
        leftBtn.hidden = YES;
    } else {
        rightBtn.hidden = NO;
        leftBtn.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)handleSingleFingerEvent:(UIGestureRecognizer *)gesture{
    
    
    if (self.navigationController.navigationBar.alpha == 0.0) {
        
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        
        [UIView animateWithDuration:0.4 animations:^{
            self.navigationController.navigationBar.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (scrollView==_scrollView)
    {
    
        NSInteger currentIndex = fabs(scrollView.contentOffset.x / self.view.frame.size.width);
        if (currentIndex == _curPage) { return; }
        
        _curPage = currentIndex;
        
        CGPoint point;
        point=scrollView.contentOffset;
        point.x=currentIndex*self.view.frame.size.width;
        scrollView.contentOffset=point;
        
        [self setBtnHide];
    }
    _pageControl.currentPage = _curPage;
    
}



//回调 获到网络图片后的回调函数
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
    
    if (iconDownloader != nil)
    {
        // Display the newly loaded image
		if(iconDownloader.cardIcon.size.width>2.0)
		{
			//保存图片
			[[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
            
             _zoomScrollView.imageView.image  = iconDownloader.cardIcon;
            
        }
        
		[[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
    }
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}

@end
