

#import <Foundation/Foundation.h>
#import "BMapKit.h"

@interface CurrentLocationAnnotation : NSObject <BMKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
    NSString *imageUrl;
    int index;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *imgaeUrl;
@property (nonatomic, assign) int index;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)title andSubtitle:(NSString *)subTitle andImage:(NSString *)imgUrl;

@end
