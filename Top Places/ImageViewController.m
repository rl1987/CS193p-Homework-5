#import "ImageViewController.h"

@interface ImageViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (NSString *)imageId;
- (void)cacheImage;

@end

@implementation ImageViewController

@synthesize imageView = _imageView;
@synthesize imageURL = _imageURL;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize toolbar = _toolbar;
     
#pragma mark -
#pragma mark Caching related methods

#define CACHE_COST_LIMIT 10*1024*1024 // 10 MB

- (void)cacheImage
{
    NSLog(@"ImageViewController cacheImage");
    
    if (!self.imageView.image)
        return;
    
    NSString *photoId = [self imageId];
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    
    NSUInteger imageDataSize = [imageData length];
   
    NSFileManager *fileman = [NSFileManager defaultManager];
    
    NSString *cacheDirectoryPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, 
                                         YES) objectAtIndex:0];
    
    NSMutableArray *preexistingCachedFiles = 
    [[fileman contentsOfDirectoryAtPath:cacheDirectoryPath 
                                 error:nil] mutableCopy];    
    
    NSMutableDictionary *fileAttributes = [[NSMutableDictionary alloc] init];
    
    NSUInteger cacheSize = 0;
    
    for (NSString *filename in preexistingCachedFiles)
    {
        NSString *filePath = 
        [cacheDirectoryPath stringByAppendingPathComponent:filename];
        
        NSDictionary *attributeDict = [fileman attributesOfItemAtPath:filePath
                                                                error:nil];
        cacheSize += [[attributeDict objectForKey:NSFileSize] integerValue];
        
        [fileAttributes setObject:attributeDict                                                            
                           forKey:filename];
    }
    
    preexistingCachedFiles = 
    [[fileAttributes keysSortedByValueUsingComparator:
     ^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1;
        NSDate *date2;
        
        date1 = [(NSDictionary *)obj1 objectForKey:NSFileCreationDate];
        date2 = [(NSDictionary *)obj2 objectForKey:NSFileCreationDate];
        
        return [date1 compare:date2];        
    }] mutableCopy];
    
    while (imageDataSize + cacheSize >= CACHE_COST_LIMIT)
    {
        if ([preexistingCachedFiles count] == 0)
            break;
        
        NSString *filename = [preexistingCachedFiles objectAtIndex:0];
        
        [preexistingCachedFiles removeObjectAtIndex:0];
        
        cacheSize -= [[[fileAttributes objectForKey:filename] 
                       objectForKey:NSFileSize] integerValue];        
        
        [fileAttributes removeObjectForKey:filename];
        
        NSString *filePath = 
        [cacheDirectoryPath stringByAppendingPathComponent:filename];
        
        [fileman removeItemAtPath:filePath 
                            error:nil];
    }
    
    cacheSize += imageDataSize;
    
    NSLog(@"%d",cacheSize);
    
    NSString *filePath = 
    [cacheDirectoryPath stringByAppendingPathComponent:
     [photoId stringByAppendingString:@".jpg"]];
    
    [fileman createFileAtPath:filePath 
                     contents:imageData
                   attributes:nil];       

}

- (NSString *)imageId
{
    NSString *imageId = @"";
    
    NSArray *urlComponents = 
    [[self.imageURL description] componentsSeparatedByString:@"/"];
    
    if ([urlComponents lastObject])
    {
        NSString *filename = [urlComponents lastObject];
        
        if ([[filename componentsSeparatedByString:@"_"] count])
            imageId = [[filename componentsSeparatedByString:@"_"] 
                       objectAtIndex:0];
    }
    
    return imageId;
}

#pragma mark -
#pragma mark Image view related stuff

- (void)positionImage:(UIImage *)image 
     insideScrollview:(UIScrollView *)scrollView
{
    self.imageView.image = image;
        
    CGSize imageSize = image.size;
    CGSize viewSize = scrollView.bounds.size;
    
    CGFloat xScale=viewSize.width/imageSize.width;
    CGFloat yScale=viewSize.height/imageSize.height;
    
    scrollView.minimumZoomScale = MIN(xScale,yScale);
    
    self.imageView.frame = 
    CGRectMake(0.0, 0.0, scrollView.zoomScale*imageSize.width, 
               scrollView.zoomScale*imageSize.height);    
    
    scrollView.contentSize = self.imageView.frame.size;
    
    scrollView.zoomScale = MAX(xScale,yScale);
    
    [scrollView flashScrollIndicators];

}

- (void)loadImage
{
    if (!self.imageView) 
        return;
    
    if (!self.imageURL) 
    {
        self.imageView.image = nil;
        return;
    }
    
    [self.spinner startAnimating];
    
    dispatch_queue_t imageDownloadQ = 
    dispatch_queue_create("image download", NULL);
    
    dispatch_async(imageDownloadQ, ^{
        UIImage *image;
        
        NSFileManager *fileman = [NSFileManager defaultManager];
        
        NSString *cacheDirectoryPath = 
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                             NSUserDomainMask, 
                                             YES) objectAtIndex:0];
        
        NSString *filePath = 
        [cacheDirectoryPath stringByAppendingPathComponent:
         [[self imageId] stringByAppendingString:@".jpg"]];
        
        NSData *cachedData = [fileman contentsAtPath:filePath];
        
        if (cachedData)
            image = [UIImage imageWithData:cachedData];
        else
            image = [UIImage imageWithData:
                     [NSData dataWithContentsOfURL:self.imageURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self positionImage:image insideScrollview:self.scrollView];
            
            [self.spinner stopAnimating];
        });
    });
    
    dispatch_release(imageDownloadQ);    
}

- (void)setImageURL:(NSURL *)imageURL
{
    
    if (![_imageURL isEqual:imageURL]) {
        _imageURL = imageURL;
        if (self.imageView.window) {    // we're on screen, so update the image
            [self loadImage];           
        } else {                        // we're not on screen, so no need to loadImage (it will happen next viewWillAppear:)
            self.imageView.image = nil; // but image has changed (so we can't leave imageView.image the same, so set to nil)
        }
    }
}

#pragma mark -
#pragma mark Split view controller delegate

//Called when a button should be added to a toolbar for a hidden view controller
- (void)splitViewController: (UISplitViewController*)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem*)barButtonItem 
       forPopoverController: (UIPopoverController*)pc
{
    [self.toolbar setItems:[NSArray arrayWithObject:barButtonItem] 
                  animated:YES];
}

// Called when the view is shown again in the split view, invalidating the 
// button and popover controller
- (void)splitViewController: (UISplitViewController*)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.toolbar setItems:nil animated:YES];
}

// Returns YES if a view controller should be hidden by the split view 
// controller in a given orientation. (This method is only called on the 
// leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation  
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

#pragma mark -
#pragma mark View lifecycle

- (void)awakeFromNib
{
    if (self.splitViewController)
        self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    self.scrollView.maximumZoomScale = 1.0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.imageView.image && self.imageURL) 
        [self loadImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cacheImage];
    
    self.imageView.image = nil;
}

- (void)didRotateFromInterfaceOrientation:
(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self positionImage:self.imageView.image insideScrollview:self.scrollView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{

    self.imageView = nil;
    [self setScrollView:nil];
    [self setSpinner:nil];
    
    [self setToolbar:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    return self.imageView;
}

@end
