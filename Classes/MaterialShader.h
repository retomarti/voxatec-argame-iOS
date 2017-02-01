//
//  MaterialShader.h
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "LightShader.h"


typedef struct MaterialParamLoc {
    GLint ambientCoeffHandle;  
    GLint diffuseCoeffHandle;
    GLint specularCoeffHandle;
    GLint specularExpHandle;
    GLint shininessHandle;
} MaterialParamLoc;


@interface MaterialShader : LightShader {
    @protected
    MaterialParamLoc material;   
}

+ (MaterialShader*) newShader;

// Overrides
- (void) setupInParams;
- (void) pushInParams;

@end
