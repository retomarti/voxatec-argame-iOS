//
//  ClipPlaneShader.h
//  AR-Quest
//
//  This shader is used to clip objects behind the image target plane.
//  Note: the rendered object must be in the image target plane but may
//  contain 'holes' through which the camera may see behind the image
//  target plane.
//
//  Created by Reto Marti on 29.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "MaterialShader.h"
#import <Foundation/Foundation.h>


@interface ClipPlaneShader : MaterialShader {
    @protected
    GLboolean depthMaskEnabled;
    GLboolean depthTestEnabled;
    GLenum depthTestFunc;
}

+ (ClipPlaneShader*) newShader;

@end
