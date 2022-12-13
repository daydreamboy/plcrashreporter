//
//  WCLogTool.h
//  HelloTest
//
//  Created by wesley_chen on 23/08/2017.
//  Copyright © 2017 wesley_chen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WCLogLevel) {
    WCLogLevelDebug,
    WCLogLevelInfo,
    WCLogLevelWarning,
    WCLogLevelError,
    WCLogLevelAlert,
};

#pragma mark - Log Suite

// Log suite in OC/C methods
#define WCLogD(args...) WCLogInMethod(WCLogLevelDebug, args)
#define WCLogI(args...) WCLogInMethod(WCLogLevelInfo, args)
#define WCLogW(args...) WCLogInMethod(WCLogLevelWarning, args)
#define WCLogE(args...) WCLogInMethod(WCLogLevelError, args)
#define WCLogA(args...) WCLogInMethod(WCLogLevelAlert, args)

#define WCLogInMethod(level, args...)    WCEventLogInFunction(level, __FILE__, __LINE__, __PRETTY_FUNCTION__, NO, args)

#pragma mark - Log Suite With Call Stack

// Note: CS short for Call Stack
#define WCLogD_CS(args...) WCLogInMethodWithCS(WCLogLevelDebug, args)
#define WCLogI_CS(args...) WCLogInMethodWithCS(WCLogLevelInfo, args)
#define WCLogW_CS(args...) WCLogInMethodWithCS(WCLogLevelWarning, args)
#define WCLogE_CS(args...) WCLogInMethodWithCS(WCLogLevelError, args)
#define WCLogA_CS(args...) WCLogInMethodWithCS(WCLogLevelAlert, args)

#define WCLogInMethodWithCS(level, args...)    WCEventLogInFunction(level, __FILE__, __LINE__, __PRETTY_FUNCTION__, YES, args)

NS_ASSUME_NONNULL_BEGIN

extern void WCEventLogInMethod(WCLogLevel level, id slf, SEL sel, const char *file, int lineNumber, const char *funcName, BOOL showCallStack, NSString *format, ...);
extern void WCEventLogInFunction(WCLogLevel level, const char *file, int lineNumber, const char *funcName, BOOL showCallStack, NSString *format,...);

// @seehttps://stackoverflow.com/questions/21512382/how-do-i-define-a-macro-with-variadic-method-in-objective-c
// ## __VA_ARGS__ 的原因

typedef void(^WCLogCallbackType)(WCLogLevel level, NSString *message);

@interface WCLogTool : NSObject

@property (nonatomic, assign) WCLogLevel currentConsoleLogLevel;

@property (nonatomic, copy, readonly) NSString *currentLogFilePath;
/**
 Default is YES
 */
@property (nonatomic, assign) BOOL showInterpolatedVariable;
/**
 Default is NO
 */
@property (nonatomic, assign) BOOL showShortLogTag;
/**
 Default is YES
 */
@property (nonatomic, assign) BOOL showSourceFileLocation;
/**
 Default is YES
 */
@property (nonatomic, assign) BOOL showCallerFunction;
/**
 Default is YES
 */
@property (nonatomic, assign) BOOL enableLogToFile;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
