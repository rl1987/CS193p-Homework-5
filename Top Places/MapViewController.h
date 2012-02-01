#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "FlickrFetcher.h"
#import "PlaceAnnotation.h"
#import "PhotoAnnotation.h"
#import "ImageViewController.h"

// Standalone class that displays geographical information on the map.
@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic,strong) NSArray *locations;

- (IBAction)placeCalloutButtonPressed:(id)sender;
- (IBAction)photoCalloutButtonPressed:(id)sender;
- (IBAction)modeChanged:(UISegmentedControl *)sender;

- (void)showLocation:(NSDictionary *)location;
- (void)showCoordinateRegion:(MKCoordinateRegion)region;

@end
