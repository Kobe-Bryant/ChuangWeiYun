//
//  MapAnnotation.m
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize coordinate;
@synthesize title;

- (id)initWithLatitude:(CLLocationDegrees)latitude
andLongitude:(CLLocationDegrees)longitude andTitle:(NSString *)titles{
	if ((self = [super init])) {
		self.latitude = latitude;
		self.longitude = longitude;
        self.title = titles;
	}
	return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)inCoord
{
	coordinate = inCoord;
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coord;
	coord.latitude = self.latitude;
	coord.longitude = self.longitude;
	return coord;
}

@end
