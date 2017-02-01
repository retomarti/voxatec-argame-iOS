//
//  Cache.m
//  AR-Quest
//
//  Created by Reto Marti on 13/05/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Cache.h"


@implementation Cache

@synthesize street, gpsCoordinates, cacheGroupId, targetImageName;


- (id) init {
    self = [super init];

    return self;
}


- (void) dealloc {
    street = nil;
    cacheGroupId = nil;
    targetImageName = nil;
}


// MKAnnotation methods

- (void) setCoordinate: (CLLocationCoordinate2D) newCoordinate {
    gpsCoordinates = newCoordinate;
}

- (CLLocationCoordinate2D) coordinate {
    return gpsCoordinates;
}


- (NSString*) title {
    return self.name;
}


@end
