//
//  SingleScrollView.h
//  cw
//
//  Created by yunlai on 13-9-27.
//
//

#import <UIKit/UIKit.h>

@protocol SingleScrollViewDelegate;
@class CWImageView;

@interface SingleScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    int sums;
    int currentPage;
    
    NSTimer *timer;
    
    id <SingleScrollViewDelegate> delegate;
}

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) id <SingleScrollViewDelegate> delegate;

- (void)invalidateSingle;

- (void)reloadScrollView;

// 设置当前页 的page
- (void)setCurrentPage:(int)page;

// 给CWImageView负值
- (void)reloadScrollViewImage:(UIImage *)img index:(int)index;

@end

@protocol SingleScrollViewDelegate <NSObject>

@optional
- (NSInteger)numberOfPagesSingle:(SingleScrollView *)singleScrollView;
- (CWImageView *)pageSingleReturnEachView:(SingleScrollView *)singleScrollView pageIndex:(NSInteger)index;

@end