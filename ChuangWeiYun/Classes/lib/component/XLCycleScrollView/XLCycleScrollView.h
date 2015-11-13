//
//  XLCycleScrollView.h
//  cw
//
//  Created by siphp on 2013-08-17.
//  Copyright (c) 2012 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XLCycleScrollViewDelegate;
@protocol XLCycleScrollViewDatasource;

@interface XLCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;

    id<XLCycleScrollViewDelegate> _delegate;
    id<XLCycleScrollViewDatasource> _datasource;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_reusableViews;
    NSMutableArray *_curViews;
    
    BOOL _isAutoPlay;
    BOOL _isResponseTap;
    BOOL _isPlaying;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<XLCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<XLCycleScrollViewDelegate> delegate;
@property (nonatomic,assign) BOOL isAutoPlay;
@property (nonatomic,assign) BOOL isResponseTap;

- (id)dequeueReusableViewWithIndex:(NSInteger)index;
- (id)viewsForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadData;

@end

@protocol XLCycleScrollViewDelegate <NSObject>
@optional
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@protocol XLCycleScrollViewDatasource <NSObject>
@required
- (NSInteger)numberOfPages;
- (UIView *)pageAtIndex:(XLCycleScrollView *)xlcScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
