#import <Foundation/Foundation.h>

@interface LSFindProcess : NSObject
+ (NSString *)processNameFromPID:(pid_t)ppid;
+ (pid_t) find_process:(const char*) name;
@end


