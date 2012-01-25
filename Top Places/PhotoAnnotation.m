#import "PhotoAnnotation.h"

@implementation PhotoAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;

- (id)initWithPhoto:(NSDictionary *)photo
{
    
    self = [super init];
    
    if (self)
    {
        _title = [photo objectForKey:@"title"];
        _subtitle = [photo valueForKeyPath:@"description._content"];
        
        CLLocationDegrees latitude = [[photo objectForKey:@"latitude"] 
                                      doubleValue];
        
        CLLocationDegrees longitude = [[photo objectForKey:@"longitude"] 
                                       doubleValue];
        
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    
    return self;    
}

@end
