//
//  TWPackage.m
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "TWPackage.h"

@implementation TWPackage

- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version name:(NSString *)name
              architecture:(NSString *)architecture control:(NSString *)control
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _version = version;
        _name = name;
        
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

- (NSArray <NSString *> *)getPackageFiles
{
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.list", kTWInfoDirectoryPath, self.identifier];
    
    NSError *error = nil;
    NSString *contents = [[NSString alloc] initWithContentsOfFile:fullPath usedEncoding:nil error:&error];
    if (error) {
        return @[];
    }
    
    NSMutableArray <NSString *> *files = [[contents componentsSeparatedByString:@"\n"] mutableCopy];
    [files removeObjectsInArray:@[@"/.", @""]];
    
    return files;
}

@end
