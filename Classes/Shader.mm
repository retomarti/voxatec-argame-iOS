//
//  Shader.m
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "Shader.h"
#import "ShaderUtils.h"
#import <QCAR/Tool.h>


namespace {
    // Model scale factor
    const float kObjectScale = 3.0f;
}


@implementation Shader

@synthesize oglObject;


- (id) init {
    self = [super init];
    
    if (self) {
        programID = 0;
        vertexHandle = 0;
        normalHandle = 0;
        mvpMatrixHandle = 0;
    }
    
    return self;
}


- (void) setupInParams {
    glGetError();
    
    // Bind uniform shader paramters
    NSAssert (programID > 0, @"Shader: program ID is 0");
    
    // attribute vec4 vertexPosition, vertexNormal
    vertexHandle         = glGetAttribLocation(programID, "vertexPosition");
    normalHandle         = glGetAttribLocation(programID, "vertexNormal");
    
    // uniform mat4 mvpMatrix
    mvpMatrixHandle      = glGetUniformLocation(programID, "mvpMatrix");

    ShaderUtils::checkGlError("Shader: setupInParams");
}


- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult {

    // mvMatrix
    mvMatrix = QCAR::Tool::convertPose2GLMatrix(aResult->getPose());
    
    // Calculate mvpMatrix from mvMatrix
    memcpy(&mvpMatrix.data[0], &mvMatrix.data[0], sizeof(QCAR::Matrix44F));
    
    // Some objects need to be translated (SHOULD BE PART OF 3D Object METADATA)
    // ShaderUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScale, &mvpMatrix.data[0]);
    
    ShaderUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale, &mvpMatrix.data[0]);
    ShaderUtils::multiplyMatrix(&projMatrix.data[0],
                                &mvpMatrix.data[0],
                                &mvpMatrix.data[0]);
    
    // normalMatrix
    memcpy(&normalMatrix.data[0], &mvpMatrix.data[0], sizeof(QCAR::Matrix44F));
    ShaderUtils::transposeMatrix(&normalMatrix.data[0]);
    ShaderUtils::invertMatrix(&normalMatrix.data[0]);

    ShaderUtils::checkGlError("Shader: calcAllInParams");
}


- (void) activate {
    glUseProgram(programID);
    ShaderUtils::checkGlError("Shader: activate");
}


- (void) deactivate {
    
}


- (void) pushInParams {
    glGetError();

    // attribute vec4 vertexPosition
    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)oglObject.vertices);
    ShaderUtils::checkGlError("pushInParams: setup vertexPosition");
    
    // attribute 'normalPosition'
    glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)oglObject.normals);
    ShaderUtils::checkGlError("pushInParams: setup normalPosition");

    // uniform mvpMatrix
    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&mvpMatrix.data[0]);
    ShaderUtils::checkGlError("pushInParams: setup mvpMatrix");

    ShaderUtils::checkGlError("Shader: pushInParams");
}


- (void) enableVertexParams {
    glGetError();

    glEnableVertexAttribArray(vertexHandle);
    glEnableVertexAttribArray(normalHandle);

    ShaderUtils::checkGlError("Shader: enableVertexParams");
}


- (void) drawScene {
    glGetError();

    // Draw model
    glDrawArrays(GL_TRIANGLES, 0, oglObject.numVertices);

    ShaderUtils::checkGlError("Shader: drawScene");
}


- (void) disableVertexParams {
    glGetError();

    glDisableVertexAttribArray(vertexHandle);
    glDisableVertexAttribArray(normalHandle);

    ShaderUtils::checkGlError("Shader: disableVertexParams");
}


@end
