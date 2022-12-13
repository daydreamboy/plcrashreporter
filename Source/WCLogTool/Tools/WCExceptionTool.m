//
//  WCExceptionTool.m
//  HelloNSLog
//
//  Created by wesley_chen on 2022/12/13.
//

#import "WCExceptionTool.h"

#include <execinfo.h>

@implementation WCExceptionTool

+ (NSArray<NSString *> *)backtrace {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

@end
