//
//  OglObject.m
//  AR-Quest
//
//  Created by Reto Marti on 08.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "OglObject.h"


@implementation OglObject

@synthesize name;
@synthesize numVertices, numNormals, numTexCoords, scaleFactor;
@synthesize vertices, normals, texCoords;
@synthesize material;


- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


- (void) dealloc {
    name = nil;
    
    free(vertices);
    free(normals);
    free(texCoords);
    
    vertices = nil;
    normals = nil;
    texCoords = nil;
    
    material = nil;
}


@end
