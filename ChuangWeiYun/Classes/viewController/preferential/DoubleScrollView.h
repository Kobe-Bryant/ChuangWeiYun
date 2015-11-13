//
//  DoubleScrollView.h
//  doubleScrollViewDemo
//
//  Created by yunlai on 13-9-17.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DoubleScrollViewDelegate;

@interface DoubleScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    int sums;
    int currentPage;
    
    id <DoubleScrollViewDelegate> delegate;
}

@property (assign, nonatomic) id <DoubleScrollViewDelegate> delegate;

- (void)reloadScrollView;

@end


@protocol DoubleScrollViewDelegate <NSObject>

@optional
- (NSInteger)numberOfPages:(DoubleScrollView *)doubleScrollView;
- (UIView *)pageReturnEachView:(DoubleScrollView *)doubleScrollView pageIndex:(NSInteger)index;

@end
