//
//  NSTask+Twackup.h
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSTask (Twackup)

/**
 Synchronously executes system command.

 @param executablePath The full path to the executable file.
 @param arguments Arguments that will be given to executable.
 @param output Return executable output.
 @return If executable was terminated with success status, returns YES. Otherwise returns NO.
 */
+ (BOOL)synchronouslyExecute:(NSString *)executablePath
                  arguments:(NSArray <NSString *> * _Nullable)arguments
                     output:(NSData * _Nullable * _Nullable)output;

@end

NS_ASSUME_NONNULL_END
