//
//  main.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright (c) 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWackup.h"

BOOL debugEnabled = NO;

void printHelpMessage(void);
NSDictionary <NSString *, NSArray <NSString *> *> *parseArgments(void);



int main(int argc, const char * argv[])
{
    NSDictionary <NSString *, NSArray <NSString *> *> *arguments = parseArgments();
    debugEnabled = arguments[@"--debug"] ? YES : NO;
    
    if (arguments[@"-a"] || arguments[@"--all"]) {
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
    } else if (arguments[@"-v"]) {
        printf("Twackup %s\n", kTWVersion.UTF8String);
    } else {
        printHelpMessage();
    }
    
    return EXIT_SUCCESS;
}

void printHelpMessage(void)
{
    printf("Использование:" "\n"
           "    -a|--all Собирает все установленные твики в deb-файлы." "\n"
           "    -z  Упаковывает все обработанные deb-файлы в один zip-архив." "\n"
           "    Эти два параметра можно использовать совместно." "\n"
           "\n"
           "    -b|--build [идентификаторы пакетов] Собирает пакеты с указанными идентификаторами в deb-файлы." "\n"
           "\n"
           "    -v Показывает версию утилиты." "\n"
           "    --debug Shows debug info while copying files" "\n"
           );
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
