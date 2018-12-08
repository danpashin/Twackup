//
//  main.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright (c) 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWPackage.h"

BOOL strictCopy = NO;
void recreateDirectory(NSURL *directoryURL);
void backupAllPackages(NSURL *workingDirectory);



int main(int argc, const char * argv[])
{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    strictCopy = [processInfo.arguments containsObject:@"-strict"];
    
    NSURL *workingDirectory = [NSURL fileURLWithPath:@"/var/mobile/Documents/twackup"];
    recreateDirectory(workingDirectory);
    
    NSString *userName = processInfo.environment[@"USER"].lowercaseString;
    if (![userName isEqualToString:@"root"] && access(workingDirectory.path.UTF8String, W_OK) != 0) {
        error_log("Утилита не имеет прав на запись в рабочую папку.\nПожалуйста, убедитесь, что утилита запущена от пользователя root.");
        return EXIT_FAILURE;
    }
    
    backupAllPackages(workingDirectory);
    
    return EXIT_SUCCESS;
}



void backupAllPackages(NSURL *workingDirectory)
{
    printf("Подготовка пакетов. Пожалуйста, подождите...\n");
    
    NSArray <TWPackage *> *allPackages = [TWPackage getAllPackages];
    printf("Найден(о) %lu пакет. Начинаем резервное копирование...\n", (unsigned long)allPackages.count);
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 5;
    operationQueue.name = @"ru.danpashin.twackup.packages.backup";
    
    [allPackages enumerateObjectsUsingBlock:^(TWPackage * _Nonnull package, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:package
                                                                                selector:@selector(buildDebAtURL:)
                                                                                  object:workingDirectory];
        [operationQueue addOperation:operation];
    }];
    
    [operationQueue waitUntilAllOperationsAreFinished];
    
    printf("\nКопирование успешно завершено! Перейдите в '%s' для просмотра .deb пакетов.\n", workingDirectory.path.UTF8String);
}

void recreateDirectory(NSURL *directoryURL)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directoryURL.path])
        [fileManager removeItemAtURL:directoryURL error:nil];
    
    [fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:NO attributes:nil error:nil];
}
