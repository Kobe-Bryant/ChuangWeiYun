//
//  XLCycleScrollView.m
//  cw
//
//  Created by siphp on 2013-08-17.
//  Copyright (c) 2012 yunlai. All rights reserved.
//

#import "XLCycleScrollView.h"

//自动播放时间
#define PALY_DURATION 3.0f

@implementation XLCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;
@synthesize isAutoPlay = _isAutoPlay;
@synthesize isResponseTap = _isResponseTap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"default_320x240.png"]];
        _scrollView.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        
        [self addSubview:_pageControl];
        
        _curPage = 0;
    
    }
    return self;
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
    
    if (_totalPages > 1) {
        //自动轮播
        if (_isPlaying == NO) {
            if (_isAutoPlay)
            {
                [self performSelector:@selector(play) withObject:nil afterDelay:PALY_DURATION];
            }
        }
    }
}

//轮播图片
- (void)play
{
    _isPlaying = YES;
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:YES];
    [self performSelector:@selector(play) withObject:nil afterDelay:PALY_DURATION];
}

- (id)dequeueReusableViewWithIndex:(NSInteger)index
{
    if (index >= 0 && index < 3)
    {
        return [_reusableViews objectAtIndex:index] == [NSNull null] ? nil : [_reusableViews objectAtIndex:index];
    }
    
    return nil;
}

- (id)viewsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_curViews objectAtIndex:[indexPath section]];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0)
    {
        _scrollView.scrollEnabled = NO;
        return;
    } else if (_totalPages == 1) {
        _scrollView.scrollEnabled = NO;
        _pageControl.numberOfPages = 0;
    } else {
        _scrollView.scrollEnabled = YES;
        _pageControl.numberOfPages = _totalPages;
    }
    
    [self loadData];
}

- (void)loadData
{
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++)
    {
        UIView *v = [_curViews objectAtIndex:i];
        
        //添加点击事件
        if (_isResponseTap)
        {
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            [singleTap release];
        }
        
        //v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        v.frame = CGRectMake(v.frame.size.width * i , 0.0f ,v.frame.size.width , v.frame.size.height);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    
}

- (void)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    
    if (!_reusableViews) {
        _reusableViews = [[NSMutableArray alloc] init];
        [_reusableViews addObject:[NSNull null]];
        [_reusableViews addObject:[NSNull null]];
        [_reusableViews addObject:[NSNull null]];
    }
    
    //---------------左边----------------
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:pre inSection:0];
    UIView *preView = [_datasource pageAtIndex:self viewForRowAtIndexPath:preIndexPath];
    
    if ([_reusableViews objectAtIndex:0] == [NSNull null])
    {
        [_reusableViews replaceObjectAtIndex:0 withObject:preView];  
    }
    
    //---------------中间----------------
    NSIndexPath *pageIndexPath = [NSIndexPath indexPathForRow:page inSection:1];
    UIView *pageView = [_datasource pageAtIndex:self viewForRowAtIndexPath:pageIndexPath];
    
    if ([_reusableViews objectAtIndex:1] == [NSNull null])
    {
        [_reusableViews replaceObjectAtIndex:1 withObject:pageView];
    }
    
    //---------------右边----------------
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:last inSection:2];
    UIView *lastView = [_datasource pageAtIndex:self viewForRowAtIndexPath:lastIndexPath];
    
    if ([_reusableViews objectAtIndex:2] == [NSNull null])
    {
        [_reusableViews replaceObjectAtIndex:2 withObject:lastView];
    }
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:preView];
    [_curViews addObject:pageView];
    [_curViews addObject:lastView];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages){
        value = 0;
    }
    
    return value;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if ([_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    
}

- (void)dealloc
{
    [_scrollView release];
    [_pageControl release];
    [_reusableViews release];
    [_curViews release];
    [super dealloc];
}

@end
