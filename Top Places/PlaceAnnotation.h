#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

- (id)initWithPlace:(NSDictionary *)place;

@end
