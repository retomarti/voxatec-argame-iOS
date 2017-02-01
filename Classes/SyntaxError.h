//
//  SyntaxError.h
//  RoboBrain
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

/*------------------------------------------------------------
  Class SyntaxError: instances of this class represent syntax
  errors with the corresponding information needed to display
  the error in the source text.
-------------------------------------------------------------*/

@interface SyntaxError : NSError {
	@protected
	NSUInteger lineNr;
	NSUInteger colNr;
	NSString* errorMsg;
}

// Creation
+ (SyntaxError*) newErrorOnLine: (NSUInteger) aLineNr
                       atColumn: (NSUInteger) aColNr
                    expectedSym: (NSString*) expSym
                    detectedSym: (NSString*) detSym;

// Accessors
- (void) setLineNr: (NSUInteger) aLineNr;
- (NSUInteger) lineNr;
- (void) setColNr: (NSUInteger) aColNr;
- (NSUInteger) colNr;
- (void) setErrorMsg: (NSString*) aErrorMsg;
- (NSString*) errorMsg;
	
@end
