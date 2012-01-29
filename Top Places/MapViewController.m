#import "MapViewController.h"

#define ZOOM_THRESHOLD 0.25

@interface MapViewController() 

typedef enum {
    ST_LOCATIONS,
    ST_PHOTOS,
    ST_TRANSIENT
} MapVCState;

@property (nonatomic, assign) MapVCState state;

- (id<MKAnnotation>)annotationForPlace:(NSDictionary *)place;
- (NSArray *)placesFittingToCoordinateRegion:(MKCoordinateRegion)region;
- (void)addPhotoAnnotationsForPlace:(NSDictionary *)place;
- (void)fetchLocations;
- (void)addPlaceAnnotations;

@end

@implementation MapViewController

@synthesize mapView;

@synthesize state = _state;
@synthesize locations = _locations;

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
        
        [[(ImageViewController *)segue.destinationViewController navigationItem] 
         setTitle:annotation.title];
    }
}

#define MAX_PHOTOS 50

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

- (NSArray *)placesFittingToCoordinateRegion:(MKCoordinateRegion)region
{
    NSMutableArray *placesThatFit = [[NSMutableArray alloc] init];
    
    CLLocationDegrees maxLatitude = 
    region.center.latitude + region.span.latitudeDelta/2.0;
    CLLocationDegrees minLatitude = 
    region.center.latitude - region.span.latitudeDelta/2.0;
    CLLocationDegrees maxLongitude = 
    region.center.longitude + region.span.longitudeDelta/2.0;
    CLLocationDegrees minLongitude = 
    region.center.longitude - region.span.longitudeDelta/2.0;
    
    for (NSDictionary *place in self.locations)
    {
        CLLocationDegrees latitude = [[place objectForKey:@"latitude"] 
                                      doubleValue];
        CLLocationDegrees longitude = [[place objectForKey:@"longitude"] 
                                       doubleValue];
        
        if ( (latitude < maxLatitude) && (latitude > minLatitude) &&
             (longitude < maxLongitude) && (longitude > minLongitude) )
            [placesThatFit addObject:place];
    }
    
    return [placesThatFit copy];
}

- (void)addPhotoAnnotationsForPlace:(NSDictionary *)place
{
    NSArray *photos = [FlickrFetcher photosInPlace:place maxResults:MAX_PHOTOS];
    
    for (NSDictionary *photo in photos)
        [self.mapView addAnnotation:
         [[PhotoAnnotation alloc] initWithPhoto:photo]];
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
                       
#define MAX_RECENT_PHOTOS 20

- (void)addPhotoToRecents:(NSDictionary *)photo
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *recents = [[defaults arrayForKey:@"recents"] mutableCopy];
    
    if (!recents)
        recents = [[NSMutableArray alloc] init];
    
    if ([recents indexOfObject:photo] == NSNotFound)
        [recents insertObject:photo atIndex:0];
    
    if ([recents count] >= MAX_RECENT_PHOTOS)
        [recents removeLastObject];
    
    [defaults setObject:[recents copy] forKey:@"recents"];
    
    [defaults synchronize];
    
}

#pragma mark -
#pragma mark Target-action stuff

- (IBAction)photoCalloutButtonPressed:(UIButton *)sender
{
    
    MKAnnotationView *av = (MKAnnotationView *)sender.superview.superview;
    
    [self performSegueWithIdentifier:@"Map to image" 
                              sender:av];
    
    [self addPhotoToRecents:[(PhotoAnnotation *)av.annotation photo]];
}

- (IBAction)placeCalloutButtonPressed:(UIButton *)sender
{
    NSLog(@"MapViewController placeCalloutButtonPressed:");
    
//    id<MKAnnotation> annotation = 
//    [(MKAnnotationView *)sender.superview.superview annotation];
//    
//    NSAssert([annotation isKindOfClass:[PlaceAnnotation class]],@"ERROR: ...");
//    
//    [self showLocation:[(PlaceAnnotation *)annotation place]];
    
}

#pragma mark -
#pragma mark Map view delegate

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
        if ((self.state == ST_LOCATIONS) || (self.state == ST_TRANSIENT))
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            NSArray *visiblePlaces = 
            [self placesFittingToCoordinateRegion:self.mapView.region];
            
            for (NSDictionary *vp in visiblePlaces)
                [self addPhotoAnnotationsForPlace:vp];
            
        }
        
        self.state = ST_PHOTOS;
    }
    
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

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.locations)
    {
        dispatch_queue_t locationDownloadQ = 
        dispatch_queue_create("location download queue", 0);
        
        dispatch_async(locationDownloadQ, ^{
            self.locations = [FlickrFetcher topPlaces];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addPlaceAnnotations];
            });
        });
        
        dispatch_release(locationDownloadQ);
    }
    else
        [self addPlaceAnnotations];
    
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
