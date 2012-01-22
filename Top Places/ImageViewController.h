//
//  ImageViewController.h
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSWritableCache.h"

@interface ImageViewController : UIViewController 
<UIScrollViewDelegate, NSCacheDelegate>

@property (nonatomic, strong) NSURL *imageURL;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

+ (NSWritableCache *)defaultCache;
+ (void)setDefaultCache:(NSWritableCache *)cache;

@end
