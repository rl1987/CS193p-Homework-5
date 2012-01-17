//
//  ImageViewController.h
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController 
<UIScrollViewDelegate, NSCacheDelegate>

@property (nonatomic, strong) NSURL *imageURL;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

+ (NSCache *)defaultCache;
+ (void)setDefaultCache:(NSCache *)cache;

@end
