//
//  DDLogWrapper.h
//  ConnectTest
//
//  Created by David Westbrook on 10/8/14.
//
//

@interface DDLogWrapper : NSObject
+ (void) logVerbose:(NSString *)message;
+ (void) logError:(NSString *)message;
+ (void) logInfo:(NSString *)message;
@end