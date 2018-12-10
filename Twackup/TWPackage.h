//
//  TWPackage.h
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWPackage : NSObject

/**
 Package identifier.
 */
@property (copy, nonatomic, readonly) NSString *identifier;

/**
 Package version.
 */
@property (copy, nonatomic, readonly) NSString *version;

/**
 Package supported architecture.
 */
@property (copy, nonatomic, readonly) NSString *architecture;


- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version architecture:(NSString *)architecture;

/**
 Builds deb from package files.
 */
- (void)buildDebAtURL:(NSURL *)tempURL;

@end

NS_ASSUME_NONNULL_END
