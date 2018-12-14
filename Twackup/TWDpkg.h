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
 Retrieves package files for the specified package.

 @param package Package identifier for parsing.
 @return Returns array of files path's for specified package.
 */
+ (NSArray <NSString *> *)filesForPackage:(NSString *)package;

/**
 Retrieves and parses package information from dpkg.

 @param packageID Package identifier for request.
 @return Return package model. Can return nil if package was not found.
 */
+ (TWPackage * _Nullable)packageForIdentifier:(NSString *)packageID;


/**
 Creates regular expression for parsing line from control.

 @param lineName Line name in control file.
 @return Returns instance of NSRegularExpression class.
 */
+ (NSRegularExpression *)regexForControlLineNamed:(NSString *)lineName;

@end

NS_ASSUME_NONNULL_END
