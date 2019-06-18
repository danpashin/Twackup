//
//  TWPackage+Control.m
//  twackup
//
//  Created by Даниил on 18/06/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "TWPackage.h"
#import "TWRegex.h"

@implementation TWPackage (Control)

+ (NSString *)safeControlFromRAW:(NSString *)rawControl
{
    NSMutableString *mutableControl = [rawControl mutableCopy];
    
    NSRegularExpression *statusRegex = [TWRegex regexForControlLineNamed:@"Status"];
    [statusRegex replaceMatchesInString:mutableControl options:0 range:NSMakeRange(0, mutableControl.length) withTemplate:@""];
    
    NSRegularExpression *controlVersionRegex = [TWRegex regexForControlLineNamed:@"Config-Version"];
    [controlVersionRegex replaceMatchesInString:mutableControl options:0 range:NSMakeRange(0, mutableControl.length) withTemplate:@""];
    [mutableControl appendString:@"\n"];
    
    return mutableControl;
}

@end
