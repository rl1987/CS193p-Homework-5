#import "PlaceListViewController.h"


@implementation PlaceListViewController

@synthesize places = _places;

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //self.places = 
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSAssert([sender isKindOfClass:[UITableViewCell class]],
             @"ERROR: Class mismatch 1");
    
    NSAssert([segue.destinationViewController 
              isKindOfClass:[LocationPhotoTableViewController class]],
             @"ERROR: Class mismatch 2");
    
    if (![segue.destinationViewController 
         respondsToSelector:@selector(setPlace:)])
        return;
    
    NSIndexPath *placeIndex = [self.tableView indexPathForCell:sender];
    
    NSDictionary *thePlace = [[self placesInCountry:[placeIndex section]] 
                              objectAtIndex:[placeIndex row]];
    
    [(LocationPhotoTableViewController *) segue.destinationViewController 
     setPlace:thePlace];

}

@end
