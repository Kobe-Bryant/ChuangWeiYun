//
//  PopupView.m
//  cw
//
//  Created by yunlai on 13-9-5.
//
//

#import "PopupView.h"

@implementation PopupView

@synthesize popupView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat width = [UIScreen mainScreen].applicationFrame.size.width;
        CGFloat height = [UIScreen mainScreen].applicationFrame.size.height;
        
        popupView = [[UIView alloc]initWithFrame:CGRectMake(0.f, 0.f, width, height + 20.f)];
    }
    return self;
}

- (void)addPopupSubview{
    [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication].delegate.window addSubview:popupView];
    }];
}

- (void)addPopupSubview:(int)animationType
{
    popupView.alpha = 1.0f;
    
    if(animationType == 1){
        // 弹窗动画 仿系统效果 12.13 chenfeng
        CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        popAnimation.duration = 0.4;
        popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                                [NSValue valueWithCATransform3D:CATransform3DIdentity]];
        popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
        popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:popAnimation forKey:nil];
        
        popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
        [[UIApplication sharedApplication].delegate.window addSubview:popupView];
        
    }else{
        [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].delegate.window addSubview:popupView];
        }];
    }
  
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    [popupView removeFromSuperview];
}

- (void)dealloc
{
    [popupView release], popupView = nil;
    
    [super dealloc];
}


@end
