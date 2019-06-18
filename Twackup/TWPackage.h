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
 Name of the package.
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 Package version.
 */
@property (copy, nonatomic, readonly) NSString *version;

/**
 Package supported architecture.
 */
@property (copy, nonatomic, readonly) NSString *architecture;

/**
 Control file of current package.
 */
@property (copy, nonatomic, readonly) NSString *control;


@property (strong, nonatomic, readonly, getter=getPackageFiles) NSArray <NSString *> *packageFiles;


- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version name:(NSString *)name
              architecture:(NSString *)architecture control:(NSString *)control;


@end


@interface TWPackage (Build)

/**
 Builds deb from package files.
 
 @return Returns YES if deb was successfully built. Otherwise, returns NO.
 */
- (BOOL)buildDebAtURL:(NSURL *)tempURL error:(NSError *_Nullable *_Nullable)error;

@end


@interface TWPackage (Control)

+ (NSString *)safeControlFromRAW:(NSString *)rawControl;

@end

NS_ASSUME_NONNULL_END
