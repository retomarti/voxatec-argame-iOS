/*==============================================================================
 Copyright (c) 2012 VOXATEC Austria Research Center GmbH.
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* clipPlaneFragmentShader = MAKESTRING(
precision mediump float;
                                                
struct Material {
    vec4 ambientCoeff;
    vec4 diffuseCoeff;
    vec4 specularCoeff;
    float specularExp;
    float shininess;
};
                                                
struct Light {
    vec4 position;
    vec4 ambientColor;
    vec4 diffuseColor;
    vec4 specularColor;
};
                                                
// Per model shader paramters
uniform mat4 mvMatrix;
uniform Material material;
uniform Light light;
                                                
varying vec4 vpeye;     // fragment position in eye coords
varying vec4 vneye;     // surface normal in eye coords
                                                
void main()
{    
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
                                                );
