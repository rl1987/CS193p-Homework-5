#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "FlickrFetcher.h"
#import "PlaceAnnotation.h"
#import "PhotoAnnotation.h"

// Standalone class that displays geographical information on the map.
@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic,strong) NSArray *locations;

@end
