/*==============================================================================
 Copyright (c) 2012 VOXATEC
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* materialVertexShader = MAKESTRING(
precision mediump float;

// Per vertex parameters setup by EAGLView
attribute vec4 vertexPosition;
attribute vec4 vertexNormal;
                    
// Per model parameters setup by EAGLView
uniform mat4 mvMatrix;
uniform mat4 mvpMatrix;
                                
// Out paramters for fragment shader
varying mat4 mvProjMatrix;
varying vec4 vpeye;
varying vec4 vneye;
                                    
void main()
{
    mvProjMatrix = mvpMatrix;
    vpeye = mvMatrix * vertexPosition; // mvMatrix * vertexPosition;
    mat4 normalMatrix = mvpMatrix;   // = transpose(inverse(mvMatrix));
    vneye = normalMatrix * vertexNormal;
    
    gl_Position = mvpMatrix * vertexPosition; // mvpMatrix * mvMatrix * vertexPosition;
}
);