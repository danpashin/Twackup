//
//  TWPackage.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "TWPackage.h"
#import "NSTask+Twackup.h"
#import "TWDpkg.h"

@interface TWPackage ()
@property (strong, nonatomic) NSURL *workingDirectoryURL;
@end

@implementation TWPackage

- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version
              architecture:(NSString *)architecture control:(NSString *)control
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _version = version;
        _architecture = architecture;
        _control = control;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; identifier: '%@'; version: '%@'; archiitecture: '%@'>",
            NSStringFromClass([self class]), self, self.identifier, self.version, self.architecture];
}

- (BOOL)buildDebAtURL:(NSURL *)tempURL error:(NSError *_Nullable *_Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *directoryName = [NSString stringWithFormat:@"%@_%@_%@", self.identifier, self.version, self.architecture];
    self.workingDirectoryURL = [tempURL URLByAppendingPathComponent:directoryName];
    
    if ([fileManager fileExistsAtPath:self.workingDirectoryURL.path]) {
        [fileManager removeItemAtURL:self.workingDirectoryURL error:nil];
    }
    
    BOOL directoryCreated = [fileManager createDirectoryAtURL:self.workingDirectoryURL
                                  withIntermediateDirectories:NO attributes:nil error:error];
    if (!directoryCreated)
        return NO;
    
    if (![self copyFiles])
        return NO;
    
    if (![self copyMetadataWithError:error])
        return NO;
    
    NSString *dpkgPath = @"/usr/bin/dpkg-deb";
//    NSString *compressionQuality = @"-Zlzma";
//    if (@available(iOS 11.0, *)) {
//        compressionQuality = @"-Zxz";
//    }
    
    NSArray *arguments = @[@"-b", self.workingDirectoryURL.path];
    BOOL buildSuccess = [NSTask synchronouslyExecute:dpkgPath arguments:arguments output:nil];
    if (buildSuccess)
        [fileManager removeItemAtURL:self.workingDirectoryURL error:nil];
    
    return buildSuccess;
}

- (BOOL)copyFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray <NSString *> *packageFiles = [TWDpkg filesForPackage:self.identifier];
    
    [packageFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"/."] || obj.length == 0)
            return;
        
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:obj isDirectory:&isDirectory];
        
        NSError *copyingError = nil;
        NSURL *fileURL = [self.workingDirectoryURL URLByAppendingPathComponent:obj];
        if (isDirectory) {
            [fileManager createDirectoryAtURL:fileURL withIntermediateDirectories:NO
                                   attributes:nil error:&copyingError];
        } else {
            [fileManager copyItemAtPath:obj toPath:fileURL.path error:&copyingError];
        }
        
        if (copyingError && debugEnabled) {
            error_log("%s", copyingError.localizedDescription.UTF8String);
        }
    }];
    
    return YES;
}

- (BOOL)copyMetadataWithError:(NSError *_Nullable *_Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *debianFolder = [self.workingDirectoryURL URLByAppendingPathComponent:@"DEBIAN"];
    [fileManager createDirectoryAtURL:debianFolder withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *infoFolder = @"/var/lib/dpkg/info/";
    NSArray <NSString *> *debianFiles = [fileManager contentsOfDirectoryAtPath:infoFolder error:nil];
    
    NSString *regexSafeIdentifier = [self.identifier stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    NSString *regexPattern = [NSString stringWithFormat:@"(%@\\.(?!(list|md5sums)))\\w+", regexSafeIdentifier];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self MATCHES [c] %@", regexPattern];
    debianFiles = [debianFiles filteredArrayUsingPredicate:predicate];
    
    [debianFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", infoFolder, obj];
        NSURL *targetScriptURL = [debianFolder URLByAppendingPathComponent:obj.pathExtension];
        
        [fileManager copyItemAtPath:fullPath toPath:targetScriptURL.path error:nil];
        [fileManager setAttributes:@{NSFilePosixPermissions:@(0775)} ofItemAtPath:targetScriptURL.path error:nil];
    }];
    
    NSURL *controlURL = [debianFolder URLByAppendingPathComponent:@"control"];
    return [self.control writeToURL:controlURL atomically:YES encoding:NSUTF8StringEncoding error:error];
}

@end
