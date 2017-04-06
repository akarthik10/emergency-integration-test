//
//  DDLogWrapper.m
//  ConnectTest
//
//  Created by David Westbrook on 10/8/14.
//
//

#import <Foundation/Foundation.h>
#import "DDLogWrapper.h"

// Logging Framework Lumberjack
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

// Definition of the current log level
//#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
//#else
//static const int ddLogLevel = LOG_LEVEL_ERROR;
//#endif

@implementation DDLogWrapper

+ (void) logVerbose:(NSString *)message {
    DDLogVerbose(message);
}

+ (void) logError:(NSString *)message {
    DDLogError(message);
}

+ (void) logInfo:(NSString *)message {
    DDLogInfo(message);
}

@end
