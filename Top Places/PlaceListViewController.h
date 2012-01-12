#import <UIKit/UIKit.h>

#import "FlickrFetcher.h"
#import "LocationPhotoTableViewController.h"

@interface PlaceListViewController : UITableViewController

@property (nonatomic,strong) NSDictionary *places;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)refresh:(id)sender;

@end
