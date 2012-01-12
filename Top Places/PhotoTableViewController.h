#import <UIKit/UIKit.h>

#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface PhotoTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) NSDictionary *place;
@property (nonatomic,strong) NSString *cellId;

@end
