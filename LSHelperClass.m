#import "LSHelperClass.h"
#import <objc/runtime.h>

#define FM [NSFileManager defaultManager]

@interface LSApplicationProxy : NSObject

@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSString * bundleType;                                                                 //@synthesize bundleType=_bundleType - In the implementation block
@property (nonatomic,readonly) NSString * localizedShortName;
@end


@interface LSApplicationWorkspace: NSObject

-(id)allInstalledApplications;
- (NSArray *)applicationsOfType:(unsigned long long)arg1 ;
- (id)allApplications;
-(id)placeholderApplications;
-(id)unrestrictedApplications;
- (void)openApplicationWithBundleID:(NSString *)string;
+ (id)defaultWorkspace;
-(BOOL)uninstallApplication:(id)arg1 withOptions:(id)arg2;

@end

@implementation LSHelperClass

+ (NSString *)appContainerForIdentifier:(NSString *)identifier {
    NSDictionary *appDict = [self appContainerDictionary][identifier];
    return appDict[@"path"];
}

+ (NSDictionary *)appContainerDictionary {
    __block NSMutableDictionary *newDicitionary = [NSMutableDictionary new];
    NSString *path = @"/var/mobile/Containers/Data/Application";
    NSArray *contents = [FM contentsOfDirectoryAtPath:path error:nil];
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentPath = [path stringByAppendingPathComponent:obj];
        NSDictionary *attrs = [FM attributesOfItemAtPath:currentPath error:nil];
        NSDate *date = attrs[NSFileModificationDate];
        NSString *metaPath = [currentPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        if ([FM fileExistsAtPath:metaPath]){
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:metaPath];
            NSString *name = dict[@"MCMMetadataIdentifier"];
            NSDictionary *deets = @{@"identifier": name,
                      @"path": currentPath,
                      @"modified": date,
            };
            
            
            newDicitionary[name] = deets;
        }
    }];
    return newDicitionary;
}

+ (id)defaultWorkspace {
    return [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
}

+ (BOOL)validBundleId:(NSString *)bundleId {
    return ([[bundleId componentsSeparatedByString:@"."] count] > 1);
}

+ (id)proxyForProcessName:(NSString *)processName {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"bundleExecutable =[c] %@", processName];
    return [[[[self defaultWorkspace]allInstalledApplications] filteredArrayUsingPredicate:pred] firstObject];
}

+ (NSString *)bundleIDForProcessName:(NSString *)processName {
    id found = [self proxyForProcessName:processName];
    return [found bundleIdentifier];
}

@end
