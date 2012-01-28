#import "LocationPhotoTableViewController.h"

@implementation LocationPhotoTableViewController
@synthesize mapButton;

- (void)awakeFromNib
{
    self.cellId = @"Photo cell 1";
}

#define MAX_RESULTS 50

- (NSArray *)retrievePhotoList
{
    dispatch_queue_t photoListFetchingQueue = 
    dispatch_queue_create("photo list fetching queue", NULL);
    
    dispatch_async(photoListFetchingQueue, ^{
        if (self.photos)
            return;
        
        self.photos = [FlickrFetcher photosInPlace:self.place 
                                        maxResults:MAX_RESULTS];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    dispatch_release(photoListFetchingQueue);
    
    return nil;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.destinationViewController isKindOfClass:
         [ImageViewController class]])
    {
        NSDictionary *photo = [self.photos objectAtIndex:
                           [[self.tableView indexPathForCell:sender] row]];
    
        [self addPhotoToRecents:photo];
    }
    else if ([segue.destinationViewController isKindOfClass:
              [MapViewController class]])
    {
        [(MapViewController *)segue.destinationViewController 
         showLocation:self.place];
    }
    
    [super prepareForSegue:segue sender:sender];
}

- (void)viewDidUnload 
{
    [self setMapButton:nil];
    
    [super viewDidUnload];
}


@end
