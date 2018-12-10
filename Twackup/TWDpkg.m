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

@implementation TWDpkg

+ (NSString *)dpkgPath
{
    return @"/usr/bin/dpkg-query";
}

+ (NSArray <TWPackage *> *)allPackages
{
    NSData *dpkgOutput = nil;
    
    NSArray *arguments = @[@"-f", @"${binary:Package}\n", @"-W"];
    if ([NSTask syncronouslyExecute:self.dpkgPath arguments:arguments output:&dpkgOutput] && dpkgOutput) {
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

+ (TWPackage *)packageForIdentifier:(NSString *)packageID
{
    if ([packageID hasPrefix:@"gsc."] || [packageID hasPrefix:@"cy+"] || packageID.length == 0)
        return nil;
    
    NSString *control = [self controlForPackage:packageID];
    NSString *packageVersion = [self versionForControl:control];
    NSString *packageArchitecture = [self architectureForControl:control];
    
    return [[TWPackage alloc] initWithID:packageID version:packageVersion
                            architecture:packageArchitecture];
}

+ (NSArray <NSString *> *)filesForPackage:(NSString *)packageID
{
    NSData *dpkgOutput = nil;
    
    NSArray *arguments = @[@"-L", packageID];
    if ([NSTask syncronouslyExecute:self.dpkgPath arguments:arguments output:&dpkgOutput] && dpkgOutput) {
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
    if ([NSTask syncronouslyExecute:self.dpkgPath arguments:arguments output:&packageControl]) {
        NSMutableString *controlString = [[NSMutableString alloc] initWithData:packageControl encoding:NSUTF8StringEncoding];
        
        NSRegularExpression *statusRegex = [self regexForControlLineNamed:@"Status"];
        [statusRegex replaceMatchesInString:controlString options:0 range:NSMakeRange(0, controlString.length) withTemplate:@""];
        
        NSRegularExpression *controlVersionRegex = [self regexForControlLineNamed:@"Config-Version"];
        [controlVersionRegex replaceMatchesInString:controlString options:0 range:NSMakeRange(0, controlString.length) withTemplate:@""];
        
        return controlString;
    }
    
    return nil;
}

+ (NSRegularExpression * _Nullable)regexForControlLineNamed:(NSString *)lineName
{
    NSString *pattern = [NSString stringWithFormat:@"(%@: .*)\n", lineName];
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:NSRegularExpressionCaseInsensitive
                                                       error:nil];
}

+ (NSString *)versionForControl:(NSString *)control
{
    NSRegularExpression *versionRegex = [self regexForControlLineNamed:@"Version"];
    NSRange versionStringRange = [versionRegex firstMatchInString:control options:0
                                                            range:NSMakeRange(0, control.length)].range;
    
    if (versionStringRange.location != NSNotFound) {
        NSString *versionString = [control substringWithRange:versionStringRange];
        versionString = [versionString stringByReplacingOccurrencesOfString:@"Version: " withString:@""];
        versionString = [versionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        return versionString;
    }
    
    return @"";
}

+ (NSString *)architectureForControl:(NSString *)control
{
    NSRegularExpression *architectureRegex = [self regexForControlLineNamed:@"Architecture"];
    NSRange architectureStringRange = [architectureRegex firstMatchInString:control options:0
                                                                      range:NSMakeRange(0, control.length)].range;
    
    if (architectureStringRange.location != NSNotFound) {
        NSString *architecture = [control substringWithRange:architectureStringRange];
        architecture = [architecture stringByReplacingOccurrencesOfString:@"Architecture: " withString:@""];
        architecture = [architecture stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        return architecture;
    }
    
    return @"";
}

@end
