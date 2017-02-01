//
//  SymObject.h
//  AR-Quest
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

// Object types
typedef enum SymObjectType {
	VARIABLE,			// Variable object
	TYPE,				// Type object
	FUNCTION,			// Function object
	PARAM				// Parameter object
} SymObjectType;


/*------------------------------------------------------------
  Class SymObject: instances of this class represent symbols
  of the C language, e.g. variables, types, functions, parameters.
  They are encountered by the C parser and temporarily stored
  in a symbol table.
-------------------------------------------------------------*/

@interface SymObject : NSObject {
	@protected
	NSString* name;
	SymObjectType type;
}
// Object creation
+ (SymObject*) newVariable: (NSString*) aVariableName;
+ (SymObject*) newType: (NSString*) aTypeName;
+ (SymObject*) newFunction: (NSString*) aFunctionName;
+ (SymObject*) newParameter: (NSString*) aParamName;

// Accessors
- (SymObjectType) type;
- (NSString*) name;
- (BOOL) isVariable;
- (BOOL) isType;
- (BOOL) isFunction;
- (BOOL) isParam;
	
@end
