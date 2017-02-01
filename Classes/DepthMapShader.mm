//
//  DepthMapShader.m
//  AR-Quest
//
//  Created by Reto Marti on 25.02.13.
//
//-------------------------------------------------------------------------------

#import "DepthMapShader.h"

@implementation DepthMapShader


// Overrides

- (void) setupInParams {
    [super setupInParams];
}


- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult {
    [super calcInParams: projMatrix forTrackable: aResult];
}


- (void) activate {
    [super activate];
}


- (void) pushInParams {
    [super pushInParams];
}


@end
