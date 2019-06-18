//
//  TWDpkg.m
//  twackup
//
//  Created by Даниил on 10/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "TWDpkg.h"
#import "TWPackage.h"
#import "NSTask+Twackup.h"
#import "packages_parser.h"
#import "TWRegex.h"

@interface TWDpkg ()

/**
 Retrieves package control file for specified package.
 
 @param package Package identifier for parsing.
 @return Returns string of package control. Can return nil, if package not found.
 */
+ (NSString * _Nullable)controlForPackage:(NSString *)package;

@end

@implementation TWDpkg

+ (NSArray <TWPackage *> *)allPackages
{
    @autoreleasepool {
        NSMutableArray <TWPackage *> *allPackages = [NSMutableArray array];
        parse_packages_file(kTWDatabaseFilePath.UTF8String, ^(NSString * _Nonnull package_description, bool * _Nonnull stop) {
            TWPackage *package = [self packageForControl:package_description];
            if (package) {
                [allPackages addObject:package];
            }
        });
        
        return allPackages;
    }
}

+ (TWPackage * _Nullable)packageForControl:(NSString *)control
{
    NSString *identifier = [TWRegex valueForKey:@"Package" inControl:control];
    if ([identifier hasPrefix:@"gsc."] || [identifier hasPrefix:@"cy+"] || identifier.length == 0)
        return nil;
    
    NSString *status = [TWRegex valueForKey:@"Status" inControl:control];
    if (status.length > 0 && ![status containsString:@" installed"]) {
        return nil;
    }
    
    NSString *version = [TWRegex valueForKey:@"Version" inControl:control];
    NSString *architecture = [TWRegex valueForKey:@"Architecture" inControl:control];
    NSString *name = [TWRegex valueForKey:@"Name" inControl:control];
    
    NSString *safeControl = [TWPackage safeControlFromRAW:control];

    
    return [[TWPackage alloc] initWithID:identifier version:version name:name
                            architecture:architecture control:safeControl];
}


+ (TWPackage * _Nullable)packageForIdentifier:(NSString *)packageID
{
    if ([packageID hasPrefix:@"gsc."] || [packageID hasPrefix:@"cy+"] || packageID.length == 0)
        return nil;
    
    NSString *control = [self controlForPackage:packageID];
    if (!control)
        return nil;
    
    NSString *version = [TWRegex valueForKey:@"Version" inControl:control];
    NSString *architecture = [TWRegex valueForKey:@"Architecture" inControl:control];
    NSString *name = [TWRegex valueForKey:@"Name" inControl:control];
    
    NSString *safeControl = [TWPackage safeControlFromRAW:control];
    
    return [[TWPackage alloc] initWithID:packageID version:version name:name
                            architecture:architecture control:safeControl];
}

+ (NSString * _Nullable)controlForPackage:(NSString *)packageID
{
    __block NSString *packageControl = nil;
    
    parse_packages_file(kTWDatabaseFilePath.UTF8String, ^(NSString * _Nonnull control, bool * _Nonnull stop) {
        NSString *identifier = [TWRegex valueForKey:@"Package" inControl:control];
        if ([identifier isEqualToString:packageID]) {
            packageControl = control;
            *stop = true;
        }
    });
    
    return [TWPackage safeControlFromRAW:packageControl];
}

@end
