//
//  NSTask+Twackup.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSTask+Twackup.h"
#import <Foundation/Foundation.h>

@implementation NSTask (Twackup)

+ (BOOL)syncronouslyExecute:(NSString *)executablePath
                  arguments:(NSArray <NSString *> * _Nullable)arguments
                     output:(NSData * _Nullable * _Nullable)output
{
    NSPipe *pipe = [NSPipe pipe];
    
    NSTask *task = [NSTask new];
    task.arguments = arguments;
    task.standardOutput = pipe;
    task.standardError = pipe;
    
    if (@available(iOS 11.0, *)) {
        task.executableURL = [NSURL fileURLWithPath:executablePath];
        
        NSError *error = nil;
        [task launchAndReturnError:&error];
    } else {
        task.launchPath = executablePath;
        [task launch];
    }
    
    if (output)
        *output = pipe.fileHandleForReading.readDataToEndOfFile;
    
    [task waitUntilExit];
    
    return (task.terminationStatus == EXIT_SUCCESS);
}
@end
