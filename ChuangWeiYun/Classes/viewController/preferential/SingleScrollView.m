//
//  SingleScrollView.m
//  cw
//
//  Created by yunlai on 13-9-27.
//
//

#import "SingleScrollView.h"
#import "CWImageView.h"
#import "Common.h"

@implementation SingleScrollView

@synthesize delegate;

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.bounces = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"default_320x240.png"]];
        [self addSubview:_scrollView];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.tag = 1234567;
        
        [self addSubview:_pageControl];
        
        [self setSums:0];
        
        currentPage = 0;
        _pageControl.currentPage = currentPage;
    }
    return self;
}

- (void)invalidateSingle
{
    [timer invalidate];
    timer = nil;
}

- (void)dealloc
{
    NSLog(@"singlescrollview dealloc. ......");
    [_scrollView release], _scrollView = nil;
    [_pageControl release], _pageControl = nil;
    
    [super dealloc];
}

// page轮询
- (void)runTimePage
{
    if (sums > 1) {
        int page = _pageControl.currentPage; // 获取当前的page
        page++;
        if (page >= sums) {
            page = 0;
            _pageControl.currentPage = page;
            [self.scrollView scrollRectToVisible:CGRectMake(320*page,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height) animated:NO];
        } else {
            page = page >= sums ? 0 : page ;
            _pageControl.currentPage = page;
            [self.scrollView setContentOffset:CGPointMake(320*page, 0) animated:YES];
        }
    }
}

// 设置当前页 的page
- (void)setCurrentPage:(int)page
{
    NSLog(@"page = %d",page);
    if (currentPage != page) {
        currentPage = page;
        _pageControl.currentPage = currentPage;
    }
    CGPoint offset = _scrollView.contentOffset;
    
    offset.x = _scrollView.frame.size.width * page;
    
    _scrollView.contentOffset = offset;
}

// 设置sums的总和
- (void)setSums:(int)sum
{
    sums = sum;
    if (sums <= 1) {
        _pageControl.hidden = YES;
    } else {
        _pageControl.hidden = NO;
        _pageControl.numberOfPages = sums;
    }
    
    int width = CGRectGetWidth(self.frame);
    int height = CGRectGetHeight(self.frame);
    
    _scrollView.contentSize = CGSizeMake(width * sums, height);
}

// 设置当前委托
- (void)setDelegate:(id<SingleScrollViewDelegate>)adelegate
{
    delegate = adelegate;
    
    [self reloadScrollView];
}

// 重新刷新
- (void)reloadScrollView
{
    if ([delegate respondsToSelector:@selector(numberOfPagesSingle:)]) {
        int sum = [delegate numberOfPagesSingle:self];
        [self setSums:sum];
        
        for (id view in _scrollView.subviews) {
            if ([view isKindOfClass:[CWImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        for (int i = 0; i < sums; i++) {
            if ([delegate respondsToSelector:@selector(pageSingleReturnEachView:pageIndex:)]) {
                CWImageView *view = [delegate pageSingleReturnEachView:self pageIndex:i];
                view.tag = i;
                [_scrollView addSubview:view];
            }
        }
    }
}

// 给CWImageView负值
- (void)reloadScrollViewImage:(UIImage *)img index:(int)index
{
    for (int i = 0; i < _scrollView.subviews.count; i++) {
        if (index == i) {
            CWImageView *imgView = [_scrollView.subviews objectAtIndex:index];
            CGSize size = [UIImage fitsize:img.size size:imgView.frame.size];
            CGFloat x = index*KUIScreenWidth + (KUIScreenWidth-size.width) / 2;
            CGFloat y = (imgView.frame.size.height - size.height) / 2;
            imgView.frame = CGRectMake(x, y, size.width, size.height);
            imgView.image = img;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;

    int page = offset.x / scrollView.frame.size.width;
    if (currentPage != page) {
        currentPage = page;
        _pageControl.currentPage = currentPage;
    }
}

@end
