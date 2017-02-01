//
//  Adventure.m
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


#import "Adventure.h"


@implementation Adventure

@synthesize stories;


- (id) init {
    self = [super init];
    
    if (self) {
        stories = [[NSMutableArray alloc] init];
    }
    
    return self;
}


+ (Adventure*) newAdventure {
    Adventure* adventure = [[Adventure alloc] init];
    return adventure;
}


- (void) dealloc {
    stories = nil;
}

@end
