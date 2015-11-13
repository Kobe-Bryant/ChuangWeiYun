//
//  LoadTableView.h
//  TableView
//
//  Created by 杜 福 on 13-1-6.
//  Copyright (c) 2013年 杜福. All rights reserved.
//

#import <UIKit/UIKit.h> 

typedef enum {
    KLoadStateNormal = 0,
    KLoadStatePulling = 1,
    KLoadStateLoading = 2,
    KLoadStateEnd = 3
}LoadState;

@interface LoadView : UIView
{
    UILabel *_stateLabel;       // 状态
//    UILabel *_dateLabel;        // 时间
    UIImageView *_arrowView;
    UIImageView *_bgImgView;
    UIImageView *_runImgView;
    UIActivityIndicatorView *_activityView;
    CALayer *_arrow;            // 图片动画
    BOOL _isLoading;             // 是否正在加载
}

@property (nonatomic, getter = isLoading) BOOL isLoading;
@property (nonatomic, getter = isTop) BOOL top;
@property (nonatomic) LoadState state;

- (id)initWithFrame:(CGRect)frame isTop:(BOOL)istop;

//- (void)updateDate:(NSDate *)date;

@end

@protocol LoadTableViewDelegate;

@interface LoadTableView : UITableView
{
    BOOL _isShowHeaderView;     // 是否显示headerView  NO 为不显示  默认YES为显示
    BOOL _isShowFooterView;     // 是否显示FooterView  NO 为不显示  默认YES为显示
    
    LoadView *_headerView;
    LoadView *_footerView;
    
    //UILabel *_msgLabel;
    
    id <LoadTableViewDelegate> loadDelegate;
}

@property (assign, nonatomic) id <LoadTableViewDelegate> loadDelegate;
@property (nonatomic, assign) BOOL isShowHeaderView;
@property (nonatomic, assign) BOOL isShowFooterView;

- (void)loadTableViewDidScroll:(UIScrollView *)scrollView;

- (void)loadTableViewDidEndDragging:(UIScrollView *)scrollView;

- (void)loadTableViewDidFinishedWithMessage:(NSString *)msg;
@end

@protocol LoadTableViewDelegate <NSObject>

@optional
// header刷新函数
- (void)loadTableViewUpRefresh:(LoadTableView *)tableView;
// footer刷新函数
- (void)loadTableViewDownRefresh:(LoadTableView *)tableView;
// date刷新函数
- (NSDate *)loadTableViewDateRefresh;
@end