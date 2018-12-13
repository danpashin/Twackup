//
//  TWackup.m
//  twackup
//
//  Created by Даниил on 10/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "TWackup.h"
#import "TWPackage.h"
#import "TWDpkg.h"

@interface TWackup ()
+ (NSURL * _Nullable)workingDirectoryURL;
@end

@implementation TWackup

+ (void)rebuildAllPackages
{
    NSURL *workingDirectory = [self workingDirectoryURL];
    printf("Подготовка пакетов. Пожалуйста, подождите...\n");
    
    NSArray <TWPackage *> *allPackages = [TWDpkg allPackages];
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

+ (void)rebuildPackageWithIdentifier:(NSString *)identifier
{
    TWPackage *package = [TWDpkg packageForIdentifier:identifier];
    if (!package) {
        error_log("Пакет %s не найден!", identifier.UTF8String);
        return;
    }
    
    NSURL *workingDirectoryURL = [self workingDirectoryURL];
    [package buildDebAtURL:workingDirectoryURL];
}

+ (NSURL * _Nullable)workingDirectoryURL
{
    NSURL *workingDirectory = [NSURL fileURLWithPath:@"/var/mobile/Documents/twackup"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:workingDirectory.path])
        [fileManager createDirectoryAtURL:workingDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *userName = processInfo.environment[@"USER"].lowercaseString;
    if (![userName isEqualToString:@"root"] && access(workingDirectory.path.UTF8String, W_OK) != 0) {
        error_log("Утилита не имеет прав на запись в рабочую папку.\nПожалуйста, убедитесь, что утилита запущена от пользователя root.");
        exit(EXIT_FAILURE);
    }
    
    return workingDirectory;
}

@end
