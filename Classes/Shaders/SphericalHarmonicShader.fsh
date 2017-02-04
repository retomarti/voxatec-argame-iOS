/*==============================================================================
 Copyright (c) 2012 VOXATEC Austria Research Center GmbH.
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* materialFragmentShader = MAKESTRING
(
precision mediump float;
                                                
// Per model input parameters from vertex shader
varying vec3 diffuseColor;
                                                
void main()
{
    gl_FragColor = vec4(diffuseColor, 1.0);
}
);
