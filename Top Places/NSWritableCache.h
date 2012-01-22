#import <Foundation/Foundation.h>

@interface NSWritableCache : NSCache <NSCoding>
{
@private
    NSMutableDictionary *_costsAndKeys;
}

@end
