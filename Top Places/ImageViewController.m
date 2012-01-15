//
//  ImageViewController.m
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageViewController

@synthesize imageView = _imageView;
@synthesize imageURL = _imageURL;
@synthesize scrollView = _scrollView;
           
- (void)loadImage
{
    if (self.imageView) {
        if (self.imageURL) {
            dispatch_queue_t imageDownloadQ = dispatch_queue_create("ShutterbugViewController image downloader", NULL);
            dispatch_async(imageDownloadQ, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                    
                    CGSize imageSize = image.size;
                    CGSize viewSize = self.view.bounds.size;
                    
                    CGFloat xScale=viewSize.width/imageSize.width;
                    CGFloat yScale=viewSize.height/imageSize.height;
                    
                    self.scrollView.minimumZoomScale = MIN(xScale,yScale);
                    
                    self.scrollView.contentSize = imageSize;
                    
                    self.imageView.frame = 
                    CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
                    
                    self.scrollView.zoomScale = MAX(xScale,yScale);
                });
            });
            dispatch_release(imageDownloadQ);
        } else {
            self.imageView.image = nil;
        }
    }
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

- (void)awakeFromNib
{
    self.scrollView.delegate = self;
    
    self.scrollView.maximumZoomScale = 1/[[UIScreen mainScreen] scale];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.imageView.image && self.imageURL) [self loadImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    self.imageView = nil;
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
    return self.imageView;
}

@end
