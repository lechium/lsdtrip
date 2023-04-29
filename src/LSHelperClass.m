#import "LSHelperClass.h"
#import "NSFileManager+size.h"
#import <objc/runtime.h>

#define FM [NSFileManager defaultManager]
#define FANCY_BYTES(B) [NSByteCountFormatter stringFromByteCount:B countStyle:NSByteCountFormatterCountStyleFile]

@interface NSObject (lazy)
- (id)diskUsage; //_LSDiskUsage
- (id)dynamicUsage;
@end

@interface LSApplicationProxy : NSObject

@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSURL * containerURL;
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSString * bundleType;                                                                 //@synthesize bundleType=_bundleType - In the implementation block
@property (nonatomic,readonly) NSString * localizedShortName;

- (BOOL)isContainerized;
- (id)staticDiskUsage;
- (id)dynamicDiskUsage;
+ (id)applicationProxyForItemID:(id)arg1;    // IMP=0x0000000000019eca
+ (id)applicationProxyForBundleURL:(id)arg1;    // IMP=0x0000000000019e9e
+ (id)applicationProxyForSystemPlaceholder:(id)arg1;    // IMP=0x0000000000019d9b
+ (id)applicationProxyForCompanionIdentifier:(id)arg1;    // IMP=0x0000000000019d3f
+ (id)applicationProxyForIdentifier:(id)arg1 placeholder:(_Bool)arg2;    // IMP=0x0000000000019d08
+ (id)applicationProxyForIdentifier:(id)arg1;

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

+ (NSNumber *)dynamicDiskUsageForProxy:(id)proxy {
    if ([proxy isContainerized]) {
        if ([proxy respondsToSelector:@selector(diskUsage)])
            return [[proxy diskUsage] dynamicUsage];
        else
            return [proxy dynamicDiskUsage];
    } else {
        NSString *container = [[self appContainerForIdentifier:[proxy bundleIdentifier]] path];
        if (container != nil){
            return [NSNumber numberWithUnsignedInteger:[NSFileManager sizeForFolderAtPath:container]];
        }
    }
    return 0;
}

+ (NSURL *)appContainerForIdentifier:(NSString *)identifier {
    id proxy = [LSApplicationProxy applicationProxyForIdentifier:identifier];
    NSString *newId = identifier; //make it possible to change it below if necessary
    if (proxy != nil) {
        NSURL *container = [proxy containerURL];
        if (container!=nil && ![container.path isEqualToString:@"/var/mobile"]) {
            return [proxy containerURL];
        } else {
            newId = [proxy bundleIdentifier];
        }
    }
    NSDictionary *appDict = [self appContainerDictionary:false][newId];
    if (appDict) {
        return [NSURL fileURLWithPath:appDict[@"path"]];
    }
    return nil;
}

+ (NSDictionary *)appContainerDictionary:(BOOL)withSize {
    //NSDate *start = [NSDate date];
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
            NSDictionary *deets = nil;
            if (withSize) {
                NSUInteger bytes = [NSFileManager sizeForFolderAtPath:currentPath];
                deets = @{@"identifier": name,
                                        @"path": currentPath,
                                        @"modified": date,
                                        @"size": FANCY_BYTES(bytes)
                };
            } else {
                deets = @{@"identifier": name,
                                        @"path": currentPath,
                                        @"modified": date,
                };
            }
            
            newDicitionary[name] = deets;
            //[newArray addObject:deets];
        }
    }];
    //NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:start];
    return newDicitionary;
}


+ (id)defaultWorkspace {
    return [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
}

+ (BOOL)validBundleId:(NSString *)bundleId {
    return ([bundleId containsString:@"."]);
}

+ (id)smartProxyFromValue:(NSString *)value {
    if ([self validBundleId:value]) {
        return [LSApplicationProxy applicationProxyForIdentifier:value];
    }
    //if we get this far its not a 'valid' bundle id, so it should be a process name
    return [self proxyForProcessName:value];
}

+ (id)proxyForProcessName:(NSString *)processName {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"localizedName =[c] %@", processName];
    return [[[[self defaultWorkspace]allInstalledApplications] filteredArrayUsingPredicate:pred] firstObject];
}

+ (NSString *)bundleIDForProcessName:(NSString *)processName {
    id found = [self proxyForProcessName:processName];
    return [found bundleIdentifier];
}

@end
