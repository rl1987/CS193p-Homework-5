#import "PlaceListViewController.h"

@implementation PlaceListViewController

@synthesize places = _places;
@synthesize refreshButton = _refreshButton;

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh:self.navigationItem.leftBarButtonItem];
}

- (void)viewDidUnload {
    [self setRefreshButton:nil];
    
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.places count];
}

- (NSArray *)placesInCountry:(NSInteger)countryIndex
{

    NSArray *sortedKeys = [[self.places allKeys] sortedArrayUsingSelector:
                           @selector(compare:)];
    
    return [self.places objectForKey:[sortedKeys objectAtIndex:countryIndex]];
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section
{
    NSArray *countries = [[self.places allKeys] sortedArrayUsingSelector:
                           @selector(compare:)];

    return [countries objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return [[self placesInCountry:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place cell";
    
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    
    NSDictionary *place = [[self placesInCountry:[indexPath section]] 
                           objectAtIndex:[indexPath row]];
    
    NSArray *placenames = [[place objectForKey:@"_content"] 
                           componentsSeparatedByString:@", "];
    
    cell.textLabel.text = [placenames objectAtIndex:0];
    
    NSString *subtitle = @"Unknown";
    
    if ([placenames count]>=2)
        subtitle = [placenames objectAtIndex:1];
    
    if ([placenames count]>=3)
        subtitle = [NSString stringWithFormat:@"%@, %@",subtitle,
                    [placenames objectAtIndex:2]];
    
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.destinationViewController 
         isKindOfClass:[LocationPhotoTableViewController class]])
    {
        LocationPhotoTableViewController *dvc = segue.destinationViewController;
        
        NSIndexPath *placeIndex = [self.tableView indexPathForCell:sender];
        
        NSDictionary *thePlace = [[self placesInCountry:[placeIndex section]] 
                                  objectAtIndex:[placeIndex row]];
        
        [dvc setPlace:thePlace];
        
        dvc.navigationItem.title = [[(UITableViewCell *)sender textLabel] text];        
    }
    else if ([segue.destinationViewController 
              isKindOfClass:[MapViewController class]])
    {
        MapViewController *mvc = segue.destinationViewController;
        
        NSMutableArray *locations = [NSMutableArray array];
        
        for (id country in [self.places allKeys])
            [locations addObjectsFromArray:[self.places objectForKey:country]];
        
        mvc.locations = locations;
    }  
    
}

#pragma mark -
#pragma mark Target-action stuff

- (IBAction)refresh:(id)sender 
{
    dispatch_queue_t locationFetchingQueue = 
    dispatch_queue_create("location fetching queue", NULL);
        
    UIActivityIndicatorView *refreshSpinner =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
     UIActivityIndicatorViewStyleGray];
    
    [refreshSpinner startAnimating];
    
    self.navigationItem.leftBarButtonItem = 
    [[UIBarButtonItem alloc] initWithCustomView:refreshSpinner];
    
    dispatch_async(locationFetchingQueue, ^{
        NSArray *fetchResults = [FlickrFetcher topPlaces];
        
        NSMutableDictionary *places = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *f in fetchResults)
        {
            NSString *country;
            
            NSArray *placenames = [[f objectForKey:@"_content"] 
                                   componentsSeparatedByString:@", "];
            
            if ([placenames count]>=2)
                country = [placenames lastObject];
            else
                country = @"Unknown";
            
            if (![places objectForKey:country])
                [places setObject:[NSMutableArray array] forKey:country];
            
            [[places objectForKey:country] addObject:f];
            
        }
        
        self.places = places;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshSpinner stopAnimating];
            self.navigationItem.leftBarButtonItem = sender;
            
            [self.tableView reloadData];
        });
        
    });
    
    dispatch_release(locationFetchingQueue);
    
}

@end
