#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

- (id)initWithPhoto:(NSDictionary *)photo;

@end
