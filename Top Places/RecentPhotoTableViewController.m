#import "RecentPhotoTableViewController.h"

@implementation RecentPhotoTableViewController

- (void)awakeFromNib
{
    self.cellId = @"Photo cell 2";
}

- (NSArray *)retrievePhotoList
{
    self.photos=[[[NSUserDefaults standardUserDefaults] 
                  arrayForKey:@"recents"] copy];
    
    return self.photos;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

@end
