//
//  LightShader.m
//  AR-Quest
//
//  Created by Reto Marti on 10.02.13.
//
//-------------------------------------------------------------------------------

#import "LightShader.h"
#import "ShaderUtils.h"


@implementation LightShader


- (id) init {
    self = [super init];
    
    if (self) {
        mvMatrixHandle = 0;
    }
    
    return self;
}


- (void) setupInParams {
    [super setupInParams];
    
    mvMatrixHandle               = glGetUniformLocation(programID, "mvMatrix");
    
    // light
    lightLoc.positionHandle         = glGetUniformLocation(programID, "light.position");
    ShaderUtils::checkGlError("setupInParams: position");
    lightLoc.ambientColorHandle     = glGetUniformLocation(programID, "light.ambientColor");
    ShaderUtils::checkGlError("setupInParams: ambientColor");
    lightLoc.diffuseColorHandle     = glGetUniformLocation(programID, "light.diffuseColor");
    ShaderUtils::checkGlError("setupInParams: diffuseColor");
    lightLoc.specularColorHandle    = glGetUniformLocation(programID, "light.specularColor");
    ShaderUtils::checkGlError("setupInParams: specularColor");
    
    // normalMatrix
    normalMatrixHandle           = glGetUniformLocation(programID, "normalMatrix");
    
}


- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult {
    [super calcInParams: projMatrix forTrackable: aResult];
    
    // Transform light position fromt world to view coords
    ShaderUtils::multiplyVector(&self.light->position[0], &mvMatrix.data[0], &vcLightPos[0]);
}


- (void) pushLightingParam {
    
    // glGetError();
    
    // vcLightPos
    glUniform4fv(lightLoc.positionHandle, 1, vcLightPos);
    ShaderUtils::checkGlError("setupLighting: position");
    
    // light.ambientColor
    glUniform4fv(lightLoc.ambientColorHandle, 1, self.light->ambientColor);
    ShaderUtils::checkGlError("setupLighting: : ambientColor");
    
    // light.diffuseColor
    glUniform4fv(lightLoc.diffuseColorHandle, 1, self.light->diffuseColor);
    ShaderUtils::checkGlError("setupLighting: diffuseColor");
    
    // light.specularColor
    glUniform4fv(lightLoc.specularColorHandle, 1, self.light->specularColor);
    ShaderUtils::checkGlError("setupLight: specularColor");
}


- (void) pushInParams {
    [super pushInParams];
    
    // uniform mat4 mvMatrix
    glUniformMatrix4fv(mvMatrixHandle, 1, GL_FALSE, (const GLfloat*)&mvMatrix.data[0]);
    ShaderUtils::checkGlError("pushInParams: setup mvMatrix");
    
    // uniform mat4 normalMatrix
    glUniformMatrix4fv(normalMatrixHandle, 1, GL_FALSE, (const GLfloat*)&normalMatrix.data[0]);
    ShaderUtils::checkGlError("pushInParams: setup normalMatrix");
    
    // uniform Light light
    [self pushLightingParam];
}



@end
