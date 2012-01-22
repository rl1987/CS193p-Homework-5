#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

#define CACHE_FILENAME @"cache"

- (NSString *)cacheFilePath
{
    NSString *filePath =    
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                         NSUserDomainMask,
                                         YES) lastObject];
    
    filePath = [filePath stringByAppendingPathComponent:CACHE_FILENAME];
    
    return filePath;
}

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [ImageViewController setDefaultCache:
     [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilePath]]];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    NSLog(@"AppDelegate applicationWillTerminate:");
    
    BOOL success =    
    [NSKeyedArchiver archiveRootObject:[ImageViewController defaultCache] 
                                toFile:[self cacheFilePath]];
    
    if (success)
        NSLog(@"1");
    else
        NSLog(@"0");
    
}

@end
