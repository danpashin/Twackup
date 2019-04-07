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
#import "TWLocalizable.h"

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
        printf(localized("\nBackup successfully finished! Go to '%s' for .deb packages.\n"),
               workingDirectory.path.UTF8String);
    } else {
        printf(localized("\nBackup was successful, however, the following packages could not be built:\n%s\n"),
               failedPackages.description.UTF8String);
    }
}

+ (void)rebuildAllPackagesAndArchive
{
    NSURL *workingDirectory = [self workingDirectoryURL];
    
    NSMutableArray <NSString *> *failedPackages = nil;
    [self _rebuildAllPackagesAtURL:workingDirectory failed:&failedPackages];
    const NSUInteger failedCount = failedPackages.count;
    
    printf(PRINT_YEL_COLOR "%s" PRINT_DEF_COLOR "\n", localized("Archiving..."));
    const BOOL archiveSuccess = [self archiveExistingPackages];
    
    
    if (failedCount == 0 && archiveSuccess) {
        printf(localized("\nBackup completed successfully! Go to '%s' to view the archive.\n"),
               workingDirectory.URLByDeletingLastPathComponent.path.UTF8String);
    } else if (failedCount == 0 && !archiveSuccess) {
        printf(localized("\nPackages were successfully built, but archiving failed. Go to '%s' to view deb files.\n"),
               workingDirectory.path.UTF8String);
    } else {
        printf(localized("\nCopying was successful, but the following packages could not be built:\n%s\n"),
               failedPackages.description.UTF8String);
    }
}

+ (void)_rebuildAllPackagesAtURL:(NSURL *)workingDirectory failed:(NSMutableArray *_Nonnull *_Nullable)failedPackages
{
    printf(PRINT_YEL_COLOR "%s" PRINT_DEF_COLOR, localized("Preparing packages. Please, wait...\n"));
    
    NSArray <TWPackage *> *allPackages = [TWDpkg allPackages];
    printf(PRINT_YEL_COLOR "%s " PRINT_CYN_COLOR "%lu" PRINT_YEL_COLOR " %s." PRINT_DEF_COLOR "\n", 
           localized("Found"), (unsigned long)allPackages.count, localized("packages"));
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 5;
    operationQueue.name = @"ru.danpashin.twackup.packages.backup";
    operationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    
    NSMutableArray <NSString *> *localFailed = [NSMutableArray array];
    
    [allPackages enumerateObjectsUsingBlock:^(TWPackage * _Nonnull package, NSUInteger idx, BOOL * _Nonnull stop) {
        [operationQueue addOperationWithBlock:^{
            printf(PRINT_YEL_COLOR "%s: " PRINT_DEF_COLOR "%s\n", localized("Processing"), package.identifier.UTF8String);
            
            if (![self rebuildPackage:package inDirectory:workingDirectory]) {
                [localFailed addObject:package.identifier];
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
        error_log("Package %s not found!", identifier.UTF8String);
        return;
    }
    
    NSURL *workingDirectoryURL = [self workingDirectoryURL];
    [self rebuildPackage:package inDirectory:workingDirectoryURL];
}

+ (BOOL)rebuildPackage:(TWPackage *)package inDirectory:(NSURL *)directory
{
    NSError *error = nil;
    BOOL buildSuccess = [package buildDebAtURL:directory error:&error];
    if (buildSuccess) {
        printf(PRINT_YEL_COLOR "%s: " PRINT_DEF_COLOR "%s\n", localized("Done"), package.identifier.UTF8String);
    } else {
        error_log("Package %s not found.\n%s", package.identifier.UTF8String, error.description.UTF8String);
    }
    
    return buildSuccess;
}

+ (NSURL * _Nullable)workingDirectoryURL
{
    NSURL *workingDirectory = [NSURL fileURLWithPath:@"/var/mobile/Documents/twackup"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:workingDirectory.path])
        [fileManager createDirectoryAtURL:workingDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    
    if (access(workingDirectory.path.UTF8String, W_OK) != EXIT_SUCCESS) {
        error_log("Twackup does not have write access to the working folder.\n"
                  "Please make sure the utility is running as root.");
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
    NSURL *zipFolderURL = [directoryURL.URLByDeletingLastPathComponent URLByAppendingPathComponent:filename];
    
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

+ (void)listInstalled
{
    printf(PRINT_YEL_COLOR "%s" PRINT_DEF_COLOR, localized("Preparing packages. Please, wait...\n"));
    
    NSMutableArray <TWPackage *> *allPackages = [[TWDpkg allPackages] mutableCopy];
    [allPackages sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    unsigned long counter = 0;
    for (TWPackage *package in allPackages) {
        printf(PRINT_RED_COLOR "%3.lu" PRINT_DEF_COLOR ": ", ++counter);
        
        if (package.name.length > 0) {
            printf("%s - " PRINT_CYN_COLOR "%s" PRINT_DEF_COLOR "\n", 
                   package.name.UTF8String, package.identifier.UTF8String);
        } else {
            printf(PRINT_CYN_COLOR "%s" PRINT_DEF_COLOR "\n", package.identifier.UTF8String);
        }
    }
}

@end
