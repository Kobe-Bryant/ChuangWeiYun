//
//  LoadTableView.m
//  TableView
//
//  Created by 杜 福 on 13-1-6.
//  Copyright (c) 2013年 杜福. All rights reserved.
//

#import "LoadTableView.h"
#import <QuartzCore/QuartzCore.h>

#define KFontSize   12.0f
#define KFontSystem(s) [UIFont fontWithName:@"Arial" size:s] 
#define kTextColor [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:0.0]
#define kPROffsetY              60.f
#define kPRMargin               5.f
#define kPRLabelHeight          20.f
#define kPRLabelWidth           150.f
#define kPRArrowWidth           38.f
#define kPRArrowHeight          38.f
#define kPRAnimationDuration    .18f

#define KMsgHeight              32.f

@interface LoadView ()

- (void)layouts;

@end

@implementation LoadView

@synthesize isLoading = _isLoading;
@synthesize top = _top;
@synthesize state = _state;

- (void)dealloc
{
    [_stateLabel release], _stateLabel = nil;
    [_dateLabel release], _dateLabel = nil;
    [_arrowView release], _arrowView = nil;
    [_activityView release], _activityView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isTop:(BOOL)istop
{
    self = [super initWithFrame:frame];
    if (self) {
        self.top = istop;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = kPRBGColor;
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.font = KFontSystem(KFontSize);
        _stateLabel.textColor = kTextColor;
        _stateLabel.backgroundColor = kPRBGColor;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_stateLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.font = KFontSystem(KFontSize);
        _dateLabel.textColor = kTextColor;
        _dateLabel.backgroundColor = kPRBGColor;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_dateLabel];
        
        _arrowView = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 0, 20, 20)];
        
//        _arrow = [CALayer layer];
//        _arrow.frame = CGRectMake(0, 0, 20, 20);
//        _arrow.contentsGravity = kCAGravityResizeAspect;
//        _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"blueArrow.png"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;
//        [self.layer addSublayer:_arrow];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        
        [self layouts];
        
        [self updateDate:[NSDate date]];
    }
    return self;
}

- (void)setState:(LoadState)state animated:(BOOL)animated
{
    //float duration = animated ? kPRAnimationDuration : 0.f;
    
    if (_state != state) {
        _state = state;
        if (_state == KLoadStateLoading) {
            _arrow.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
            
            _isLoading = YES;
            if (self.top) {
                _stateLabel.text = NSLocalizedString(@"刷新中...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"加载中...", @"");
            }
            
        } else if (_state == KLoadStatePulling && !_isLoading) {
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
//            [CATransaction begin];
//            [CATransaction setAnimationDuration:duration];
//            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
//            [CATransaction commit];
            
            if (self.top) {
                _stateLabel.text = NSLocalizedString(@"松开即可刷新...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"释放加载更多...", @"");
            }
            
        } else if (_state == KLoadStateNormal && !_isLoading){
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
//            [CATransaction begin];
//            [CATransaction setAnimationDuration:duration];
//            _arrow.transform = CATransform3DIdentity;
//            [CATransaction commit];
            
            if (self.top) {
                _stateLabel.text = NSLocalizedString(@"下拉可以刷新...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"上拉加载更多...", @"");
            }
        } else if (_state == KLoadStateEnd) {
            if (!self.top) {
                _arrow.hidden = YES;
                _stateLabel.text = NSLocalizedString(@"没有了...", @"");
            }
        }
    }
}

- (void)setState:(LoadState)state {
    [self setState:state animated:YES];
}

#pragma mark - LoadView ()
- (void)layouts
{
    CGSize size = self.frame.size;
    CGRect stateFrame,dateFrame,arrowFrame;
    
    float x = 0,y,margin;
    margin = (kPROffsetY - 2*kPRLabelHeight)/2;
    
    if (self.top) {
        y = size.height - margin - kPRLabelHeight;
        dateFrame = CGRectMake(0,y,size.width,kPRLabelHeight);
        
        y = y - kPRLabelHeight;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        x = kPRMargin;
        y = size.height - margin - kPRArrowHeight;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
//        UIImage *arrow = [UIImage imageNamed:@"blueArrow.png"];
//        _arrow.contents = (id)arrow.CGImage;
        
        _stateLabel.text =  NSLocalizedString(@"下拉可以刷新...", @"");
    } else {
        y = margin;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight );
        
        y = y + kPRLabelHeight;
        dateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        x = kPRMargin;
        y = margin;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
//        UIImage *arrow = [UIImage imageNamed:@"blueArrowDown.png"];
//        _arrow.contents = (id)arrow.CGImage;
        
        _stateLabel.text = NSLocalizedString(@"上拉加载更多...", @"");
    }
    
    _stateLabel.frame = stateFrame;
    _dateLabel.frame = dateFrame;
    _arrowView.frame = arrowFrame;
    _activityView.center = _arrowView.center;
//    _arrow.frame = arrowFrame;
//    _arrow.transform = CATransform3DIdentity;
}

- (void)updateDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dateString = [df stringFromDate:date];
    NSString *title = NSLocalizedString(@"今天", nil);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:date toDate:[NSDate date] options:0];
    int year = [components year];
    int month = [components month];
    int day = [components day];
    if (year == 0 && month == 0 && day < 3) {
        if (day == 0) {
            title = NSLocalizedString(@"今天",nil);
        } else if (day == 1) {
            title = NSLocalizedString(@"昨天",nil);
        } else if (day == 2) {
            title = NSLocalizedString(@"前天",nil);
        }
        df.dateFormat = [NSString stringWithFormat:@"%@ HH:mm",title];
        dateString = [df stringFromDate:date];
        
    }
    _dateLabel.text = [NSString stringWithFormat:@"%@: %@",
                       NSLocalizedString(@"最后更新", @""),
                       dateString];
    [df release];
}

@end

@interface LoadTableView ()

//- (void)finishMessage:(NSString *)msg;

@end

@implementation LoadTableView

@synthesize loadDelegate;
@synthesize isShowHeaderView = _isShowHeaderView;
@synthesize isShowFooterView = _isShowFooterView;

- (void)dealloc
{
    [_headerView release], _headerView = nil;
    [_footerView release], _footerView = nil;
    
    [self removeObserver:self forKeyPath:@"contentSize"];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        _headerView = [[LoadView alloc] initWithFrame:CGRectMake(0, 0 - frame.size.height, frame.size.width, frame.size.height) isTop:YES];
        _headerView.hidden = NO;
        _isShowHeaderView = YES;
        [self addSubview:_headerView];
        
        _footerView = [[LoadView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height) isTop:NO];
        _footerView.hidden = NO;
        _isShowFooterView = YES;
        [self addSubview:_footerView];
        
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setIsShowHeaderView:(BOOL)isShowHeaderView
{
    _isShowHeaderView = isShowHeaderView;
    if (_isShowHeaderView) {
        _headerView.hidden = NO;
    } else {
        _headerView.hidden = YES;
    }
}

- (void)setIsShowFooterView:(BOOL)isShowFooterView
{
    _isShowFooterView = isShowFooterView;
    if (_isShowFooterView) {
        _footerView.hidden = NO;
    } else {
        _footerView.hidden = YES;
    }
}

- (void)loadTableViewDidScroll:(UIScrollView *)scrollView
{
    if (_headerView.state == KLoadStateLoading || _footerView.state == KLoadStateLoading) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    
    CGFloat yMargin = offset.y + size.height - contentSize.height;
    if (offset.y < (-kPROffsetY)) {
        if (!_isShowHeaderView) {
            return;
        }
        _headerView.state = KLoadStatePulling;
    }
    else if (offset.y > (-kPROffsetY) && offset.y < 0) {
        if (!_isShowHeaderView) {
            return;
        }
        _headerView.state = KLoadStateNormal;
    }
    else if (yMargin > kPROffsetY) {
        if (!_isShowFooterView) {
            return;
        }
        if (_footerView.state != KLoadStateEnd) {
            _footerView.state = KLoadStatePulling;
        }
    }
    else if (yMargin < kPROffsetY && yMargin > 0) {
        if (!_isShowFooterView) {
            return;
        }
        if (_footerView.state != KLoadStateEnd) {
            _footerView.state = KLoadStateNormal;
        }
    }
}

- (void)loadTableViewDidEndDragging:(UIScrollView *)scrollView
{
    if (_headerView.state == KLoadStateLoading || _footerView.state == KLoadStateLoading) {
        return;
    }
    
    if (_headerView.state == KLoadStatePulling) {
        _headerView.state = KLoadStateLoading;
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            self.contentInset = UIEdgeInsetsMake(kPROffsetY, 0, 0, 0);
        }];
        
        if ([loadDelegate respondsToSelector:@selector(loadTableViewUpRefresh:)]) {
            [loadDelegate loadTableViewUpRefresh:self];
        }
    }
    else if (_footerView.state == KLoadStatePulling){
        _footerView.state = KLoadStateLoading;
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            self.contentInset = UIEdgeInsetsMake(0, 0, kPROffsetY, 0);
        }];
        
        if ([loadDelegate respondsToSelector:@selector(loadTableViewDownRefresh:)]) {
            [loadDelegate loadTableViewDownRefresh:self];
        }
    }
}

- (void)loadTableViewDidFinishedWithMessage:(NSString *)msg
{
    if (_headerView.isLoading) {
        _headerView.isLoading = NO;
        [_headerView setState:KLoadStateNormal animated:NO];
        
        NSDate *nsdate = nil;
        if ([loadDelegate respondsToSelector:@selector(loadTableViewDateRefresh)]) {
            nsdate = [loadDelegate loadTableViewDateRefresh];
        }
        [_headerView updateDate:nsdate];
        
        [UIView animateWithDuration:kPRAnimationDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
//            if (msg != nil && ![msg isEqualToString:@""]) {
//                [self finishMessage:msg];
//            }
        }];
    }
    else if (_footerView.isLoading) {
        _footerView.isLoading = NO;
        [_footerView setState:KLoadStateNormal animated:NO];
        
        NSDate *nsdate = nil;
        if ([loadDelegate respondsToSelector:@selector(loadTableViewDateRefresh)]) {
            nsdate = [loadDelegate loadTableViewDateRefresh];
        }
        [_headerView updateDate:nsdate];
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^ {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
//            if (msg != nil && ![msg isEqualToString:@""]) {
//                [self finishMessage:msg];
//            }
        }];
    }
}

//- (void)finishMessage:(NSString *)msg
//{
//    __block CGRect rect = CGRectMake(0, self.contentOffset.y - KMsgHeight, self.bounds.size.width, KMsgHeight);
//    if (_msgLabel == nil) {
//        _msgLabel = [[UILabel alloc] init];
//        _msgLabel.frame = rect;
//        _msgLabel.font = KFontSystem(KFontSize);
//        _msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _msgLabel.backgroundColor = [UIColor brownColor];
//        _msgLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:_msgLabel];
//    }
//    _msgLabel.text = msg;
//    rect.origin.y += KMsgHeight;
//    [UIView animateWithDuration:.4f animations:^ {
//        _msgLabel.frame = rect;
//    } completion:^(BOOL finished) {
//        rect.origin.y -= KMsgHeight;
//        [UIView animateWithDuration:.4f delay:1.2f options:UIViewAnimationOptionCurveLinear animations:^{
//            _msgLabel.frame = rect;
//        } completion:^(BOOL finished) {
//            [_msgLabel removeFromSuperview];
//            [_msgLabel release],_msgLabel = nil;
//        }];
//    }];
//}

//- (void)launchRefreshing {
//    [self setContentOffset:CGPointMake(0,0) animated:NO];
//    [UIView animateWithDuration:kPRAnimationDuration animations:^{
//        self.contentOffset = CGPointMake(0, -kPROffsetY-1);
//    } completion:^(BOOL bl){
//        [self loadTableViewDidEndDragging:self];
//    }];
//}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGRect frame = _footerView.frame;
    CGSize contentSize = self.contentSize;
    frame.origin.y = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
    _footerView.frame = frame;
//    if (self.autoScrollToNextPage && _isFooterInAction) {
//        [self scrollToNextPage];
//        _isFooterInAction = NO;
//    } else if (_isFooterInAction) {
//        CGPoint offset = self.contentOffset;
//        offset.y += 44.f;
//        self.contentOffset = offset;
//    }
    
    
}

@end
