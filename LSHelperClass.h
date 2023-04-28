#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSHelperClass : NSObject
+ (id)proxyForProcessName:(NSString *)processName;
+ (NSString *)bundleIDForProcessName:(NSString *)processName;
+ (NSString *)appContainerForIdentifier:(NSString *)identifier;
+ (BOOL)validBundleId:(NSString *)bundleId;
@end

NS_ASSUME_NONNULL_END
