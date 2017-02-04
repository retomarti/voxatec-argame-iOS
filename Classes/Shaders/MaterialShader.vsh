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
uniform mat4 normalMatrix;
                                
// Out paramters for fragment shader
varying vec4 vpeye;
varying vec4 vneye;

                                    
void main()
{
    vpeye = mvMatrix * vertexPosition;        // mvMatrix * vertexPosition;
    vneye = normalMatrix * vertexNormal;      // normalMatrix = mvMatrix;
    
    gl_Position = mvpMatrix * vertexPosition; 
}
);
