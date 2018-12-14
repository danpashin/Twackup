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
#import <SSZipArchive.h>

@interface TWackup ()
+ (NSURL * _Nullable)workingDirectoryURL;
@end

@implementation TWackup

+ (void)rebuildAllPackages
{
    NSURL *workingDirectory = [self workingDirectoryURL];
    
    NSMutableArray <NSString *> *failedPackages = nil;
    [self _rebuildAllPackagesAtURL:workingDirectory failed:&failedPackages];
    
    if (failedPackages.count == 0) {
        printf("\nКопирование успешно завершено! Перейдите в '%s' для просмотра .deb пакетов.\n",
               workingDirectory.path.UTF8String);
    } else {
        printf("\nКопирование прошло успешно, но следующие пакеты собрать не удалось:\n%s\n",
               failedPackages.description.UTF8String);
    }
}

+ (void)rebuildAllPackagesAndArchive
{
    NSURL *workingDirectory = [self workingDirectoryURL];
    
    NSMutableArray <NSString *> *failedPackages = nil;
    [self _rebuildAllPackagesAtURL:workingDirectory failed:&failedPackages];
    const NSUInteger failedCount = failedPackages.count;
    const BOOL archiveSuccess = [self archiveExistingPackages];
    
    
    if (failedCount == 0 && archiveSuccess) {
        printf("\nКопирование успешно завершено! Перейдите в '%s' для просмотра архива.\n",
               workingDirectory.URLByDeletingLastPathComponent.path.UTF8String);
    } else if (failedCount == 0 && !archiveSuccess) {
        printf("\nПакеты успешно собраны, но архивирование не удалось. Перейдите в '%s' для просмотра .deb пакетов\n",
               workingDirectory.path.UTF8String);
    } else {
        printf("\nКопирование прошло успешно, но следующие пакеты собрать не удалось:\n%s\n",
               failedPackages.description.UTF8String);
    }
}

+ (void)_rebuildAllPackagesAtURL:(NSURL *)workingDirectory failed:(NSMutableArray *_Nonnull *_Nullable)failedPackages
{
    printf("Подготовка пакетов. Пожалуйста, подождите...\n");
    
    NSArray <TWPackage *> *allPackages = [TWDpkg allPackages];
    printf("Найден(о) %lu пакет.\n", (unsigned long)allPackages.count);
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 5;
    operationQueue.name = @"ru.danpashin.twackup.packages.backup";
    
    NSMutableArray <NSString *> *localFailed = [NSMutableArray array];
    
    [allPackages enumerateObjectsUsingBlock:^(TWPackage * _Nonnull package, NSUInteger idx, BOOL * _Nonnull stop) {
        [operationQueue addOperationWithBlock:^{
            NSError *buildError = nil;
            BOOL buildSuccess = [package buildDebAtURL:workingDirectory error:&buildError];
            if (!buildSuccess) {
                error_log("Сборка %s не удалась.", package.identifier.UTF8String);
                [localFailed addObject:package.identifier];
            } else {
                printf("%s Успешно собран\n", package.identifier.UTF8String);
            }
        }];
    }];
    
    [operationQueue waitUntilAllOperationsAreFinished];
    
    *failedPackages = localFailed;
}

+ (void)rebuildPackageWithIdentifier:(NSString *)identifier
{
    TWPackage *package = [TWDpkg packageForIdentifier:identifier];
    if (!package) {
        error_log("Пакет %s не найден!", identifier.UTF8String);
        return;
    }
    
    NSURL *workingDirectoryURL = [self workingDirectoryURL];
    [package buildDebAtURL:workingDirectoryURL error:nil];
}

+ (NSURL * _Nullable)workingDirectoryURL
{
    NSURL *workingDirectory = [NSURL fileURLWithPath:@"/var/mobile/Documents/twackup"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:workingDirectory.path])
        [fileManager createDirectoryAtURL:workingDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
    if (access(workingDirectory.path.UTF8String, W_OK) != 0) {
        error_log("Утилита не имеет прав на запись в рабочую папку.\n"
                  "Пожалуйста, убедитесь, что утилита запущена от пользователя root.");
        exit(EXIT_FAILURE);
    }
    
    return workingDirectory;
}

+ (BOOL)archiveExistingPackages
{
    NSURL *directoryURL = [self workingDirectoryURL];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd-MM-yyyy_HH:mm";
    NSString *filename = [NSString stringWithFormat:@"twackup_%@.zip", [dateFormatter stringFromDate:[NSDate date]]];
    NSURL *zipFolderURL = [directoryURL URLByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSString *> *debsNames = [fileManager contentsOfDirectoryAtPath:directoryURL.path error:nil];
    debsNames = [debsNames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.deb'"]];
    
    NSMutableArray <NSString *> *pathsToDebs = [NSMutableArray array];
    [debsNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fullPath = [directoryURL URLByAppendingPathComponent:obj].path;
        [pathsToDebs addObject:fullPath];
    }];
    
    return [SSZipArchive createZipFileAtPath:zipFolderURL.path withFilesAtPaths:pathsToDebs];
}

@end
