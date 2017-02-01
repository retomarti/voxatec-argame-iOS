/*==============================================================================
 BLINN-PHONG Shader
 -------------------------------------------------------------------------------
 Copyright (c) 2012 VOXATEC
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* textureLightFragmentShader = MAKESTRING(
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
uniform mat4      mvMatrix;
uniform mat4      mvpMatrix;
                                                    
uniform Material  material;
uniform Light     light;
uniform sampler2D texSampler2D;
                                               
// Per fragment shader paramters (coming from vertex shader)
varying vec2 texCoord;
varying vec4 normal;
                                               
void main()
{
    vec3 n        = normalize(normal.xyz);
    vec3 lightDir = vec3(0.0, 0.0, -1.0);
    
    vec4 Iamb     = light.ambientColor * material.ambientCoeff;
    vec4 Idiff    = light.diffuseColor * material.diffuseCoeff * max(dot(n, lightDir), 0.0);
    vec4 Ispec    = light.specularColor * material.specularCoeff; // * pow(max(dot(h_eye, n_eye), 0.0), material.specularExp);
    vec4 texColor = texture2D(texSampler2D, texCoord);
    
    gl_FragColor  = (Iamb + Idiff + Ispec) * texColor;
}
);
