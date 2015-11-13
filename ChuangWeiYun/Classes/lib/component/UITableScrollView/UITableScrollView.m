//
//  UITableScrollView.m
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "UITableScrollView.h"

//此处可以修改，如果为1  说明是3个内存在循环，如果为2  说明是5个内存在循环
#define KNumCell   2

@implementation UITableScrollView

@synthesize clickIndex;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame clickIndex:(NSInteger)aclickIndex pages:(NSInteger)cpages
{
    self = [super initWithFrame:frame];
    if (self) {
        clickIndex = aclickIndex;
        currIndex = clickIndex;
        self.delegate = self;
        pages = cpages;
        
        visiblePages = [[NSMutableSet alloc]initWithCapacity:0];
        recycledPages = [[NSMutableSet alloc]initWithCapacity:0];
    }
    return self;
}

- (void)setClickIndex:(NSInteger)aclickIndex
{
    clickIndex = aclickIndex;
    
    currIndex = clickIndex;
}

- (void)removeFromSuperviewSelf
{
    [recycledPages removeAllObjects];
    [visiblePages removeAllObjects];
    
    for (UIView *page in self.subviews) {
        [page removeFromSuperview];
    }
}

- (void)dealloc
{
    NSLog(@"UITableScrollView dealloc.......");
    [recycledPages removeAllObjects];
    [recycledPages release], recycledPages = nil;
    [visiblePages removeAllObjects];
    [visiblePages release], visiblePages = nil;
    
    [super dealloc];
}

// 创建视图
- (void)createScrollSubViews
{
    if ([dataSource respondsToSelector:@selector(tableScrollView:viewForRowAtIndex:)]) {
        
        int start = 0;
        int end = 0;
        
        if (sumPages > 2*pages+1) {
            
            start = clickIndex - pages >= 0 ? clickIndex - pages : 0;
            
            end = sumPages - clickIndex > pages ? clickIndex + pages : sumPages - 1;
            
        } else {
            start = 0;
            end = sumPages - 1;
        }

        for (int i = start; i <= end; i++) {
            NSLog(@"i = %d",i);
            [self addPageForScrollView:i];
        }
        
        self.contentOffset = CGPointMake(self.bounds.size.width*clickIndex, 0.f);
    }
}

// 增加页数
- (void)addPageForScrollView:(NSInteger)index
{
    if ([dataSource respondsToSelector:@selector(tableScrollView:viewForRowAtIndex:)]) {
        
        UITableScrollViewCell *pageCell = [dataSource tableScrollView:self viewForRowAtIndex:index];
        //设置index对应的UITableScrollViewCell图片和位置
        [self configurePage:pageCell forIndex:index];
        [self addSubview:pageCell];
        //将page加入到visiblePages集合里
        [visiblePages addObject:pageCell];
    }
}

// 设置页数
- (void)setSumPages:(NSInteger)asumPages
{
    sumPages = asumPages;
    self.contentSize = CGSizeMake(self.frame.size.width *sumPages, self.frame.size.height);
}

// 设置委托
- (void)setDataSource:(id<UITableScrollViewDelagate>)adataSource
{
    dataSource = adataSource;
    
    [self reloadView];
}

// 重载视图
- (void)reloadView
{
    if ([dataSource respondsToSelector:@selector(tableScrollViewNumberOfRow:)]) {
        NSInteger sum = [dataSource tableScrollViewNumberOfRow:self];
        
        sum = MAX(sum, 0);
        
        [self setSumPages:sum];
        
        [self createScrollSubViews];
    }
}

// 刷新视图
- (void)layoutView
{
    CGRect visibleBounds = self.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    // 判断如果快到边界，不需要去删除视图
    if ((firstNeededPageIndex <= pages-1 || lastNeededPageIndex >= sumPages - pages) && sumPages <= (2*pages+1)) {
        return;
    }
    
    firstNeededPageIndex = MAX(firstNeededPageIndex - pages, 0);
    lastNeededPageIndex = MIN(lastNeededPageIndex + pages, sumPages - 1);
    
    for (UITableScrollViewCell *page in visiblePages) {
        //不显⽰示的判断条件
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            //将没有显示的ImageView保存在recycledPages里
            [recycledPages addObject:page];
            //将未显示的ImageView移除
            [page removeFromSuperview];
        }
    }
    //集合-指定集合(即:所有不在既定集合中的元素)
    [visiblePages minusSet:recycledPages];
    
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            [self addPageForScrollView:index];
        }
    }
}

- (id)dequeueRecycledPage
{
    //查看是否有重用对象
    UITableScrollViewCell *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        //返回重用对象,并从重用集合中删除
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    
    for (UITableScrollViewCell *page in visiblePages) {
        if (page.index == index) {
            //如果index所对应的UITableScrollViewCell在可见数组中,将标志位标记为YES,否则返 回NO
            foundPage = YES;
            break;
        }
    }
    
    return foundPage;
}

- (void)configurePage:(UITableScrollViewCell *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.tag = index;
    page.frame = CGRectMake(self.frame.size.width*index, 0, page.frame.size.width,page.frame.size.height);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect visibleBounds = self.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    
    if (firstNeededPageIndex == -1) {
        firstNeededPageIndex = 0;
    } else if (firstNeededPageIndex == sumPages + 1) {
        firstNeededPageIndex = sumPages;
    }
    
    NSLog(@"dufu firstNeededPageIndex = %d",firstNeededPageIndex);
    NSLog(@"dufu currIndex = %d",currIndex);
    NSLog(@"dufu sumPages = %d",sumPages);
    
    if (currIndex != firstNeededPageIndex) {
        if ([dataSource respondsToSelector:@selector(tableScrollView:didSelectRowAtIndex:beforeIndex:)]) {
            [dataSource tableScrollView:self didSelectRowAtIndex:firstNeededPageIndex beforeIndex:currIndex];
        }
        
        currIndex = firstNeededPageIndex;
        
        [self layoutView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([dataSource respondsToSelector:@selector(tablescrollViewDidScroll:)]) {
        [dataSource tablescrollViewDidScroll:self];
    }
}

@end
