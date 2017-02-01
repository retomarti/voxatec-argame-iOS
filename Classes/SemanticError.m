//
//  SemanticError.m
//  AR-Quest
//
//  Created by Reto Marti on 23.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "SemanticError.h"

@implementation SemanticError

@synthesize lineNr, colNr, errorMsg;


+ (SemanticError*) fileNotFoundError: (NSString*) fileName onLine: (NSUInteger) lineNr atColumn: (NSUInteger) colNr {
    
    SemanticError* error = [[SemanticError alloc] init];
    error.lineNr = lineNr;
    error.colNr = colNr;
    error.errorMsg = [NSString stringWithFormat: @"File not found error: didn't find file %s", [fileName UTF8String]];
    
    return error;
}

@end
