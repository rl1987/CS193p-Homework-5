#import <UIKit/UIKit.h>

#import "FlickrFetcher.h"
#import "LocationPhotoTableViewController.h"
#import "MapViewController.h"

@interface PlaceListViewController : UITableViewController

@property (nonatomic,strong) NSMutableDictionary *places;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)refresh:(id)sender;

@end
