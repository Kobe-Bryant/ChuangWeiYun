//
//  CWPictureView.m
//  ImageDemo
//
//  Created by yunlai on 13-8-20.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CWPictureView.h"
#import "CWImageView.h"

@implementation CWPictureView

@synthesize scrollView = _scrollView;
@synthesize appView = _appView;
@synthesize blackMask = _blackMask;
@synthesize imgViewArr;
@synthesize fromImageView;
@synthesize urlStr;
@synthesize CwPictureViewClose;
@synthesize delegate;
@synthesize selectIndex;

- (id)initWithclickIndex:(NSInteger)aclickIndex
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade] ;
        
        _appView = (CWPictureView *)[UIApplication sharedApplication].delegate.window;
        
        self.frame = _appView.frame;
        
        selectIndex = aclickIndex;
        
        _scrollView = [[UITableScrollView alloc]initWithFrame:self.frame clickIndex:aclickIndex pages:2];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.dataSource = self;
        [self addSubview:_scrollView];
        
        _blackMask = [[UIView alloc] initWithFrame:self.frame];
        _blackMask.backgroundColor = [UIColor blackColor];
        _blackMask.alpha = 1;
        _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_blackMask atIndex:0];
        
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(10.f, CGRectGetHeight(self.frame)-60.f, 300.f, 30.f)];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
        
        UIImage *img = [UIImage imageNamed:@"icon_left_sliding.png"];
        leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(5.f, CGRectGetHeight(self.frame)/2 - img.size.height/2, img.size.width, img.size.height);
        [leftBtn setBackgroundImage:img forState:UIControlStateNormal];
        leftBtn.tag = 0;
        [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        leftBtn.hidden = YES;
        
        img = [UIImage imageNamed:@"icon_right_sliding.png"];
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 5.f - img.size.width, CGRectGetHeight(self.frame)/2 - img.size.height/2, img.size.width, img.size.height);
        [rightBtn setBackgroundImage:img forState:UIControlStateNormal];
        rightBtn.tag = 1;
        [rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        rightBtn.hidden = YES;
        
        [_appView addSubview:self];
    }
    return self;
}

- (void)setSelectIndex:(int)aselectIndex
{
    selectIndex = aselectIndex;
    
    _scrollView.clickIndex = selectIndex;
    
    [_scrollView removeFromSuperviewSelf];
    
    [_appView addSubview:self];
}

- (void)setBtnHide
{
    int count = self.imgViewArr.count;
    
    if (count == 1) {
        rightBtn.hidden = YES;
        leftBtn.hidden = YES;
    }else if (count - 1 == currIndex) {
        rightBtn.hidden = YES;
        leftBtn.hidden = NO;
    } else if (0 == currIndex) {
        rightBtn.hidden = NO;
        leftBtn.hidden = YES;
    } else {
        rightBtn.hidden = NO;
        leftBtn.hidden = NO;
    }
}

- (void)setPictureView:(NSMutableArray *)imgArr
{
//    self.fromImageView = imageView;
//    self.urlStr = url;
    self.imgViewArr = imgArr;
    currIndex = selectIndex;
    
    _blackMask.alpha = 1.f;
    
    [self setBtnHide];
    
    if (self.imgViewArr.count > 1) {
        _pageControl.numberOfPages = self.imgViewArr.count;
        _pageControl.currentPage = currIndex;
    }

    [_scrollView reloadView];
}

- (void)setPageControlPage:(BOOL)isNext
{
    CGPoint point = _scrollView.contentOffset;
    
    if (isNext) {
        if (_pageControl.currentPage == self.imgViewArr.count - 1) {
            _pageControl.currentPage = self.imgViewArr.count - 1;
        } else {
            _pageControl.currentPage++;
            _scrollView.contentOffset = CGPointMake(point.x + _scrollView.frame.size.width, 0.f);
        }
    } else {
        if (_pageControl.currentPage == 0) {
            _pageControl.currentPage = 0;
        } else {
            _pageControl.currentPage--;
            _scrollView.contentOffset = CGPointMake(point.x - _scrollView.frame.size.width, 0.f);
        }
    }
    
    if (currIndex != _pageControl.currentPage) {
        currIndex = _pageControl.currentPage;
        
        if ([delegate respondsToSelector:@selector(cwPictureViewSetPage:)] && delegate != nil) {
            [delegate cwPictureViewSetPage:currIndex];
        }
        
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

#pragma mark - UITableScrollViewDelagate
- (NSInteger)tableScrollViewNumberOfRow:(UITableScrollView *)tableScrollView
{
    return self.imgViewArr.count;
}

- (UITableScrollViewCell *)tableScrollView:(UITableScrollView *)tableScrollView viewForRowAtIndex:(NSInteger)index
{
    CWImageView *imgView = [self.imgViewArr objectAtIndex:index];
    
    CGRect newFrame = [[self.imgViewArr objectAtIndex:selectIndex] convertRect:[[UIScreen mainScreen] applicationFrame] toView:nil];
    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = imgView.frame.size;
    
    CWPictureViewCell *cell = [tableScrollView dequeueRecycledPage];
    
    if (cell == nil) {
        cell = [[[CWPictureViewCell alloc]initWithFrame:self.frame] autorelease];
        
        [cell createView];
    } else {
        cell.imageView = nil;
    }
    
    cell.delegate = self;
    cell.blackMask = _blackMask;
    
    [cell setPictureViewCellContent:imgView rect:newFrame];
    
    return cell;
}

- (void)tableScrollView:(UITableScrollView *)tableScrollView didSelectRowAtIndex:(NSInteger)index beforeIndex:(NSInteger)aindex
{
//    CWPictureViewCell *cell = [(CWPictureViewCell *)[tableScrollView viewWithTag:index];
//    [cell zoomInZoomIn:CGPointMake(KUIScreenWidth/2, KUIScreenHeight/2)];
    currIndex = index;
    
    [self setBtnHide];
    
    if ([delegate respondsToSelector:@selector(cwPictureViewSetPage:)] && delegate != nil) {
        [delegate cwPictureViewSetPage:index];
    }
}

- (void)tablescrollViewDidScroll:(UIScrollView *)scrollView
{    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

#pragma mark - CWPictureViewCellDelegate
- (void)removePictureView
{
    [self.imgViewArr removeAllObjects];
    [self removeFromSuperview];
    self.CwPictureViewClose();
}

- (void)dealloc
{
    NSLog(@"CWPictureView dealloc....");
    [_scrollView release], _scrollView = nil;
    
    self.fromImageView = nil;
    self.urlStr = nil;
    
    [imgViewArr removeAllObjects];
    self.imgViewArr = nil;
    
    [_blackMask release], _blackMask = nil;
    [_pageControl release], _pageControl = nil;
    
    self.CwPictureViewClose = nil;
    
    [super dealloc];
}

@end
