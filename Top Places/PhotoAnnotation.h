#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotoAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) NSDictionary *photo;

- (id)initWithPhoto:(NSDictionary *)photo;

@end
