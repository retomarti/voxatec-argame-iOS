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


// Initialisation -------------------------------------------------------------------------

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


// NSCoding protocol ----------------------------------------------------------------------

- (instancetype) initWithCoder: (NSCoder*) decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        // seqNr
        self.seqNr = (int) [decoder decodeIntegerForKey: @"seqNr"];
        // We don't store the rest of scene (only needed for game status persistency)
    }
    return self;
}


- (void) encodeWithCoder: (NSCoder*) encoder {
    [super encodeWithCoder: encoder];

    // seqNr
    [encoder encodeInteger: (NSInteger) self.seqNr forKey: @"seqNr"];
}


@end
