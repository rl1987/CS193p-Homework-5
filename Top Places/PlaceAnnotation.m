#import "PlaceAnnotation.h"

@implementation PlaceAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize place = _place;

- (id)initWithPlace:(NSDictionary *)place
{
    
    self = [super init];
    
    if (self)
    {
        NSArray *placenames = [[place objectForKey:@"_content"] 
                               componentsSeparatedByString:@", "];
        
        _title = [[placenames objectAtIndex:0] copy];
        
        NSString *subtitle = @"Unknown";
        
        if ([placenames count]>=2)
            subtitle = [placenames objectAtIndex:1];
        
        if ([placenames count]>=3)
            subtitle = [NSString stringWithFormat:@"%@, %@",subtitle,
                        [placenames objectAtIndex:2]];
        
        _subtitle = [subtitle copy];
        
        CLLocationDegrees latitude = [[place objectForKey:@"latitude"] 
                                      doubleValue];
        
        CLLocationDegrees longitude = [[place objectForKey:@"longitude"] 
                                       doubleValue];
        
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        _place = place;        
    }
    
    return self;
}

@end
