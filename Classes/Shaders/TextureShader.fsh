/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/


const char* textureFragmentShader = MAKESTRING(
precision mediump float;

// Per model shader paramters
uniform sampler2D texSampler2D;

// Per fragment shader paramters
varying vec2 texCoord;

void main()
{
    gl_FragColor = texture2D(texSampler2D, texCoord);
}
);
