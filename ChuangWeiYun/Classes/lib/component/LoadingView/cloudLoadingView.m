//
//  cloudLoadingView.m
//  yunPai
//
//  Created by siphp on 13-8-3.
//
//

#import "cloudLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation cloudLoadingView

@synthesize backgroundImageView = _backgroundImageView;
@synthesize loadingImageView = _loadingImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //loading 圆线
        UIImage *loadingImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_loading" ofType:@"png"]];
        UIImageView *tempLoadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 0.f, 0.f, loadingImage.size.width, loadingImage.size.height)];
        tempLoadingImageView.image = loadingImage;
        self.loadingImageView = tempLoadingImageView;
        [self addSubview:self.loadingImageView];
        [loadingImage release];
        [tempLoadingImageView release];
        
        //底部 
        UIImage *backgroundImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_logo" ofType:@"png"]];
        UIImageView *tempBackgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, backgroundImage.size.width, backgroundImage.size.height)];
        tempBackgroundImageView.image = backgroundImage;
        self.backgroundImageView = tempBackgroundImageView;
        [self addSubview:self.backgroundImageView];
        [backgroundImage release];
        [tempBackgroundImageView release];
        
        [self.loadingImageView setCenter:self.backgroundImageView.center];
        
        //动画
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 2;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 10000;
        [self.loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return self;
}

// dufu add 2013.09.30
//+ (cloudLoadingView *)
//{
//    
//}

- (void) dealloc {
    [_backgroundImageView release];
    [_loadingImageView release];
    [super dealloc];
}

@end
