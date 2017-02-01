//
//  TextureShader.h
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "Shader.h"

@interface TextureShader : Shader {
    @protected
    // uniform parameters
    GLint textureCoordHandle;
    GLint texSampler2DHandle;
}

+ (TextureShader*) newShader;

// Overrides
- (void) setupInParams;
- (void) pushInParams;

@end
