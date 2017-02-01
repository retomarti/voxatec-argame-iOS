//
//  SymTable.m
//  RoboBrain
//
//  Created by Reto Marti on 29.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "SymTable.h"


@implementation SymTable

// Table creation ---------------------------------------------------------------------------------------------------------

- (void) setStack: (NSMutableArray*) aStack {
    stack = aStack;
}


- (id) init {
    self = [super init];
    
    if (self) {
        NSMutableArray* aStack = [[NSMutableArray alloc] init];
        [self setStack: aStack];
    }
    
    return self;
}


- (void) dealloc {
    stack = nil;
}


+ (SymTable*) newTable {
    SymTable* aTable = [[SymTable alloc] init];
    return aTable;
}



// Context creation -------------------------------------------------------------------------------------------------------

- (void) openNewSymContext {
    NSMutableDictionary* aSymContext = [[NSMutableDictionary alloc] init];
    [stack addObject: aSymContext];
}


- (void) closeSymContext {
    [stack removeLastObject];
}



// SymObject registration -------------------------------------------------------------------------------------------------

- (void) addSymObject: (SymObject*) aObject {
    NSMutableDictionary* currSymContext = [stack lastObject];
    
    NSAssert(currSymContext != nil, @"symbol context may not be nil");
    NSAssert(aObject != nil, @"a symbol object may not be nil");
    
    [currSymContext setObject: aObject forKey: [aObject name]];
}



// SymObject retrieval ----------------------------------------------------------------------------------------------------

- (SymObject*) symObjectWithName: (NSString*) aName {
    NSUInteger stackDepth = [stack count];
    SymObject* theObject = nil;
    NSUInteger sp = stackDepth;
    
    do {
        sp--;
        NSMutableDictionary* currSymContext = [stack objectAtIndex: sp];
        theObject = [currSymContext objectForKey: aName];
    } while (theObject == nil && sp > 0);
    
    return theObject;
}

@end
