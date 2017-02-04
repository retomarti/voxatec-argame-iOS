/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

const char* textureVertexShader = MAKESTRING
(
precision mediump float;

// Per vertex shader parameters
attribute vec4 vertexPosition;
attribute vec4 vertexNormal;
attribute vec2 vertexTexCoord;

// Per model shader parameters
uniform mat4 mvpMatrix;
uniform mat4 mvMatrix;
                         
// Out paramters for fragment shader
varying vec2 texCoord;
varying vec4 normal;

void main()
{
    gl_Position = mvpMatrix * vertexPosition;
    normal = vertexNormal;
    texCoord = vertexTexCoord;
}
);
