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
    NSData *dpkgOutput = nil;
    
    NSArray *arguments = @[@"-f", @"${binary:Package}\n", @"-W"];
    if ([NSTask synchronouslyExecute:self.dpkgPath arguments:arguments output:&dpkgOutput] && dpkgOutput) {
        NSString *packages = [[NSString alloc] initWithData:dpkgOutput
                                                   encoding:NSUTF8StringEncoding];
        
        NSMutableArray <TWPackage *> *allPackages = [NSMutableArray array];
        [packages enumerateLinesUsingBlock:^(NSString * _Nonnull packageID, BOOL * _Nonnull stop) {
            TWPackage *package = [self packageForIdentifier:packageID];
            if (package) {
                [allPackages addObject:package];
            }
        }];
        
        return allPackages;
    }
    
    return @[];
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
    NSString *pattern = [NSString stringWithFormat:@"(%@: .*)(\n|\r|\f)", lineName];
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:NSRegularExpressionCaseInsensitive
                                                       error:nil];
}

+ (NSString *)valueForKey:(NSString *)lineName inControl:(NSString *)control
{
    NSRegularExpression *lineRegex = [self regexForControlLineNamed:lineName];
    NSRange lineRange = [lineRegex firstMatchInString:control options:0
                                                range:NSMakeRange(0, control.length)].range;
    
    if (lineRange.location != NSNotFound) {
        NSString *keyString = [lineName stringByAppendingString:@": "];
        
        NSString *valueString = [control substringWithRange:lineRange];
        valueString = [valueString stringByReplacingOccurrencesOfString:keyString withString:@""];
        valueString = [valueString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        return valueString;
    }
    
    return @"";
}

@end
