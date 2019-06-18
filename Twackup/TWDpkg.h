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
 Retrieves and parses package information from dpkg.

 @param packageID Package identifier for request.
 @return Return package model. Can return nil if package was not found.
 */
+ (TWPackage * _Nullable)packageForIdentifier:(NSString *)packageID;

@end

NS_ASSUME_NONNULL_END
