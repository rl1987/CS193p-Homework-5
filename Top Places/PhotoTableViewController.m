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
    NSString *subtitle = [photo valueForKeyPath:@"description._content"]; 
    
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
    
    dispatch_queue_t q = dispatch_queue_create("thumbnail download queue", 0);
    
    dispatch_async(q, ^{
        NSURL *thumbnailURL = 
        [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        
        UIImage *thumbnail = [UIImage imageWithData:
                              [NSData dataWithContentsOfURL:thumbnailURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = thumbnail;
            
            [cell setNeedsLayout];
        });
                            
    });
    
    dispatch_release(q);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != 
        UIUserInterfaceIdiomPad)
        return;
    
    NSDictionary *photo = [self.photos objectAtIndex:[indexPath row]];
    
    NSURL *photoURL = 
    [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    
    ImageViewController *ivc = 
    (ImageViewController *) [[self.splitViewController viewControllers] 
                             lastObject];
    
    [ivc setImageURL:photoURL];
    
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.destinationViewController 
          isKindOfClass:[ImageViewController class]])
        return;
        
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
