//
//  DepthMapShader.h
//  AR-Quest
//
//  Created by Reto Marti on 25.02.13.
//
//-------------------------------------------------------------------------------

#import "LightShader.h"

// Class used to create a depth map for a shadow map shader

@interface DepthMapShader : LightShader {
    
}

// Overrides
- (void) setupInParams;
- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult;
- (void) activate;
- (void) pushInParams;

@end
