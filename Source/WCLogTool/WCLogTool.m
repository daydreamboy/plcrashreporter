//
//  WCLogTool.m
//  HelloTest
//
//  Created by wesley_chen on 23/08/2017.
//  Copyright © 2017 wesley_chen. All rights reserved.
//

#import "WCLogTool.h"
#import "WCExceptionTool.h"

#import <objc/runtime.h>

#define WCLogTool_DEBUG 1

@interface WCLogTool ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDictionary *logLevelTags;
@property (nonatomic, strong) NSDictionary *logLevelShortTags;

@property (nonatomic, copy) NSString *logDirPath;
@property (nonatomic, copy) NSString *logFilePrefix;
@property (nonatomic, copy) NSString *logFileExtension;
@property (nonatomic, copy, readwrite) NSString *currentLogFilePath;

@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation WCLogTool

static long long unsigned sOrder;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static WCLogTool *sInstance;
    dispatch_once(&onceToken, ^{
        sInstance = [[WCLogTool alloc] init];
    });
    
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentConsoleLogLevel = WCLogLevelDebug;
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss.SSSSSSZZ";
        formatter.timeZone = [NSTimeZone systemTimeZone];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _formatter = formatter;
        
        _logLevelTags = @{
                          @(WCLogLevelDebug): @"DEBUG",
                          @(WCLogLevelInfo): @"INFO",
                          @(WCLogLevelWarning): @"WARNING",
                          @(WCLogLevelError): @"ERROR",
                          @(WCLogLevelAlert): @"ALERT",
                          };
        
        _logLevelShortTags = @{
                               @(WCLogLevelDebug): @"D",
                               @(WCLogLevelInfo): @"I",
                               @(WCLogLevelWarning): @"W",
                               @(WCLogLevelError): @"E",
                               @(WCLogLevelAlert): @"A",
                               };
        
        _logDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _logFilePrefix = @"wc_log";
        _logFileExtension = @"txt";
        
        _showCallerFunction = YES;
        _showInterpolatedVariable = YES;
        _showShortLogTag = NO;
        _showSourceFileLocation = YES;
        
        _enableLogToFile = YES;
        
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:[self createLogFileIfNeeded]];
    }
    return self;
}

#pragma mark - Getter

- (NSString *)currentLogFilePath {
    _currentLogFilePath = [NSString stringWithFormat:@"%@/%@.%@", _logDirPath, _logFilePrefix, _logFileExtension];
    
    return _currentLogFilePath;
}

#pragma mark -

- (void)dealloc {
    if (@available(iOS 13.0, *)) {
        NSError *error;
        [self.fileHandle closeAndReturnError:&error];
#if WCLogTool_DEBUG
    if (error) {
        NSLog(@"[WCLogTool]<destroy file handle error>|error:%@|", error);
    }
#endif
    }
    else {
        [self.fileHandle closeFile];
    }
}

#pragma mark - 

- (NSString *)levelTagWithLogLevel:(WCLogLevel)logLevel {
    return _logLevelTags[@(logLevel)];
}

- (NSString *)levelShortTagWithLogLevel:(WCLogLevel)logLevel {
    return _logLevelShortTags[@(logLevel)];
}

- (void)appendStringToFile:(NSString *)msg {
    [self createLogFileIfNeeded];
    [self.fileHandle truncateFileAtOffset:[self.fileHandle seekToEndOfFile]];
    [self.fileHandle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (@available(iOS 13.0, *)) {
        NSError *error;
        [self.fileHandle synchronizeAndReturnError:&error];
#if WCLogTool_DEBUG
        if (error) {
            NSLog(@"[WCLogTool]<sync data to log file error>|error:%@|", error);
        }
#endif
    }
    else {
        [self.fileHandle synchronizeFile];
    }
}

- (NSString *)createLogFileIfNeeded {
    // TODO: calculate current log file size
    //
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.currentLogFilePath]) {
#if WCLogTool_DEBUG
        fprintf(stderr, "Creating file at %s\n", self.currentLogFilePath.UTF8String);
#endif
        [[NSData data] writeToFile:self.currentLogFilePath atomically:YES];
    }
    
    return self.currentLogFilePath;
}

- (nullable NSString *)createLogMessageWithLevel:(WCLogLevel)level file:(const char *)file lineNumber:(int)lineNumber funcName:(const char *)funcName callStack:(NSArray<NSString *> * _Nullable)callStack format:(NSString *)format vaList:(va_list)ap {
    if (level < [WCLogTool sharedInstance].currentConsoleLogLevel) {
        return nil;
    }
    
    NSDate *timestamp = [NSDate date];
    NSString *timestampString = [[WCLogTool sharedInstance].formatter stringFromDate:timestamp];
    const char *fileName = ((strrchr(file, '/') ?: file - 1) + 1);
    
    if (_showInterpolatedVariable) {
        format = [format stringByReplacingOccurrencesOfString:@"%@" withString:@"`%@`"];
    }
    NSString *customerMessage = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@", format] arguments:ap];
    
    NSString *logMessage = ({
        NSMutableString *stringM = [NSMutableString string];
        
        // Note: componentable log message
        // full format for printf: @"%s %llu:[%s][%s:%d]`%s: %s"
        // 2022-12-12 11:01:14.923000+0800 1:[DEBUG][PrintLogInCFunctionsViewController.m:18]`void callAFunction(NSString *__strong): a test for calling c function with `some parameters`
        [stringM appendFormat:@"%@ ", timestampString];
        [stringM appendFormat:@"%llu:", sOrder++];
        [stringM appendFormat:@"[%@]", (_showShortLogTag == YES ? [[WCLogTool sharedInstance] levelShortTagWithLogLevel:level] : [[WCLogTool sharedInstance] levelTagWithLogLevel:level])];
        if (_showSourceFileLocation) {
            [stringM appendFormat:@"[%s:%d]", fileName, lineNumber];
        }
        if (_showCallerFunction) {
            [stringM appendFormat:@"`%s:", funcName];
        }
        [stringM appendFormat:@" %@", customerMessage];
        
        if (callStack) {
            [stringM appendFormat:@"\n%@", callStack];
        }
        [stringM appendString:@"\r\n"];
        
        stringM;
    });
    
    return logMessage;
}

- (void)logToConsoleWithLevel:(WCLogLevel)level logMessage:(NSString *)logMessage {
    if (level >= [WCLogTool sharedInstance].currentConsoleLogLevel) {
        fprintf(stdout, "%s", logMessage.UTF8String);
    }
}

- (void)logToFileIfNeededWithLevel:(WCLogLevel)level logMessage:(NSString *)logMessage {
    if (_enableLogToFile && level >= [WCLogTool sharedInstance].currentConsoleLogLevel) {
        [[WCLogTool sharedInstance] appendStringToFile:logMessage];
    }
}

@end

#pragma mark - Public Methods

void WCEventLogInMethod(WCLogLevel level, id slf, SEL sel, const char *file, int lineNumber, const char *funcName, BOOL showCallStack, NSString *format, ...)
{
    NSArray<NSString *> *callStack;
    if (showCallStack) {
        callStack = [WCExceptionTool backtrace];
    }
    
    // @see https://stackoverflow.com/questions/3530771/passing-variable-arguments-to-another-function-that-accepts-a-variable-argument
    va_list ap;
    va_start (ap, format);
    NSString *logMessage = [[WCLogTool sharedInstance] createLogMessageWithLevel:level file:file lineNumber:lineNumber funcName:funcName callStack:callStack format:format vaList:ap];
    va_end (ap);
    
    // Note: not not the current log level, will get a null log message
    if (logMessage) {
        [[WCLogTool sharedInstance] logToConsoleWithLevel:level logMessage:logMessage];
        [[WCLogTool sharedInstance] logToFileIfNeededWithLevel:level logMessage:logMessage];
    }
}

void WCEventLogInFunction(WCLogLevel level, const char *file, int lineNumber, const char *funcName, BOOL showCallStack, NSString *format,...)
{
    NSArray<NSString *> *callStack;
    if (showCallStack) {
        callStack = [WCExceptionTool backtrace];
    }
    
    va_list ap;
    va_start (ap, format);
    NSString *logMessage = [[WCLogTool sharedInstance] createLogMessageWithLevel:level file:file lineNumber:lineNumber funcName:funcName callStack:callStack format:format vaList:ap];
    va_end (ap);
    
    // Note: not not the current log level, will get a null log message
    if (logMessage) {
        [[WCLogTool sharedInstance] logToConsoleWithLevel:level logMessage:logMessage];
        [[WCLogTool sharedInstance] logToFileIfNeededWithLevel:level logMessage:logMessage];
    }
}
