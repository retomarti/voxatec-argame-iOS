//
//  Scene.m
//  AR-Quest
//
//  Created by Reto Marti on 02.02.13.
//
//----------------------------------------------------------------------------------------

#import "Scene.h"


@implementation Scene
    
@synthesize cache, object3D, riddle, light, targetImgName, targetImgXmlFile, targetImgDataFile;


- (id) init {
    self = [super init];
    
    if (self) {
        self.seqNr = 0;
    }
    
    return self;
}


- (void) dealloc {
    cache = nil;
    object3D = nil;
    light = nil;
    targetImgName = nil;
    targetImgXmlFile = nil;
    targetImgDataFile = nil;
}


@end
