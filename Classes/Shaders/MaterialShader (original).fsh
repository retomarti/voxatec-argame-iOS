/*==============================================================================
 Copyright (c) 2012 VOXATEC Austria Research Center GmbH.
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/


const char* materialFragmentShader = MAKESTRING(
precision mediump float;

struct Material {
    vec4 ambientCoeff;
    vec4 diffuseCoeff;
    vec4 specularCoeff;
    float shininess;
};

struct Light {
    vec4 position;
    vec4 ambientColor;
    vec4 diffuseColor;
    vec4 specularColor;
};

uniform Material material;
uniform Light light;

varying mat4 mvProjMatrix;
varying vec4 vpeye;     // fragment position in eye coords
varying vec4 vneye;     // surface normal in eye coords

void main()
{
    vec4 n_eye = normalize(vneye);                              // normalise just to be on the safe side
    vec4 lightPos = light.position;                             // project light into eye coordinates
    vec4 s_eye = normalize(lightPos - vpeye);                   // get direction from surface fragment to light
    vec4 v_eye = normalize(-vpeye);                             // get direction from surface fragment to camera
    vec4 h_eye = normalize(v_eye + s_eye);                      // Blinn's half-way vector
    
    vec4 Ia = light.ambientColor * material.ambientCoeff; 
    float Es= 2.0;                                              // Specular exponent (use to tune specular reflection)
    vec4 Id = light.diffuseColor * material.diffuseCoeff * max(dot(s_eye, n_eye), 0.0); // no negative colours -> max()
    vec4 Is = light.specularColor * material.specularCoeff * pow(max(dot(h_eye, n_eye), 0.0), Es);    
    gl_FragColor = (Ia + Id + Is);
}
);