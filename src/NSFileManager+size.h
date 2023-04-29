#import <Foundation/Foundation.h>

@interface NSFileManager(Util)

+ (NSUInteger)sizeForFolderAtPath:(NSString *)source;
+ (CGFloat)availableSpaceForPath:(NSString *)source;
+ (void)ls:(const char *)name completion:(void(^)(NSInteger size, NSInteger count))block;
- (NSNumber *)sizeForFolderAtPath:(NSString *)source error:(NSError **)error;

@end
