//
//  control_parser.h
//  DeLoader
//
//  Created by Даниил on 10/04/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import  <Foundation/Foundation.h>

@class NSString;

NS_ASSUME_NONNULL_BEGIN

/**
 Gets line between positions in file.
 
 @param start_pos Start position. Measured in bytes.
 @param end_pos End position. Measured in bytes.
 @param file The handle of the file for which the string is retrieved.
 @return Returns a string with null-terminated symbol. In MUST be freed when done.
 */
char * _Nullable fgetbetween(const long start_pos, const long end_pos, FILE *file);

/**
 Performs packages file parsing end calls handler every time finding new package.

 @param path Path to file.
 @param handler Handler that calls every time function find package.
 @return Returns true when operation was success.
 */
bool parse_packages_file(const char *path, void (^handler)(NSString *package));

NS_ASSUME_NONNULL_END
