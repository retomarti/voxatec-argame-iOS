/*==============================================================================
 Copyright (c) 2012 VOXATEC.
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* depthMapVertexShader = MAKESTRING(

// Vertex shader for rendering the depth values to a texture.

attribute vec4 vertexPosition;

/// Uniform variables.
uniform mat4 mvpMatrix;
uniform mat4 mvMatrix;
uniform mat4 mMatrix;
uniform vec4 modelScale;

/// Varying variables.
varying vec4 vPosition;


/// Vertex shader entry.
void main ()
{
	vPosition = mvMatrix * mMatrix * vertexPosition * modelScale;
	gl_Position = mvpMatrix * vPosition;
}
);