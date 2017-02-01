//
//  ClipPlaneShader.m
//  AR-Quest
//
//  Created by Reto Marti on 29.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "ClipPlaneShader.h"
#import "ShaderUtils.h"

@implementation ClipPlaneShader


+ (ClipPlaneShader*) newShader {
    ClipPlaneShader* shader = [ClipPlaneShader new];
    
    return shader;
}


- (void) activate {
    [super activate];
    
    // Disable writing into color buffer
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    
    depthTestEnabled = GL_FALSE;
    depthMaskEnabled = GL_FALSE;
    
    glGetBooleanv(GL_DEPTH_WRITEMASK, &depthMaskEnabled);
    glGetBooleanv(GL_DEPTH_TEST, &depthTestEnabled);
    
    // Make sure writing into depth buffer is on
    // glDepthMask(GL_TRUE);
    // glEnable(GL_DEPTH_TEST);
    // glDepthFunc(GL_LEQUAL);
    
    ShaderUtils::checkGlError("ClipPlaneShader: activate");
}


- (void) deactivate {
    [super deactivate];
    
    // Enable writing into color buffer
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    // Reset previous OpenGL properties
    // glDepthMask(depthMaskEnabled);
    // glDepthFunc(depthTestFunc);

    ShaderUtils::checkGlError("ClipPlaneShader: deactivate");
}


@end
