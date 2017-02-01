//
//  TextureShader.m
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "TextureShader.h"
#import "ShaderUtils.h"
#import "Material.h"


@implementation TextureShader


- (id) init {
    self = [super init];
    
    if (self) {
        textureCoordHandle = 0;
        texSampler2DHandle = 0;
    }
    
    return self;
}


+ (TextureShader*) newShader {
    
    TextureShader* shader = [[TextureShader alloc] init];
    return shader;
}


- (void) setupInParams {
    [super setupInParams];
    
    // attribute vec2 vertexTexCorrd
    textureCoordHandle   = glGetAttribLocation(programID, "vertexTexCoord");
    
    // uniform mat4 
    texSampler2DHandle   = glGetUniformLocation(programID, "texSampler2D");
    
    ShaderUtils::checkGlError("TextureShader: setupInParams");

}


- (void) pushInParams {
    [super pushInParams];
    
    Material* material = self.oglObject.material;
    Texture* texture = [material textureMap];
    
    // attribute vec2 vertexTexCoord
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
    
    ShaderUtils::checkGlError("TextureShader: pushInParams");
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
