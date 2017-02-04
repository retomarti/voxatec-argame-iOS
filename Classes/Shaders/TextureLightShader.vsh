/*==============================================================================
 Copyright (c) 2012 VOXATEC
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* textureLightVertexShader = MAKESTRING(
precision mediump float;

// Per vertex shader parameters
attribute vec4 vertexPosition;
attribute vec4 vertexNormal;
attribute vec2 vertexTexCoord;
                                             
// Per model parameters setup by EAGLView
uniform mat4 mvMatrix;
uniform mat4 mvpMatrix;
uniform mat4 normalMatrix;
                                             
// Out parameters for fragment shader
varying vec4 vpeye;      // vertex position in eye coords
varying vec4 vneye;      // vertex normal in eye coords
varying vec2 texCoord;
varying vec4 normal;
                                             
void main()
{
    gl_Position = mvpMatrix * vertexPosition;

    vpeye = mvMatrix * vertexPosition; 
    vneye = normalMatrix * vertexNormal;
    normal = vertexNormal;
    texCoord = vertexTexCoord;
}
);
