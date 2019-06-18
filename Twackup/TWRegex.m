//
//  TWRegex.m
//  twackup
//
//  Created by Даниил on 18/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "TWRegex.h"

@implementation TWRegex

+ (NSRegularExpression *)regexForControlLineNamed:(NSString *)lineName
{
    NSString *pattern = [NSString stringWithFormat:@"(%@: .*){1}(\n|\r|\f)*", lineName];
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:0
                                                       error:nil];
}

+ (NSString *)valueForKey:(NSString *)lineName inControl:(NSString *)string
{
    if (string.length == 0) {
        return nil;
    }
    
    NSRegularExpression *lineRegex = [self regexForControlLineNamed:lineName];
    NSTextCheckingResult *result = [lineRegex firstMatchInString:string options:0
                                                           range:NSMakeRange(0, string.length)];
    
    if (result) {
        NSMutableString *valueString = [[string substringWithRange:result.range] mutableCopy];
        
        NSRange keyStringRange = [valueString rangeOfString:@":"];
        if (keyStringRange.location != NSNotFound) {
            [valueString deleteCharactersInRange:NSMakeRange(0, keyStringRange.location + 1)];
        }
        
        
        NSRange valueStringRange = NSMakeRange(0, valueString.length);
        while ([valueString hasPrefix:@" "]) {
            [valueString deleteCharactersInRange:NSMakeRange(0, 1)];
            valueStringRange.length -= 1;
        }
        
        [valueString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:valueStringRange];
        valueStringRange.length = valueString.length;
        [valueString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:valueStringRange];
        
        return valueString;
    }
    
    return nil;
}


@end
