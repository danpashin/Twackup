//
//  control_parser.m
//  DeLoader
//
//  Created by Даниил on 10/04/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "packages_parser.h"

char *fgetbetween(const long start_pos, const long end_pos, FILE *file)
{
    @autoreleasepool {
        if (end_pos - start_pos <= 1 || !file) {
            return NULL;
        }
        
        const long origin_pos = ftell(file);
        
        fseek(file, start_pos, SEEK_SET);
        
        const long buffer_bytes = (end_pos - start_pos + 1);
        char *buffer = malloc((unsigned long)buffer_bytes);
        if (!buffer) {
            return NULL;
        }
        
        bzero(buffer, buffer_bytes);
        
        char chr;
        long buffer_current_length = 0;
        while (buffer_current_length < buffer_bytes - 1 && (chr = (char)fgetc(file)) != EOF) {
            buffer[buffer_current_length++] = chr;
        }
        
        fseek(file, origin_pos, SEEK_SET);
        
        while (buffer[--buffer_current_length] == '\n') {
            buffer[buffer_current_length] = '\0';
        }
        
        return buffer;
    }
}

bool parse_packages_file(const char *path, void (^handler)(NSString *package, bool *stop))
{
    if (!path)
        return false;
    
    FILE *file = fopen(path, "r");
    if (!file)
        return false;
    
    char *line = NULL;
    
    size_t line_size = 0;
    long package_start_position = 0;
    long package_end_position = 0;
    
    bool stop = false;
    while (!stop) {
        getline(&line, &line_size, file);
        stop = feof(file);
        
        if (line[0] == '\n' || stop) {
            package_end_position = ftell(file) - 1;
            if (stop) {
                package_end_position++;
            }
            
            char *substr = fgetbetween(package_start_position, package_end_position, file);
            if (substr) {
                const unsigned long length = strlen(substr);
                NSString *package = [[NSString alloc] initWithBytesNoCopy:substr length:length
                                                                 encoding:NSASCIIStringEncoding freeWhenDone:NO];
                
                if (package) {
                    package = [[NSString alloc] initWithBytesNoCopy:substr length:length
                                                           encoding:NSASCIIStringEncoding freeWhenDone:YES];
                    handler(package, &stop);
                } else {
                    package = [[NSString alloc] initWithBytesNoCopy:substr length:length
                                                           encoding:NSUTF8StringEncoding freeWhenDone:YES];
                    handler(package, &stop);
                }
            }
            
            package_start_position = ftell(file);
        }
    }
    
    if (line)
        free(line);
    
    fclose(file);
    
    return true;
}

