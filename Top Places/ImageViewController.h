// Some code in this class was reused from Shutterbug. See:
// https://www.stanford.edu/class/cs193p/cgi-bin/drupal/node/281

#import <UIKit/UIKit.h>

#import "NSWritableCache.h"

@interface ImageViewController : UIViewController 
<UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) NSURL *imageURL;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

+ (NSWritableCache *)defaultCache;
+ (void)setDefaultCache:(NSWritableCache *)cache;

@end
