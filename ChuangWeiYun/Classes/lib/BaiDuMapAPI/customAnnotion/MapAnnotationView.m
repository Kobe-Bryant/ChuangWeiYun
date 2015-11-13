//
//  MapAnnotationView.m
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "MapAnnotationView.h"

@implementation MapViewCW

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _seperatorLength = 50;
        _radio = 120;
        
    }
    return self;
}
static bool isInvalidate = NO;

int beginRadio = -20;
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //18 42 66
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextAddArc(ctx, self.center.x, self.center.y, _radio, 0, M_PI*2, 1);
    CGContextEOClip(ctx);
    
    for (int i=beginRadio; i>=-_seperatorLength; i-=_seperatorLength-10) {
        CGFloat start = i;
        CGFloat end = start + _seperatorLength;
        if (start<0) {
            start = 0;
        }
        
//        CGFloat ss = 0;
//        if (start>0&&end-start<_seperatorLength) {
//            ss = (end - start)/_seperatorLength;
//        }
        
        CGFloat locs[3] = {1,0.7,1};

//        CGFloat colors[16] = {134/255.0,192/255.0,224/255.0,0.6,
//            134/255.0,192/255.0,224/255.0,0.1,
//            134/255.0,172/255.0,224/255.0,0.5
//        };
        
        CGFloat colors[16] = {84/255.0,187/255.0,254/255.0,0.6,
            84/255.0,187/255.0,254/255.0,0.1,
            84/255.0,187/255.0,254/255.0,0.5
        };
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locs, 3.5);
        //NSLog(@"%d  %d",start,end);
        CGContextDrawRadialGradient(ctx, gradient, CGPointMake(self.center.x, self.center.y), start, CGPointMake(self.center.x, self.center.y), end, 0);
        CGGradientRelease(gradient);
        //NSLog(@"%f------%f",self.center.x,self.center.y);
        
       
    }
    
    if (beginRadio == _seperatorLength) {
        self.alpha = 0;
    }
    
    //release colorspace and gradient
    CGColorSpaceRelease(colorSpace);
    
   
    
}


- (void)change {
    if (beginRadio == _radio + _seperatorLength) {
        beginRadio -= _seperatorLength;
        
    }
    
    beginRadio+=3;
    
//    if (beginRadio>100) {
//        beginRadio=-50;
//    }
    
    [self setNeedsDisplay];

}
-(void)startAnimation{

    beginRadio = -50;
    if (!isInvalidate) {
        timer=[NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(change) userInfo:nil repeats:YES];
    }

    isInvalidate=YES;
    
}
- (void)stopAnimation
{
    [timer invalidate];
    timer=nil;
    isInvalidate=NO;
}

- (void)dealloc
{
    [timer invalidate];
    RELEASE_SAFE(timer);
    [super dealloc];
}

@end



@implementation MapAnnotationView

@synthesize clickBtn=_clickBtn;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 30, 30)];
        
        _clickBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_clickBtn setFrame:CGRectMake(0, 0, 30, 30)];
        _clickBtn.center=self.center;
        _clickBtn.enabled = NO;
        [_clickBtn setImage:[UIImage imageNamed:@"icon_center_point.png"] forState:UIControlStateNormal];
        [self addSubview:_clickBtn];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isStops:) name:@"isStopAnimation" object:nil];
    }
    return self;
}

-(void)start{
    if (_mapPinView.superview) {
        [_mapPinView removeFromSuperview];
        RELEASE_SAFE(_mapPinView);
    }
    
    [self setFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mapPinView = [[MapViewCW alloc] initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight)];
    _mapPinView.center=self.center;
    _mapPinView.tag=1010;
    _mapPinView.userInteractionEnabled=NO;
    _mapPinView.backgroundColor = [UIColor clearColor];
    [self addSubview:_mapPinView];

    [_mapPinView startAnimation];
    
    [self performSelector:@selector(stop) withObject:nil afterDelay:3.5];
    
}
-(void)isStops:(NSNotification *)notification{
    if ([[notification name] isEqualToString:@"isStopAnimation"]&&[[notification object] isEqualToString:@"YES"])
    {
        [self stop];
        //NSLog (@"Successfully received the notification!");
    }else{
        [self performSelector:@selector(stop) withObject:nil afterDelay:3.5];
    }
}

-(void)stop{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    _mapPinView.alpha=0;

    [_mapPinView stopAnimation];
    
    if (_mapPinView.superview) {
        _mapPinView.frame=CGRectZero;
        self.frame=CGRectZero;
        [_mapPinView removeFromSuperview];
        RELEASE_SAFE(_mapPinView);
    }
    [UIView commitAnimations];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE_SAFE(_mapPinView);
    [super dealloc];
}

@end
