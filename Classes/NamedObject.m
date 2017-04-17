//
//  NamedObject.m
//  AR-Quest
//
//  Created by Reto Marti on 13/05/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "NamedObject.h"


@implementation NamedObject

@synthesize name, text;


// Initialisation ------------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


- (void) dealloc {
    name = nil;
    text = nil;
}


// NSCoding protocol ----------------------------------------------------------------------

- (instancetype) initWithCoder: (NSCoder*) decoder {
    self = [super initWithCoder: decoder];
    
    if (self != nil) {
        self.name = [decoder decodeObjectForKey: @"name"];
        self.text = [decoder decodeObjectForKey: @"text"];
    }
    return self;
}


- (void) encodeWithCoder: (NSCoder*) encoder {
    [super encodeWithCoder: encoder];

    // version
    [encoder encodeObject: self.name forKey: @"name"];
    [encoder encodeObject: self.text forKey: @"text"];
}


@end
