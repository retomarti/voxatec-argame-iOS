//
//  ARObject.m
//  AR-Quest
//
//  Created by Reto Marti on 13/05/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


#import "ARObject.h"


@implementation ARObject

@synthesize id;


// Initialisation ------------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


- (void) dealloc {
}


// NSCoding protocol ----------------------------------------------------------------------

- (instancetype) initWithCoder: (NSCoder*) decoder {
    self = [self init];
    
    if (self != nil) {
        self.id = [decoder decodeObjectForKey: @"id"];
    }
    return self;
}


- (void) encodeWithCoder: (NSCoder*) encoder {
    // version
    [encoder encodeObject: self.id forKey: @"id"];
}


@end
