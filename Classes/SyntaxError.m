//
//  SyntaxError.m
//  RoboBrain
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//

#import "SyntaxError.h"


@implementation SyntaxError

	// Creation
	
    + (SyntaxError*) newErrorOnLine: (NSUInteger) aLineNr
                           atColumn: (NSUInteger) aColNr
                        expectedSym: (NSString*) expSym
                        detectedSym: (NSString*) detSym {
        
        SyntaxError* aError = [[SyntaxError alloc] initWithDomain: @"Syntax error" code: 0 userInfo: nil];
        [aError setLineNr: aLineNr];
        [aError setColNr: aColNr];
        
        // Error message
        NSString* message = [NSString stringWithFormat:
                             @"Syntax error: expected symbol %s, found %s (line %lu, col %lu)",
                             [expSym UTF8String],
                             [detSym UTF8String],
                             (unsigned long)aLineNr,
                                aColNr];
        [aError setErrorMsg: message];
        
        return aError;
    }


	// Accessors
	
	- (void) setLineNr: (NSUInteger) aLineNr {
		lineNr = aLineNr;
	}
	
	
	- (NSUInteger) lineNr {	
		return lineNr;
	}
	
	
	- (void) setColNr: (NSUInteger) aColNr {
		colNr = aColNr;
	}
	
	
	- (NSUInteger) colNr {
		return colNr;
	}
	
	
	- (void) setErrorMsg: (NSString*) aErrorMsg {
		errorMsg = aErrorMsg;
	}
	
	
	- (NSString*) errorMsg {
		return errorMsg;
	}

    - (NSString*) localizedDescription {
        return [self errorMsg];
    }

@end
