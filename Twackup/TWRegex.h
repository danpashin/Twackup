//
//  TWRegex.h
//  twackup
//
//  Created by Даниил on 18/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWRegex : NSObject

/**
 Creates regular expression for parsing line from control.
 
 @param lineName Line name in control file.
 @return Returns instance of NSRegularExpression class.
 */
+ (NSRegularExpression *)regexForControlLineNamed:(NSString *)lineName;

+ (NSString *)valueForKey:(NSString *)lineName inControl:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
