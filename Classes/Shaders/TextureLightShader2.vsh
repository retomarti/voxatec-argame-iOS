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
                                             
// Out paramters for fragment shader
varying vec2 texCoord;
varying vec4 normal;
                                             
void main()
{
    gl_Position = mvpMatrix * vertexPosition;

    normal = mvMatrix * vertexNormal;
    normal = normalize(normal);
    texCoord = vertexTexCoord;
}
);
