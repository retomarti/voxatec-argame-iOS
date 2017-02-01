//
//  LightShader.h
//  AR-Quest
//
//  Created by Reto Marti on 10.02.13.
//
//-------------------------------------------------------------------------------

#import "Shader.h"
#import "Light.h"


// GLSL param location references
typedef struct LightParamLoc {
    GLint positionHandle;
    GLint ambientColorHandle;
    GLint diffuseColorHandle;
    GLint specularColorHandle;
} LightParamLoc;


// Class implements common parameter handling for a Blinn-Phong shader with light reflections
@interface LightShader : Shader {
    @protected
    float vcLightPos[4];      // light position in view coords
    LightParamLoc lightLoc;   // uniform parameters
}

@property (nonatomic, strong) Light* light;   // Has to be set prior to the following method calls

// Overrides
- (void) setupInParams;
- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult;
- (void) pushInParams;

@end
