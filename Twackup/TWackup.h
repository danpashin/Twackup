//
//  TWackup.h
//  twackup
//
//  Created by Даниил on 10/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWackup : NSObject

/**
 Makes syncronous rebuild of all packages to deb archives.
 */
+ (void)rebuildAllPackages;

/**
 Makes syncronous rebuild of the package to deb.

 @param identifier Package identifier for rebuild.
 */
+ (void)rebuildPackageWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
