#import "LogicTests.h"

@implementation LogicTests

- (void)setUp
{
    [super setUp];

    cache = [[WritableCache alloc] init];
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSingleObject
{
    
    NSNumber *testNumber = [NSNumber numberWithInteger:4];
    
    [cache setObject:testNumber forKey:@"4"];
    
    STAssertEqualObjects(testNumber, [cache objectForKey:@"4"], 
                         @"caching failure");
    
}

- (void)testCostThresholding
{
    [cache removeAllObjects];
    
    [cache setTotalCostLimit:32];
    
    NSNumber *testNumber1 = [NSNumber numberWithInt:1];
    NSNumber *testNumber2 = [NSNumber numberWithInt:2];
    
    [cache setObject:testNumber1 forKey:@"1" cost:31];
    [cache setObject:testNumber2 forKey:@"2" cost:31];
    
    STAssertNotNil([cache objectForKey:@"2"], 
                   @"this object was supposed to be in the cache");
    
    STAssertNil([cache objectForKey:@"1"], 
                 @"this object was supposed to be evicted from cache");
    
}

#define CACHE_FILENAME @"cache1"

- (NSString *)cacheFilePath
{
    NSString *filePath =    
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                         NSUserDomainMask,
                                         YES) lastObject];
    
    filePath = [filePath stringByAppendingPathComponent:CACHE_FILENAME];
    
    return filePath;
}

- (void)testWritability
{

    [cache removeAllObjects];
    
    NSString *testString = @"test test test";
    
    [cache setObject:testString forKey:@"t"];
    
    BOOL success = 
    [NSKeyedArchiver archiveRootObject:cache toFile:[self cacheFilePath]];
    
    STAssertTrue(success, @"file writing failure");
    
    WritableCache *cache2 = 
    [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilePath]];
    
    STAssertNotNil(cache2, @"failed to read cache file");
    
    STAssertEqualObjects([cache objectForKey:@"t"],[cache2 objectForKey:@"t"],
                         @"cached objects not surviving filesystem i/o");
                    
    
}

@end
