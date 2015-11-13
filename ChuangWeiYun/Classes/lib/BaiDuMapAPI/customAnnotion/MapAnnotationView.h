//
//  MapAnnotationView.h
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "BMKAnnotationView.h"



@class MapViewCW;

@interface MapAnnotationView : BMKAnnotationView
{
    UIButton *_clickBtn;
    MapViewCW *_mapPinView;
}
@property(nonatomic,retain)UIButton *clickBtn;
-(void)start;
-(void)stop;
@end

@interface MapViewCW : UIView{
    CGFloat _radio;
    CGFloat _seperatorLength;
    NSTimer *timer;
}

-(void)startAnimation;
-(void)stopAnimation;
@end