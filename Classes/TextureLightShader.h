//
//  TextureLightShader.h
//  AR-Quest
//
//  Created by Reto Marti on 10.02.13.
//
//-------------------------------------------------------------------------------

#import "MaterialShader.h"

@interface TextureLightShader : MaterialShader {
    @protected
    // uniform parameters
    GLint textureCoordHandle;
    GLint texSampler2DHandle;
}

+ (TextureLightShader*) newShader;

// Overrides
- (void) setupInParams;
- (void) pushInParams;

@end
