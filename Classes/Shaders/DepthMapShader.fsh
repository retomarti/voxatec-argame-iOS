/*==============================================================================
 Copyright (c) 2012 VOXATEC.
 All Rights Reserved.
 VOXATEC Confidential and Proprietary
 ==============================================================================*/

const char* depthMapVertexShader = MAKESTRING(

precision highp float;

// Linear depth calculation.
                         
const float Near = 1.0;
const float Far = 30.0;
const float LinearDepthConstant = 1.0 / (Far - Near);

// Out paramters for fragment shader
varying vec4 vPosition;

// Pack a floating point value into an RGBA (32bpp).
vec4 pack (float depth)
{
	const vec4 bias = vec4(1.0 / 255.0,
                           1.0 / 255.0,
                           1.0 / 255.0,
                           0.0);

	float r = depth;
	float g = fract(r * 255.0);
	float b = fract(g * 255.0);
	float a = fract(b * 255.0);
	vec4 colour = vec4(r, g, b, a);
	
	return colour - (colour.yzww * bias);
}


// Pack a floating point value into a vec2 (16bpp).
vec2 packHalf (float depth)
{
	const vec2 bias = vec2(1.0 / 255.0, 0.0);
							
	vec2 colour = vec2(depth, fract(depth * 255.0));
	return colour - (colour.yy * bias);
}


void main ()
{
	// Linear depth
	float linearDepth = length(vPosition) * LinearDepthConstant;
	
	if ( FilterType == 2 )
	{
		//
		// Variance Shadow Map Code
		// Encode moments to RG/BA
		//
		//float moment1 = gl_FragCoord.z;
		float moment1 = linearDepth;
		float moment2 = moment1 * moment1;
		gl_FragColor = vec4(packHalf(moment1), packHalf(moment2));
	}
	else
	{
		//
		// Classic shadow mapping algorithm.
		// Store screen-space z-coordinate or linear depth value (better precision)
		//
		//gl_FragColor = pack(gl_FragCoord.z);
		gl_FragColor = pack(linearDepth);
	}
}
);