//
//  Shader.h
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "OglObject.h"
#import <QCAR/QCAR.h>
#import <QCAR/Matrices.h>
#import <QCAR/TrackableResult.h>


@interface Shader : NSObject {
    @public
    GLuint programID;
    
    @protected
    // parameter values
    QCAR::Matrix44F mvMatrix;       // model view matrix
    QCAR::Matrix44F mvpMatrix;      // model view projection matrix
    QCAR::Matrix44F normalMatrix;   // model view projection matrix
    
    // shader param locations
    GLint vertexHandle;
    GLint normalHandle;
    GLint mvMatrixHandle;
    GLint mvpMatrixHandle;
    GLint normalMatrixHandle;
}

@property (nonatomic, strong) OglObject* oglObject;  // Has to be defined prior to call of following methods

- (void) activate;
- (void) setupInParams;
- (void) calcInParams: (QCAR::Matrix44F) projMatrix forTrackable: (const QCAR::TrackableResult*) aResult;
- (void) pushInParams;
- (void) enableVertexParams;
- (void) drawScene;
- (void) disableVertexParams;
- (void) deactivate;

@end
