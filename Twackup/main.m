//
//  main.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright (c) 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWackup.h"
#import "TWLocalizable.h"

BOOL debugEnabled = NO;

void printHelpMessage(void);
NSDictionary <NSString *, NSArray <NSString *> *> *parseArgments(void);



int main(int argc, const char * argv[])
{
    NSDictionary <NSString *, NSArray <NSString *> *> *arguments = parseArgments();
    debugEnabled = arguments[@"--debug"] ? YES : NO;
    
    if (arguments[@"-l"] || arguments[@"--list-installed"]) {
        [TWackup listInstalled];
    } else if (arguments[@"-a"] || arguments[@"--all"]) {
        if (arguments[@"-z"]) {
            [TWackup rebuildAllPackagesAndArchive];
        } else {
            [TWackup rebuildAllPackages];
        }
    } else if (arguments[@"-b"] || arguments[@"--build"]) {
        NSArray <NSString *> *identifiers = arguments[@"-b"] ?: arguments[@"--build"];
        [identifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull packageID, NSUInteger idx, BOOL * _Nonnull stop) {
            [TWackup rebuildPackageWithIdentifier:packageID];
        }];
    } else if (arguments[@"-v"] || arguments[@"--version"]) {
        printf("Twackup v%s (Builded on %s %s)\n", kTWVersion.UTF8String, __DATE__, __TIME__);
    } else {
        printf("%s", TWLocalizable.helpMessage);
    }
    
    return EXIT_SUCCESS;
}


NSDictionary <NSString *, NSArray <NSString *> *> *parseArgments(void)
{
    NSArray <NSString *> *arguments = [NSProcessInfo processInfo].arguments;
    NSUInteger argumentsCount = arguments.count;
    
    NSMutableDictionary *argumentsDict = [NSMutableDictionary dictionary];
    for (NSUInteger index = 1; index < argumentsCount; index++) {
        NSString *argument = arguments[index];
        
        if ([argument hasPrefix:@"-"]) {
            NSMutableArray <NSString *> *postArguments = [NSMutableArray array];
            for (NSUInteger secondIndex = index + 1; secondIndex < argumentsCount; secondIndex++) {
                NSString *nextArgument = arguments[secondIndex];
                if ([nextArgument hasPrefix:@"-"])
                    break;
                
                [postArguments addObject:nextArgument];
            }
            argumentsDict[argument] = postArguments;
        }
    }
    
    return argumentsDict;
}
