//
//  SymObject.m
//  RoboBrain
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "SymObject.h"


@implementation SymObject

// Object creation ----------------------------------------------------------------------------------------

- (void) setName: (NSString*) aName {
    name = aName;
}


- (void) setType: (SymObjectType) aType {
    type = aType;
}


- (id) initWithName: (NSString*) aName type: (SymObjectType) aType {
    self = [self init];
    
    if (self) {
        [self setName: aName];
        [self setType: aType];
    }
    
    return self;
}


+ (SymObject*) newVariable: (NSString*) aVariableName {
    NSAssert(aVariableName != nil && [aVariableName length] > 0, @"a variable object may not have a zero length name");
    SymObject* aVar = [[SymObject alloc] initWithName: aVariableName type: VARIABLE];
    return aVar;
}


+ (SymObject*) newType: (NSString*) aTypeName {
    NSAssert(aTypeName != nil && [aTypeName length] > 0, @"a type object may not have a zero length name");
    SymObject* aType = [[SymObject alloc] initWithName: aTypeName type: TYPE];
    return aType;
}


+ (SymObject*) newFunction: (NSString*) aFunctionName {
    NSAssert(aFunctionName != nil && [aFunctionName length] > 0, @"a function object may not have a zero length name");
    SymObject* aFunction = [[SymObject alloc] initWithName: aFunctionName type: FUNCTION];
    return aFunction;
}


+ (SymObject*) newParameter: (NSString*) aParamName {
    NSAssert(aParamName != nil && [aParamName length] > 0, @"a parameter object may not have a zero length name");
    SymObject* aParam = [[SymObject alloc] initWithName: aParamName type: PARAM];
    return aParam;
}



// Accessors  ----------------------------------------------------------------------------------------

- (SymObjectType) type {
    return type;
}


- (NSString*) name {
    return name;
}


- (BOOL) isVariable {
    return type == VARIABLE;
}


- (BOOL) isType {
    return type == TYPE;
}


- (BOOL) isFunction {
    return type == FUNCTION;
}


- (BOOL) isParam {
    return type == PARAM;
}


@end
