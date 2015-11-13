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
#define kTextColor [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0]
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
    [_arrowView release], _arrowView = nil;
    [_activityView release], _activityView = nil;
    [_bgImgView release], _bgImgView = nil;
    [_runImgView release], _runImgView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isTop:(BOOL)istop
{
    self = [super initWithFrame:frame];
    if (self) {
        self.top = istop;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.font = KFontSystem(KFontSize);
        _stateLabel.textColor = kTextColor;
        _stateLabel.backgroundColor = [UIColor clearColor];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_stateLabel];
        
        _arrowView = [[UIImageView alloc]initWithFrame:CGRectZero];
        
        _arrow = [CALayer layer];
        _arrow.contentsGravity = kCAGravityResizeAspect;
        _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"down_refresh_store.png"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;
        [self.layer addSublayer:_arrow];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        
        _bgImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:_bgImgView];
        
        // 转
        UIImage *loadingImage = [UIImage imageNamed:@"rotate_refresh_store.png"];
        _runImgView = [[UIImageView alloc]initWithFrame:CGRectMake( 0.f , 0.f , loadingImage.size.width , loadingImage.size.height)];
        _runImgView.image = loadingImage;
        _runImgView.hidden = YES;
        [self addSubview:_runImgView];

        [self layouts];
    }
    return self;
}

- (void)removeAnimated
{
    [_runImgView.layer removeAllAnimations];
}

- (void)durationAnimated
{
    //[self removeAnimated];
    //动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    [_runImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)setState:(LoadState)state animated:(BOOL)animated
{
    float duration = animated ? kPRAnimationDuration : 0.f;
    
    if (_state != state) {
        _state = state;
        if (_state == KLoadStateLoading) {
            _arrow.hidden = YES;
            _runImgView.hidden = NO;
            [self durationAnimated];
            
            _isLoading = YES;
            if (self.top) {
                _stateLabel.text = NSLocalizedString(@"正在加载中...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"加载中...", @"");
            }
        } else if (_state == KLoadStatePulling && !_isLoading) {
            
            _arrow.hidden = NO;
            _runImgView.hidden = YES;
            [self removeAnimated];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            
            if (self.top) {
                _stateLabel.text = NSLocalizedString(@"松开即可刷新...", @"");
            } else {
                _stateLabel.text = NSLocalizedString(@"释放加载更多...", @"");
            }
            
        } else if (_state == KLoadStateNormal && !_isLoading){
            
            _arrow.hidden = NO;
            _runImgView.hidden = YES;
            [self removeAnimated];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
            
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
    CGRect stateFrame,arrowFrame; // dateFrame
    
    float x = 0,y,margin;
    margin = (kPROffsetY - 2*kPRLabelHeight)/2;
    
    if (self.top) {
        self.backgroundColor = kPRBGColor;
        
        y = size.height - kPRLabelHeight - margin;
        stateFrame = CGRectMake(8.f, y+6, size.width, kPRLabelHeight);

        UIImage *arrow = [UIImage imageNamed:@"down_refresh_store.png"];
        x = 120.f - arrow.size.width;
        y = size.height - margin - kPRLabelHeight + 8.f;
        arrowFrame = CGRectMake(x, y, arrow.size.width, arrow.size.height);
        _arrow.contents = (id)arrow.CGImage;
        
        UIImage *bgImg = [UIImage imageNamed:@"logo_default_store.png"];
        _bgImgView.image = bgImg;
        x = size.width/2-bgImg.size.width/2;
        y = size.height - bgImg.size.height - kPRLabelHeight - margin;
        _bgImgView.frame = CGRectMake(x, y-6, bgImg.size.width, bgImg.size.height);
        
        _stateLabel.text =  NSLocalizedString(@"下拉可以刷新...", @"");
    } else {
        self.backgroundColor = [UIColor clearColor];
        
        y = margin;
        stateFrame = CGRectMake(10.f, y, size.width, kPRLabelHeight );
        
        UIImage *arrow = [UIImage imageNamed:@"up_refresh_store.png"];
        x = 120.f - arrow.size.width;
        y = margin + 2.f;
        arrowFrame = CGRectMake(x, y, arrow.size.width, arrow.size.height);
        _arrow.contents = (id)arrow.CGImage;
        
        _stateLabel.text = NSLocalizedString(@"上拉加载更多...", @"");
    }
    
    _stateLabel.frame = stateFrame;
    _arrowView.frame = arrowFrame;
    _runImgView.center = _arrowView.center;
    _arrow.frame = arrowFrame;
    _arrow.transform = CATransform3DIdentity;
}

@end

@interface LoadTableView ()

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
    NSLog(@"isShowFooterView = %d",isShowFooterView);
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
        
        [UIView animateWithDuration:kPRAnimationDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
        }];
    }
    else if (_footerView.isLoading) {
        _footerView.isLoading = NO;
        [_footerView setState:KLoadStateNormal animated:NO];
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^ {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
        }];
    }
}

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
