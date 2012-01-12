#import "PhotoTableViewController.h"

@implementation PhotoTableViewController

@synthesize photos = _photos;
@synthesize place = _place;
@synthesize cellId = _cellId;

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSArray *)retrievePhotoList
{
    // set self.photos
    self.photos = nil;
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    [self retrievePhotoList];
        
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:self.cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:self.cellId];
    }
    
    NSDictionary *photo = [self.photos objectAtIndex:[indexPath row]];
    
    NSString *title = [photo objectForKey:@"title"];
    NSString *subtitle = [[photo objectForKey:@"description"] 
                          objectForKey:@"_content"];   
    
    if ([title length]==0)
    {
        if ([subtitle length]>0)
        {
            title = subtitle;
            subtitle = nil;
        }
        else
            title = @"Unknown";       
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"PhotoTableViewController prepareForSegue:");
    
    NSURL *picURL;
    
    NSAssert([sender isKindOfClass:[UITableViewCell class]],
             @"ERROR: Unexpected class");
    
    NSDictionary *photo = [self.photos objectAtIndex:
                           [[self.tableView indexPathForCell:sender] row]];
    
    picURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    
    [(ImageViewController *)segue.destinationViewController setImageURL:picURL];
    
    [[(ImageViewController *)segue.destinationViewController navigationItem] 
    setTitle:[[sender textLabel] text]]; 
    
}

@end
