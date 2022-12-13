//
//  WCExceptionTool.h
//  HelloNSLog
//
//  Created by wesley_chen on 2022/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCExceptionTool : NSObject

@end

@interface WCExceptionTool ()
+ (NSArray<NSString *> *)backtrace;
@end

NS_ASSUME_NONNULL_END
