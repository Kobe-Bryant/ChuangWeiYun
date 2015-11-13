//
//  MapAnnotation.h
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
@interface MapAnnotation : NSObject <BMKAnnotation> 

{
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    NSString *title;
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoord;
- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude andTitle:(NSString *)titles;

@end
