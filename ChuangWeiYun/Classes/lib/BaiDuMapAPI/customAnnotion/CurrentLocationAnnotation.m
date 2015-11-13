

#import "CurrentLocationAnnotation.h"


@implementation CurrentLocationAnnotation

@synthesize coordinate, title, subtitle,index,imgaeUrl;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)atitle andSubtitle:(NSString *)subTitle andImage:(NSString *)imgUrl{
	self.coordinate = coord;
	self.title = atitle;
	self.subtitle = subTitle;
    self.imgaeUrl=imgUrl;
	return self;
}

- (void) dealloc {
	[title release],title = nil;
	[subtitle release],subtitle = nil;
    [imgaeUrl release],imgaeUrl=nil;
	[super dealloc];
}


@end
