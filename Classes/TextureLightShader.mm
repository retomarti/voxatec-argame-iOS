//
//  TextureLightShader.m
//  AR-Quest
//
//  Created by Reto Marti on 10.02.13.
//
//-------------------------------------------------------------------------------

#import "TextureLightShader.h"
#import "ShaderUtils.h"
#import "Texture.h"


@implementation TextureLightShader

- (id) init {
    self = [super init];
    
    if (self) {
        textureCoordHandle = 0;
        texSampler2DHandle = 0;
    }
    
    return self;
}


+ (TextureLightShader*) newShader {
    
    TextureLightShader* shader = [TextureLightShader new];
    return shader;
}


- (void) setupInParams {
    [super setupInParams];
    
    // attribute vec2 vertexTexCorrd
    textureCoordHandle   = glGetAttribLocation(programID, "vertexTexCoord");
    
    // uniform mat4 texSampler2D
    texSampler2DHandle   = glGetUniformLocation(programID, "texSampler2D");
    
    ShaderUtils::checkGlError("TextureShader: setupInParams");
}


- (void) pushInParams {
    [super pushInParams];
    
    // attribute vec2 vertexTexCoord
    Texture* texture = [self.oglObject.material textureMap];
    NSAssert(texture != nil, @"TextureLightShader encountered a material with no texture map");
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [texture textureID]);
    glVertexAttribPointer(textureCoordHandle,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          0,
                          (const GLvoid*)self.oglObject.texCoords);
    
    // uniform sampler2D texSampler2D
    glUniform1i(texSampler2DHandle, 0 /*L_TEXTURE0*/);
    glEnableVertexAttribArray(textureCoordHandle);
    
    ShaderUtils::checkGlError("TextureLightShader: pushInParams");
}


- (void) enableVertexParams {
    [super enableVertexParams];
    
    glEnableVertexAttribArray(textureCoordHandle);
}


- (void) disableVertexParams {
    [super disableVertexParams];
    
    glDisableVertexAttribArray(textureCoordHandle);
}

@end
