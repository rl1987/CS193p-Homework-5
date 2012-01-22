#import "NSWritableCache.h"

@implementation NSWritableCache

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)g
{
    if (_costsAndKeys)
        _costsAndKeys = [[NSMutableDictionary alloc] init];

    [_costsAndKeys setObject:[NSNumber numberWithInteger:g] 
                      forKey:key];
    
    [super setObject:obj forKey:key cost:g];
}

- (void)setObject:(id)obj forKey:(id)key
{
    if (_costsAndKeys)
        _costsAndKeys = [[NSMutableDictionary alloc] init];
    
    [_costsAndKeys setObject:[NSNumber numberWithInt:0] 
                      forKey:key];    
    
    [super setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [_costsAndKeys removeObjectForKey:key];
    
    [super removeObjectForKey:key];
}

- (void)removeAllObjects
{
    _costsAndKeys = nil;
    
    [super removeAllObjects];
}

#pragma mark -
#pragma mark NSCoding methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (id key in [_costsAndKeys allKeys])
    {
        NSArray *element = [NSArray arrayWithObjects:[self objectForKey:key], 
                            [_costsAndKeys objectForKey:key],nil];
        
        [dict setObject:element forKey:key];
    }
    
    [aCoder encodeObject:dict];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *dict = [aDecoder decodeObject];
    
    self = [super init];
    
    if (self)
    {
        for (id key in dict)
        {
            NSArray *element = [dict objectForKey:key];
            
            [self setObject:[element objectAtIndex:0] 
                     forKey:key 
                       cost:[(NSNumber *)[element objectAtIndex:1] 
                             integerValue]];
        }
        
    }
    
    return self;
    
}

@end
