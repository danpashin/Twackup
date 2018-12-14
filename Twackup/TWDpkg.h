//
//  TWDpkg.h
//  twackup
//
//  Created by Даниил on 10/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TWPackage;

NS_ASSUME_NONNULL_BEGIN

@interface TWDpkg : NSObject

/**
 Parses all installed packages.
 
 @return Returns array of packages.
 */
+ (NSArray <TWPackage *> *)allPackages;

/**
 Gets package files for the specified package.

 @param package Package identifier for parsing.
 @return Returns array of files path's for specified package.
 */
+ (NSArray <NSString *> *)filesForPackage:(NSString *)package;

/**
 Gets package control file for specified package.

 @param package Package identifier for parsing.
 @return Returns string of package control. Can return nil, if package not found.
 */
+ (NSMutableString * _Nullable)controlForPackage:(NSString *)package;


+ (TWPackage * _Nullable)packageForIdentifier:(NSString *)packageID;


+ (NSRegularExpression * _Nullable)regexForControlLineNamed:(NSString *)lineName;

@end

NS_ASSUME_NONNULL_END
