#import "MapViewController.h"

#define ZOOM_THRESHOLD 0.25

@interface MapViewController() 

typedef enum {
    ST_LOCATIONS,
    ST_PHOTOS
} MapVCState;

@property (nonatomic, assign) MapVCState state;

- (id<MKAnnotation>)annotationForPlace:(NSDictionary *)place;

@end

@implementation MapViewController
@synthesize mapView;

@synthesize state = _state;
@synthesize locations = _locations;

- (id<MKAnnotation>)annotationForPlace:(NSDictionary *)place
{
    return [[PlaceAnnotation alloc] initWithPlace:place];
}

- (void)addPlaceAnnotations
{
    if (!self.locations)
        return;
    
    for (NSDictionary *place in self.locations)
            [self.mapView addAnnotation:[self annotationForPlace:place]];
}

- (void)setState:(MapVCState)state
{
    if (_state == state)
        return;
    
    _state = state;
    
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (state == ST_LOCATIONS)
    {
        [self addPlaceAnnotations];
    }
    else
    {
        // ...
    }
}

#pragma mark -
#pragma mark Map view delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animate
{
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    if (MAX(self.mapView.region.span.latitudeDelta,
            self.mapView.region.span.longitudeDelta) > ZOOM_THRESHOLD) 
        self.state = ST_LOCATIONS;
    else
        self.state = ST_PHOTOS;
    
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    
}

#define PLACE_PIN @"Place annotation"
#define PHOTO_PIN @"Photo annotation"

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to 
// use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pin;
    
    if ([annotation isKindOfClass:[PlaceAnnotation class]])
    {
        pin=[self.mapView dequeueReusableAnnotationViewWithIdentifier:PLACE_PIN];
        
        if (!pin)
        {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                                                  reuseIdentifier:PLACE_PIN];
            
            pin.canShowCallout = YES;
            pin.enabled = YES;
        }
        else
        {
            [pin setAnnotation:annotation];
        }
    }
    else if ([annotation isKindOfClass:[PhotoAnnotation class]])
    {
        
    }
    
    return pin;
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when 
// the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view 
                      calloutAccessoryControlTapped:(UIControl *)control
{
    
}

- (void)mapView:(MKMapView *)mapView 
didSelectAnnotationView:(MKAnnotationView *)view 
{
    
}

- (void)mapView:(MKMapView *)mapView 
didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addPlaceAnnotations];
    
//    dispatch_queue_t locationDownloadQ = 
//    dispatch_queue_create("location download queue", NULL);
//    
//    dispatch_async(locationDownloadQ, ^{
//        self.locations = [FlickrFetcher topPlaces];
//        
//        self.state = ST_LOCATIONS;
//    });        
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    self.locations = nil;
    
    [super viewDidUnload];
}
@end
