#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) NSDictionary *place;

- (id)initWithPlace:(NSDictionary *)place;

@end
