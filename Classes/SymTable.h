//
//  SymTable.h
//  AR-Quest
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "SymObject.h"

/*------------------------------------------------------------
  Class SymTable: instances of this class represent symbol
  tables storing symbol objects that have been encountered
  during a parsing process. Due to the block structure of 
  the C language, symbols are stored in nested contexts
  (stack of symbol contexts). 
-------------------------------------------------------------*/

@interface SymTable : NSObject {
	@protected
	NSMutableArray* stack;	// Stack with context dictionaries containing the SymObjects
}
// Table creation
+ (SymTable*) newTable;

// Context creation
- (void) openNewSymContext;
- (void) closeSymContext;

// SymObject registration
- (void) addSymObject: (SymObject*) aObject;	// add object to current symbol context

// SymObject retrieval
- (SymObject*) symObjectWithName: (NSString*) aName;
	
@end
