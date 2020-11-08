#import "LSFindProcess.h"
#include <sys/param.h>

extern int proc_pidpath(int, void*, uint32_t);
extern char*** _NSGetEnviron(void);
extern int proc_listallpids(void*, int);
extern int proc_pidpath(int, void*, uint32_t);
static int process_buffer_size = 4096;

@implementation LSFindProcess

+ (NSString *)processNameFromPID:(pid_t)ppid {
    char path_buffer[MAXPATHLEN];
    proc_pidpath(ppid, (void*)path_buffer, sizeof(path_buffer));
    return [NSString stringWithUTF8String:path_buffer];
}

+ (pid_t) find_process:(const char*) name {
    pid_t *pid_buffer;
    char path_buffer[MAXPATHLEN];
    int count, i, ret;
    boolean_t res = FALSE;
    pid_t ppid_ret = 0;
    pid_buffer = (pid_t*)calloc(1, process_buffer_size);
    assert(pid_buffer != NULL);
    
    count = proc_listallpids(pid_buffer, process_buffer_size);
    NSLog(@"process count: %d", count);
    if(count) {
        for(i = 0; i < count; i++) {
            pid_t ppid = pid_buffer[i];
            
            ret = proc_pidpath(ppid, (void*)path_buffer, sizeof(path_buffer));
            if(ret < 0) {
                fprintf(stderr, "(%s:%d) proc_pidinfo() call failed.\n", __FILE__, __LINE__);
                continue;
            }
            fprintf(stderr, "comparing %s to %s\n", path_buffer, name);
            /*
            if (strncmp(path_buffer, name, strlen(path_buffer)) == 0){
                res = TRUE;
                ppid_ret = ppid;
                break;
            }*/
            
             if(strstr(path_buffer, name)) {
             fprintf(stderr, "match in %s to %s\n", path_buffer, name);
             res = TRUE;
             ppid_ret = ppid;
             break;
             }
        }
    }
    
    free(pid_buffer);
    return ppid_ret;
}

@end



