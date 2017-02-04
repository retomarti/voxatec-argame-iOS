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
                                               
// Per model shader parameters
uniform mat4      mvMatrix;
uniform Material  material;
uniform Light     light;
uniform sampler2D texSampler2D;
                                               
// Per fragment shader parameters (coming from vertex shader)
varying vec4 vpeye;
varying vec4 vneye;
varying vec2 texCoord;
varying vec4 normal;
                                                    
void main()
{    
    vec4 n_eye    = normalize(vneye);                              // normalize just to be on the safe side
    vec4 s_eye    = normalize(light.position - vpeye);             // get direction from surface fragment to light
    vec4 v_eye    = normalize(-vpeye);                             // get direction from surface fragment to camera
    vec4 h_eye    = normalize(v_eye + s_eye);                      // Blinn's half-way vector

    vec4 texColor = texture2D(texSampler2D, texCoord);
    
    vec4 Iamb     = light.ambientColor * material.ambientCoeff;
    vec4 Idiff    = light.diffuseColor * material.diffuseCoeff * max(dot(s_eye, n_eye), 0.0);
    vec4 Ispec    = light.specularColor * material.specularCoeff * pow(max(dot(h_eye, n_eye), 0.0), material.specularExp);
        
    gl_FragColor  = (Iamb + Idiff + Ispec) * texColor;
}
);
