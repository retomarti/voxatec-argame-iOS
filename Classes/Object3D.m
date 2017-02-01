//
//  Object3D.m
//  AR-Quest
//
//  Created by Reto Marti on 03.02.13.
//
//-------------------------------------------------------------------------------

#import "Object3D.h"


@implementation Object3D

@synthesize obj3DFileName, materialFileName, obj3DFile, materialFile, textureFiles, oglObjects;



- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


- (void) dealloc {
    obj3DFileName = nil;
    materialFileName = nil;
    obj3DFile = nil;
    materialFile = nil;
    textureFiles = nil;
    oglObjects = nil;
}

@end

