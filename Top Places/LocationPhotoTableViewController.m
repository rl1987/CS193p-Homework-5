#import "LocationPhotoTableViewController.h"

@implementation LocationPhotoTableViewController

- (void)awakeFromNib
{
    self.cellId = @"Photo cell 1";
}

#define MAX_RESULTS 50

- (NSArray *)retrievePhotoList
{
    self.photos = [FlickrFetcher photosInPlace:self.place 
                                    maxResults:MAX_RESULTS];
    
    return self.photos;
}

#define MAX_RECENT_PHOTOS 50

- (void)addPhotoToRecents:(NSDictionary *)photo
{
    
    NSLog(@"PhotoTableViewController addPhotoToRecents:");
    
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
    
    NSLog(@"%@",recents);
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *photo = [self.photos objectAtIndex:
                           [[self.tableView indexPathForCell:sender] row]];
    
    [self addPhotoToRecents:photo];
    
    [super prepareForSegue:segue sender:sender];
}

@end
