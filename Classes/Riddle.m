//
//  Riddle.m
//  AR-Quest
//
//  Created by Reto Marti on 04/02/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Riddle.h"


@implementation Riddle

@synthesize challenge, response;


- (Boolean) isResponseCorrect: (NSString*) aResponse {
    NSComparisonResult res = [response caseInsensitiveCompare: aResponse];
    return (res == NSOrderedSame);
}

@end