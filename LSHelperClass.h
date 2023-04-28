#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSHelperClass : NSObject
+ (id)proxyForProcessName:(NSString *)processName;
+ (NSString *)bundleIDForProcessName:(NSString *)processName;
+ (NSURL *)appContainerForIdentifier:(NSString *)identifier;
+ (id)smartProxyFromValue:(NSString *)value;
+ (BOOL)validBundleId:(NSString *)bundleId;
+ (NSNumber *)dynamicDiskUsageForProxy:(id)proxy;
@end

NS_ASSUME_NONNULL_END
