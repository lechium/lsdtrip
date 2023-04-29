
#import "NSFileManager+size.h"
#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

@implementation NSFileManager(Util)

//https://stackoverflow.com/questions/50105231/how-do-i-recursively-go-through-folders-and-count-total-file-size

long long do_ls(const char *name) {
    DIR *dir_ptr;
    struct dirent *direntp;
    struct stat info;
    long long total = 0;
    if (stat(name, &info)) {
        fprintf(stderr, "ls01: cannot stat %s\n", name);
        return 0;
    }
    if (S_ISDIR(info.st_mode)) {
        if ((dir_ptr = opendir(name)) == NULL) {
            fprintf(stderr, "ls01: cannot open directory %s\n", name);
        } else {
            while ((direntp = readdir(dir_ptr)) != NULL) {
                char *pathname;
                
                /* ignore current and parent directories */
                if (!strcmp(direntp->d_name, ".") || !strcmp(direntp->d_name, ".."))
                    continue;
                
                pathname = malloc(strlen(name) + 1 + strlen(direntp->d_name) + 1);
                if (pathname == NULL) {
                    fprintf(stderr, "ls01: cannot allocated memory\n");
                    exit(1);
                }
                sprintf(pathname, "%s/%s", name, direntp->d_name);
                total += do_ls(pathname);
                free(pathname);
            }
            closedir(dir_ptr);
        }
    } else {
        total = info.st_size;
    }
    //printf("file count: %i\n", fileCount);
    //printf("%10lld  %s\n", total, name);
    return total;
}

//same code but with a completion block to offer a non-blocking solution

+ (void)ls:(const char *)name completion:(void(^)(NSInteger size, NSInteger count))block {
    DIR *dir_ptr;
    struct dirent *direntp;
    struct stat info;
    __block long long total = 0;
    __block int fileCount = 0;
    if (stat(name, &info)) {
        fprintf(stderr, "ls01: cannot stat %s\n", name);
        return;
    }
    if (S_ISDIR(info.st_mode)) {
        if ((dir_ptr = opendir(name)) == NULL) {
            fprintf(stderr, "ls01: cannot open directory %s\n", name);
        } else {
            while ((direntp = readdir(dir_ptr)) != NULL) {
                char *pathname;

                /* ignore current and parent directories */
                if (!strcmp(direntp->d_name, ".") || !strcmp(direntp->d_name, ".."))
                    continue;

                pathname = malloc(strlen(name) + 1 + strlen(direntp->d_name) + 1);
                if (pathname == NULL) {
                    fprintf(stderr, "ls01: cannot allocate memory\n");
                    exit(1);
                }
                sprintf(pathname, "%s/%s", name, direntp->d_name);
                [self ls:pathname completion:^(NSInteger size, NSInteger count) {
                    total+=size;
                    fileCount+=count;
                }];
                free(pathname);
            }
            closedir(dir_ptr);
        }
    } else {
        total = info.st_size;
        fileCount++;
    }
    //printf("file count: %i\n", fileCount);
    //printf("%10lld  %s\n", total, name);
    if (block) {
        block(total,fileCount);
    }
}

+ (NSUInteger)sizeForFolderAtPath:(NSString *)source {
    return do_ls([source UTF8String]);
}

+ (CGFloat)availableSpaceForPath:(NSString *)source {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:source error:&error];
    if (error) {
        //DLog(@"error: %@", error);
        attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"." error:&error];
    }
    return [[attrs objectForKey:NSFileSystemFreeSize] floatValue];
}

- (NSNumber *)sizeForFolderAtPath:(NSString *) source error:(NSError **)error
{
    NSArray * contents;
    unsigned long long size = 0;
    NSEnumerator * enumerator;
    NSString * path;
    BOOL isDirectory;
    
    // Determine Paths to Add
    if ([self fileExistsAtPath:source isDirectory:&isDirectory] && isDirectory)
    {
        contents = [self subpathsAtPath:source];
    }
    else
    {
        contents = [NSArray array];
    }
    // Add Size Of All Paths
    enumerator = [contents objectEnumerator];
    while (path = [enumerator nextObject])
    {
        NSDictionary * fattrs = [self attributesOfItemAtPath: [ source stringByAppendingPathComponent:path ] error:error];
        size += [[fattrs objectForKey:NSFileSize] unsignedLongLongValue];
    }
    // Return Total Size in MB
    
    return [ NSNumber numberWithUnsignedLongLong:size/1024/1024];
}

@end
