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

- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version architecture:(NSString *)architecture
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _version = version;
        _architecture = architecture;
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
    
    if (![self copyFilesWithError:error]) {
        [fileManager removeItemAtURL:self.workingDirectoryURL error:nil];
        return NO;
    }
    
    if (![self copyMetadataWithError:error]) {
        [fileManager removeItemAtURL:self.workingDirectoryURL error:nil];
        return NO;
    }
    
    NSString *dpkgPath = @"/usr/bin/dpkg-deb";
//    NSString *compressionQuality = @"-Zlzma";
//    if (@available(iOS 11.0, *)) {
//        compressionQuality = @"-Zxz";
//    }
    
    NSArray *arguments = @[@"-b", self.workingDirectoryURL.path];
    BOOL buildSuccess = [NSTask syncronouslyExecute:dpkgPath arguments:arguments output:nil];
    if (buildSuccess)
        [fileManager removeItemAtURL:self.workingDirectoryURL error:nil];
    
    return buildSuccess;
}

- (BOOL)copyFilesWithError:(NSError *_Nullable *_Nullable)error
{
    __block BOOL operationISsuccess = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray <NSString *> *packageFiles = [TWDpkg filesForPackage:self.identifier];
    
    [packageFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"/."] || obj.length == 0)
            return;
        
        BOOL isDirectory = [obj hasSuffix:@".app"];
        [fileManager fileExistsAtPath:obj isDirectory:&isDirectory];
        
        NSError *copyingError = nil;
        NSURL *fileURL = [self.workingDirectoryURL URLByAppendingPathComponent:obj];
        if (isDirectory) {
            [fileManager createDirectoryAtURL:fileURL withIntermediateDirectories:NO
                                   attributes:nil error:&copyingError];
        } else {
            [fileManager copyItemAtPath:obj toPath:fileURL.path error:&copyingError];
        }
        
        if (copyingError && strictCopy) {
            error_log("Error while creating item in temporary directory! %s\nStopping...",
                      copyingError.description.UTF8String);
            *stop = YES;
            operationISsuccess = NO;
        }
    }];
    
    return operationISsuccess;
}

- (BOOL)copyMetadataWithError:(NSError *_Nullable *_Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *debianFolder = [self.workingDirectoryURL URLByAppendingPathComponent:@"DEBIAN"];
    [fileManager createDirectoryAtURL:debianFolder withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *dpkgInfoFolder = [NSString stringWithFormat:@"/var/lib/dpkg/info/%@", self.identifier];
    
    NSArray <NSString *> *packageScripts = @[@"preinst", @"postinst", @"prerm", @"postrm", @"extrainst_"];
    [packageScripts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *scriptPath = [NSString stringWithFormat:@"%@.%@", dpkgInfoFolder, obj];
        if ([fileManager fileExistsAtPath:scriptPath]) {
            NSURL *targetScriptURL = [debianFolder URLByAppendingPathComponent:obj];
            [fileManager copyItemAtPath:scriptPath toPath:targetScriptURL.path error:nil];
        }
    }];
    
    NSMutableString *control = [TWDpkg controlForPackage:self.identifier];
    NSURL *controlURL = [debianFolder URLByAppendingPathComponent:@"control"];
    
    return [control writeToURL:controlURL atomically:YES encoding:NSUTF8StringEncoding error:error];;
}

@end
