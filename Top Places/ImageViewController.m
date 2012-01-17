//
//  ImageViewController.m
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

static NSCache *_cache = nil;
static NSMutableArray *_imageIds = nil;
static NSMutableDictionary *_cachedData = nil;
/* (Keys are hashes of cached data, objects are imaged IDs.) */

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
          
- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSUInteger hash = [obj hash];
    
    [_cachedData removeObjectForKey:[NSNumber numberWithInteger:hash]];
}

+ (NSCache *)defaultCache
{
    if (_cache == nil)
    {
        _cache = [[NSCache alloc] init];
        
        [_cache setTotalCostLimit:10*1024*1024]; // 10 MB
        
        [_cache setCountLimit:0]; // Number of cached photos is
                                  // unlimited, as long as they
                                  // don't take 10 MB of space.
    }
    
    return _cache;
}

+ (void)setDefaultCache:(NSCache *)cache
{
    _cache = cache;
}

- (void)cacheImage
{
    NSString *photoId = [self imageId];
    
    if (!_cachedData)
        _cachedData = [NSMutableDictionary dictionary];
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    
    [_cachedData setObject:photoId 
                    forKey:[NSNumber numberWithInteger:[imageData hash]]];
    
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
    
    NSLog(@"ImageViewController imageId");
    NSLog(@"%@",imageId);
    
    return imageId;
}

- (void)positionImage:(UIImage *)image 
     insideScrollview:(UIScrollView *)scrollView
{
    self.imageView.image = image;
    
    CGSize imageSize = image.size;
    CGSize viewSize = scrollView.bounds.size;
    
    CGFloat xScale=viewSize.width/imageSize.width;
    CGFloat yScale=viewSize.height/imageSize.height;
    
    scrollView.minimumZoomScale = MIN(xScale,yScale);
    
    scrollView.contentSize = self.imageView.bounds.size; //imageSize;
    
    self.imageView.frame = 
    CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    
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
    NSLog(@"ImageViewController setImageURL:");
    NSLog(@"%@",imageURL);
    
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

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.scrollView.delegate = self;
    
    self.scrollView.maximumZoomScale = 1/[[UIScreen mainScreen] scale];
    
    [[ImageViewController defaultCache] setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.imageURL) [self loadImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cacheImage];
    
    self.imageURL = nil;
}
 
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation 
                                duration:(NSTimeInterval)duration
{
    NSLog(@"ImageViewController willRotateToInterfaceOrientation: duration:");
    
    NSLog(@"width = %g , height = %g",self.view.bounds.size.width,
          self.view.bounds.size.height);
}

- (void)didRotateFromInterfaceOrientation:
(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    NSLog(@"ImageViewController didRotateFromInterfaceOrientation:");
    
    NSLog(@"width = %g , height = %g",self.view.bounds.size.width,
          self.view.bounds.size.height);
    
    //[self loadImage];
    //[self positionImage:self.imageView.image insideScrollview:self.scrollView];
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
