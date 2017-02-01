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


@end
