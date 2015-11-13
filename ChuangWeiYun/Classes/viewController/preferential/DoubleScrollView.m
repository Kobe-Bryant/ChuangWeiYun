//
//  DoubleScrollView.m
//  doubleScrollViewDemo
//
//  Created by yunlai on 13-9-17.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "DoubleScrollView.h"

@implementation DoubleScrollView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];        
        [self addSubview:_pageControl];
        
        [self setSums:0];
        
        currentPage = 0;
        
        _pageControl.currentPage = currentPage;
        
    }
    return self;
}

- (void)dealloc
{
    [_scrollView release], _scrollView = nil;
    [_pageControl release], _pageControl = nil;
    
    [super dealloc];
}

- (void)updateDots
{
    for (int i = 0; i < [_pageControl.subviews count]; i++) {
        UIView *subView = [_pageControl.subviews objectAtIndex:i];
        if ([NSStringFromClass([subView class]) isEqualToString:NSStringFromClass([UIImageView class])]) {
            ((UIImageView*)subView).image = (_pageControl.currentPage == i ? [UIImage imageNamed:@"curr_pangcontrol.png"] : [UIImage imageNamed:@"bg_pangcontrol.png"]);
        }
    }
}

// 设置当前页 的page
- (void)setCurrentPage:(int)page
{
    if (currentPage != page) {
        currentPage = page;
        _pageControl.currentPage = currentPage;
        [self updateDots];
    }
}

// 设置sums的总和
- (void)setSums:(int)sum
{
    sums = sum;
    int pages = sums % 2 == 0 ? sums / 2 : sums / 2 + 1;
    if (pages <= 1) {
        _pageControl.hidden = YES;
    } else {
        _pageControl.hidden = NO;
        _pageControl.numberOfPages = pages;
    }
    
    int width = CGRectGetWidth(self.frame);
    int height = CGRectGetHeight(self.frame);
    
    _scrollView.contentSize = CGSizeMake(width * (sums%2 == 0 ? sums/2 : sums/2 + 1), height);
}

// 设置当前委托
- (void)setDelegate:(id<DoubleScrollViewDelegate>)adelegate
{
    delegate = adelegate;
    
    [self reloadScrollView];
}

// 重新刷新
- (void)reloadScrollView
{
    if ([delegate respondsToSelector:@selector(numberOfPages:)]) {
        int sum = [delegate numberOfPages:self];
        [self setSums:sum];
    }
    
    for (id view in _scrollView.subviews) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i < sums; i++) {
        if ([delegate respondsToSelector:@selector(pageReturnEachView:pageIndex:)]) {
            UIView *view = [delegate pageReturnEachView:self pageIndex:i];
            view.tag = i;
            [_scrollView addSubview:view]; 
        }
    }
    
    [self updateDots];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    int page = offset.x / scrollView.frame.size.width;
    [self setCurrentPage:page];
}
@end
