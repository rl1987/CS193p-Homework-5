#import "PhotoAnnotation.h"

@implementation PhotoAnnotation

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;
@synthesize photo = _photo;

- (id)initWithPhoto:(NSDictionary *)photo
{
    
    self = [super init];
    
    if (self)
    {
        _title = [photo objectForKey:@"title"];
        
        if ([_title length]==0)
            _title = @"Unknown";
        
        _subtitle = [photo valueForKeyPath:@"description._content"];
        
        CLLocationDegrees latitude = [[photo objectForKey:@"latitude"] 
                                      doubleValue];
        
        CLLocationDegrees longitude = [[photo objectForKey:@"longitude"] 
                                       doubleValue];
        
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        _photo = photo;
    }
    
    return self;    
}

@end
