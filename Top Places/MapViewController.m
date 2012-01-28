#import "MapViewController.h"

#define ZOOM_THRESHOLD 0.25

@interface MapViewController() 

typedef enum {
    ST_LOCATIONS,
    ST_PHOTOS
} MapVCState;

@property (nonatomic, assign) MapVCState state;

- (id<MKAnnotation>)annotationForPlace:(NSDictionary *)place;
- (void)fetchLocations;
- (void)addPlaceAnnotations;

@end

@implementation MapViewController
@synthesize mapView;

@synthesize state = _state;
@synthesize locations = _locations;

#define MAX_PHOTOS 50

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Map to image"])
    {
        id<MKAnnotation> annotation = [(MKAnnotationView *)sender annotation];
        
        NSAssert([annotation isKindOfClass:[PhotoAnnotation class]],@"ERROR");
        
        NSDictionary *photo = [(PhotoAnnotation *)annotation photo];  
        
        NSURL *photoURL = [FlickrFetcher urlForPhoto:photo 
                                              format:FlickrPhotoFormatLarge];
        
        [(ImageViewController *)segue.destinationViewController 
         setImageURL:photoURL];
    }
}

- (void)showLocation:(NSDictionary *)location
{
    
    NSArray *photosinLocation = 
    [FlickrFetcher photosInPlace:location maxResults:MAX_PHOTOS];
    
    CLLocationDegrees maxLatitude,minLatitude;
    CLLocationDegrees maxLongitude,minLongitude;
    
    maxLatitude=minLatitude = [[location objectForKey:@"latitude"] doubleValue];
    maxLongitude=minLongitude=[[location objectForKey:@"longitude"]doubleValue];
    
    for (NSDictionary *photo in photosinLocation)
    {
        [self.mapView addAnnotation:
         [[PhotoAnnotation alloc] initWithPhoto:photo]];
        
        if (maxLatitude < [[photo objectForKey:@"latitude"] doubleValue])
            maxLatitude = [[photo objectForKey:@"latitude"] doubleValue];
        
        if (minLatitude > [[photo objectForKey:@"latitude"] doubleValue])
            minLatitude = [[photo objectForKey:@"latitude"] doubleValue];
        
        if (maxLongitude < [[photo objectForKey:@"longitude"] doubleValue])
            maxLongitude = [[photo objectForKey:@"longitude"] doubleValue];
        
        if (minLongitude > [[photo objectForKey:@"longitude"] doubleValue])
            minLongitude = [[photo objectForKey:@"longitude"] doubleValue];
    }
    
    CLLocationCoordinate2D centerCoordinate = 
    CLLocationCoordinate2DMake((maxLatitude+minLatitude)/2.0, 
                               (maxLongitude+minLongitude)/2.0);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLatitude-minLatitude, 
                                                 maxLongitude-minLongitude);
        
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    
    self.state = ST_PHOTOS;
}

- (void)showCoordinateRegion:(MKCoordinateRegion)region
{
    self.mapView.region = region;
}

- (void)fetchLocations
{

    self.locations = [FlickrFetcher topPlaces];

}

- (id<MKAnnotation>)annotationForPlace:(NSDictionary *)place
{
    return [[PlaceAnnotation alloc] initWithPlace:place];
}

- (id<MKAnnotation>)annotationForPhoto:(NSDictionary *)photo
{
    return [[PhotoAnnotation alloc] initWithPhoto:photo];
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
        
}

#pragma mark -
#pragma mark Target-action stuff

- (IBAction)photoCalloutButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"Map to image" 
                              sender:sender.superview.superview];
    // (We're passing the annotation view as sender.)
}

- (IBAction)placeCalloutButtonPressed:(UIButton *)sender
{
    NSLog(@"MapViewController placeCalloutButtonPressed:");
    
    id<MKAnnotation> annotation = 
    [(MKAnnotationView *)sender.superview.superview annotation];
    
    NSAssert([annotation isKindOfClass:[PlaceAnnotation class]],@"ERROR: ...");
    
    [self showLocation:[(PlaceAnnotation *)annotation place]];
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
    {
        if (self.state == ST_PHOTOS)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            [self addPlaceAnnotations];
        }
        
        self.state = ST_LOCATIONS;

    }
    else
    {
        if (self.state == ST_LOCATIONS)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            // Add photo pins.
            
        }
        
        self.state = ST_PHOTOS;
    }
    
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
#define THUMBNAIL_FRAME CGRectMake(0.0, 0.0, 32.0, 32.0)

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
                        
            UIButton *calloutButton = 
            [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            [calloutButton addTarget:self 
                              action:@selector(placeCalloutButtonPressed:) 
                    forControlEvents:UIControlEventTouchUpInside];
            
            pin.rightCalloutAccessoryView = calloutButton;
            
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
        pin=[self.mapView dequeueReusableAnnotationViewWithIdentifier:PHOTO_PIN];
        
        if (!pin)
        {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
                                                  reuseIdentifier:PHOTO_PIN];
            
            UIButton *calloutButton = 
            [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            [calloutButton addTarget:self 
                              action:@selector(photoCalloutButtonPressed:) 
                    forControlEvents:UIControlEventTouchUpInside];
            
            pin.rightCalloutAccessoryView = calloutButton;
            
            pin.leftCalloutAccessoryView = 
            [[UIImageView alloc] initWithFrame:THUMBNAIL_FRAME];
            
            pin.canShowCallout = YES;
            pin.enabled = YES;
        }
        
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
    
    if ([view.annotation isKindOfClass:[PhotoAnnotation class]])
    {
        UIImageView *thumbnailView=(UIImageView*)view.leftCalloutAccessoryView;
        
        dispatch_queue_t thumbnailDownloadQ = 
        dispatch_queue_create("thumbnail download queue", 0);
        
        dispatch_async(thumbnailDownloadQ, ^{
            NSDictionary *photo = 
            [(PhotoAnnotation *) view.annotation photo];
            
            NSURL *thumbnailURL = 
            [FlickrFetcher urlForPhoto:photo 
                                format:FlickrPhotoFormatSquare];
            
            UIImage *thumbnail = 
            [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailURL]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                thumbnailView.image = thumbnail;
            });
        });
        
    }
    
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
    
    if (!self.locations)
    {
        dispatch_queue_t locationDownloadQ = 
        dispatch_queue_create("location download queue", NULL);
        
        dispatch_async(locationDownloadQ, ^{
            self.locations = [FlickrFetcher topPlaces];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addPlaceAnnotations];
            });
        });
        
        dispatch_release(locationDownloadQ);
    }
        
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
