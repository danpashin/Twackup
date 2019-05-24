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

@interface TWDpkg ()

/**
 Retrieves package control file for specified package.
 
 @param package Package identifier for parsing.
 @return Returns string of package control. Can return nil, if package not found.
 */
+ (NSMutableString * _Nullable)controlForPackage:(NSString *)package;

@end

@implementation TWDpkg

+ (NSString *)dpkgPath
{
    return @"/usr/bin/dpkg-query";
}

+ (NSArray <TWPackage *> *)allPackages
{
    NSMutableArray <TWPackage *> *allPackages = [NSMutableArray array];
    parse_packages_file("/var/lib/dpkg/status", ^(NSString * _Nonnull package_description) {
        TWPackage *package = [self packageForControl:package_description];
        if (package) {
            [allPackages addObject:package];
        }
    });
    
    return allPackages;
}

+ (TWPackage * _Nullable)packageForControl:(NSString *)control
{
    NSString *identifier = [self valueForKey:@"Package" inControl:control];
    if ([identifier hasPrefix:@"gsc."] || [identifier hasPrefix:@"cy+"] || identifier.length == 0)
        return nil;
    
    NSString *version = [self valueForKey:@"Version" inControl:control];
    NSString *architecture = [self valueForKey:@"Architecture" inControl:control];
    NSString *name = [self valueForKey:@"Name" inControl:control];
    
    NSMutableString *mutableControl = [control mutableCopy];
    
    NSRegularExpression *statusRegex = [self regexForControlLineNamed:@"Status"];
    [statusRegex replaceMatchesInString:mutableControl options:0 range:NSMakeRange(0, mutableControl.length) withTemplate:@""];
    
    NSRegularExpression *controlVersionRegex = [self regexForControlLineNamed:@"Config-Version"];
    [controlVersionRegex replaceMatchesInString:mutableControl options:0 range:NSMakeRange(0, mutableControl.length) withTemplate:@""];
    
    [mutableControl appendString:@"\n"];
    
    return [[TWPackage alloc] initWithID:identifier version:version name:name
                            architecture:architecture control:mutableControl];
}


+ (TWPackage * _Nullable)packageForIdentifier:(NSString *)packageID
{
    if ([packageID hasPrefix:@"gsc."] || [packageID hasPrefix:@"cy+"] || packageID.length == 0)
        return nil;
    
    NSString *control = [self controlForPackage:packageID];
    if (!control)
        return nil;
    
    NSString *version = [self valueForKey:@"Version" inControl:control];
    NSString *architecture = [self valueForKey:@"Architecture" inControl:control];
    NSString *name = [self valueForKey:@"Name" inControl:control];
    
    return [[TWPackage alloc] initWithID:packageID version:version name:name
                            architecture:architecture control:control];
}

+ (NSArray <NSString *> *)filesForPackage:(NSString *)packageID
{
    NSData *dpkgOutput = nil;
    
    NSArray *arguments = @[@"-L", packageID];
    if ([NSTask synchronouslyExecute:self.dpkgPath arguments:arguments output:&dpkgOutput] && dpkgOutput) {
        NSString *allFiles = [[NSString alloc] initWithData:dpkgOutput
                                                   encoding:NSUTF8StringEncoding];
        return [allFiles componentsSeparatedByString:@"\n"];
    }
    
    return @[];
}

+ (NSMutableString * _Nullable)controlForPackage:(NSString *)packageID
{
    NSData *packageControl = nil;
    
    NSArray *arguments = @[@"-s", packageID];
    if ([NSTask synchronouslyExecute:self.dpkgPath arguments:arguments output:&packageControl] && packageControl) {
        NSMutableString *controlString = [[NSMutableString alloc] initWithData:packageControl encoding:NSUTF8StringEncoding];
        if (!controlString)
            return nil;
        
        NSRegularExpression *statusRegex = [self regexForControlLineNamed:@"Status"];
        [statusRegex replaceMatchesInString:controlString options:0 range:NSMakeRange(0, controlString.length) withTemplate:@""];
        
        NSRegularExpression *controlVersionRegex = [self regexForControlLineNamed:@"Config-Version"];
        [controlVersionRegex replaceMatchesInString:controlString options:0 range:NSMakeRange(0, controlString.length) withTemplate:@""];
        
        return controlString;
    }
    
    return nil;
}

+ (NSRegularExpression *)regexForControlLineNamed:(NSString *)lineName
{
    NSString *pattern = [NSString stringWithFormat:@"(%@: .*){1}(\n|\r|\f)*", lineName];
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:0
                                                       error:nil];
}

+ (NSString *)valueForKey:(NSString *)lineName inControl:(NSString *)string
{
    if (string.length == 0) {
        return nil;
    }
    
    NSRegularExpression *lineRegex = [self regexForControlLineNamed:lineName];
    NSTextCheckingResult *result = [lineRegex firstMatchInString:string options:0
                                                           range:NSMakeRange(0, string.length)];
    
    if (result) {
        NSMutableString *valueString = [[string substringWithRange:result.range] mutableCopy];
        
        NSRange keyStringRange = [valueString rangeOfString:@":"];
        if (keyStringRange.location != NSNotFound) {
            [valueString deleteCharactersInRange:NSMakeRange(0, keyStringRange.location + 1)];
        }
        
        
        NSRange valueStringRange = NSMakeRange(0, valueString.length);
        while ([valueString hasPrefix:@" "]) {
            [valueString deleteCharactersInRange:NSMakeRange(0, 1)];
            valueStringRange.length -= 1;
        }
        
        [valueString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:valueStringRange];
        valueStringRange.length = valueString.length;
        [valueString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:valueStringRange];
        
        return valueString;
    }
    
    return nil;
}

@end
