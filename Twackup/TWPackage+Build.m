//
//  TWPackage+Build.m
//  twackup
//
//  Created by Даниил on 18/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "TWPackage.h"
#import "NSTask+Twackup.h"
#import "TWDpkg.h"
#import <objc/runtime.h>

@implementation TWPackage (Build)

- (BOOL)buildDebAtURL:(NSURL *)tempURL error:(NSError *_Nullable *_Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *directoryName = [NSString stringWithFormat:@"%@_%@_%@", self.identifier, self.version, self.architecture];
    NSURL *workingDirectoryURL = [tempURL URLByAppendingPathComponent:directoryName];
    
    if ([fileManager fileExistsAtPath:workingDirectoryURL.path]) {
        [fileManager removeItemAtURL:workingDirectoryURL error:nil];
    }
    
    BOOL directoryCreated = [fileManager createDirectoryAtURL:workingDirectoryURL
                                  withIntermediateDirectories:NO attributes:nil error:error];
    if (!directoryCreated)
        return NO;
    
    if (![self copyFilesToDir:workingDirectoryURL])
        return NO;
    
    if (![self copyMetadataToDir:workingDirectoryURL error:error])
        return NO;
    
    NSString *dpkgPath = @"/usr/bin/dpkg-deb";
    NSArray *arguments = @[@"-b", workingDirectoryURL.path];
    BOOL buildSuccess = [NSTask synchronouslyExecute:dpkgPath arguments:arguments output:nil];
    if (buildSuccess)
        [fileManager removeItemAtURL:workingDirectoryURL error:nil];
    
    return buildSuccess;
}

- (BOOL)copyFilesToDir:(NSURL *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self.packageFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:obj isDirectory:&isDirectory];
        
        NSError *copyingError = nil;
        NSURL *fileURL = [directory URLByAppendingPathComponent:obj];
        if (isDirectory) {
            [fileManager createDirectoryAtURL:fileURL withIntermediateDirectories:NO
                                   attributes:nil error:&copyingError];
        } else {
            [fileManager copyItemAtPath:obj toPath:fileURL.path error:&copyingError];
        }
        
        if (copyingError) {
            warn_log("%s - %s", self.identifier.UTF8String, copyingError.localizedDescription.UTF8String);
        }
    }];
    
    return YES;
}

- (BOOL)copyMetadataToDir:(NSURL *)directory error:(NSError *_Nullable *_Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *debianFolder = [directory URLByAppendingPathComponent:@"DEBIAN"];
    [fileManager createDirectoryAtURL:debianFolder withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSArray <NSString *> *debianFiles = [fileManager contentsOfDirectoryAtPath:kTWInfoDirectoryPath error:nil];
    
    NSString *regexSafeIdentifier = [self.identifier stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    NSString *regexPattern = [NSString stringWithFormat:@"(%@\\.(?!(list|md5sums)))\\w+", regexSafeIdentifier];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES [c] %@", regexPattern];
    debianFiles = [debianFiles filteredArrayUsingPredicate:predicate];
    
    [debianFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", kTWInfoDirectoryPath, obj];
        NSURL *targetScriptURL = [debianFolder URLByAppendingPathComponent:obj.pathExtension];
        
        [fileManager copyItemAtPath:fullPath toPath:targetScriptURL.path error:nil];
        [fileManager setAttributes:@{NSFilePosixPermissions:@(0775)} ofItemAtPath:targetScriptURL.path error:nil];
    }];
    
    NSURL *controlURL = [debianFolder URLByAppendingPathComponent:@"control"];
    return [self.control writeToURL:controlURL atomically:YES encoding:NSUTF8StringEncoding error:error];
}

@end
