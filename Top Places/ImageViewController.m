#import "ImageViewController.h"

static NSWritableCache *_cache = nil;

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
     
#pragma mark -
#pragma mark Caching related methods

+ (NSWritableCache *)defaultCache
{
    if (_cache == nil)
    {
        _cache = [[NSWritableCache alloc] init];
        
        [_cache setTotalCostLimit:10*1024*1024]; // 10 MB
        
        [_cache setCountLimit:0]; // Number of cached photos is
                                  // unlimited, as long as they
                                  // don't take 10 MB of space.
    }
    
    return _cache;
}

+ (void)setDefaultCache:(NSWritableCache *)cache
{
    _cache = cache;
}

- (void)cacheImage
{
    if (!self.imageView.image)
        return;
    
    NSString *photoId = [self imageId];
     
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    
    [[ImageViewController defaultCache] setObject:imageData 
                                           forKey:photoId 
                                             cost:[imageData length]];
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
    
    scrollView.zoomScale = MAX(xScale,yScale);
    
    self.imageView.frame = 
    CGRectMake(0.0, 0.0, scrollView.zoomScale*imageSize.width, 
               scrollView.zoomScale*imageSize.height);    
    
    scrollView.contentSize = self.imageView.frame.size; //imageSize
    
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
    dispatch_queue_create("ShutterbugViewController image downloader", NULL);
    
    dispatch_async(imageDownloadQ, ^{
        UIImage *image;
        
        NSData *cachedData = 
        [[ImageViewController defaultCache] objectForKey:[self imageId]];
        
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
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    self.scrollView.maximumZoomScale = 1/[[UIScreen mainScreen] scale];
    
    [[ImageViewController defaultCache] setDelegate:self];
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
    
//    NSLog(@"ImageViewController didRotateFromInterfaceOrientation:");
//    
//    NSLog(@"width = %g , height = %g",self.view.bounds.size.width,
//          self.view.bounds.size.height);
    
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
    
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    return self.imageView;
}

@end
