/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <QCAR/QCAR.h>
#import <QCAR/State.h>
#import <QCAR/Tool.h>
#import <QCAR/Renderer.h>
#import <QCAR/TrackableResult.h>
#import <QCAR/VideoBackgroundConfig.h>

#import "TourManager.h"

#import "ImageTargetsEAGLView.h"
#import "Texture.h"

#import "TourManager.h"
#import "Scene.h"
#import "Texture.h"
#import "Object3D.h"

// Shaders
#import "Shader.h"
#import "ShaderUtils.h"
#define MAKESTRING(x) #x
#import "Shaders/TextureShader.vsh"
#import "Shaders/TextureShader.fsh"
#import "Shaders/TextureLightShader.vsh"
#import "Shaders/TextureLightShader.fsh"
#import "Shaders/MaterialShader.vsh"
#import "Shaders/MaterialShader.fsh"
#import "Shaders/ClipPlaneShader.vsh"
#import "Shaders/ClipPlaneShader.fsh"

#define kClipObjectMaterial @"Clip-Plane"



//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the QCAR camera, which causes QCAR to locate our EAGLView and start
//    the render thread.
// 3) QCAR calls our renderFrameQCAR method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
}


@interface ImageTargetsEAGLView (PrivateMethods)

- (void) initShaders;
- (void) createFramebuffer;
- (void) deleteFramebuffer;
- (void) setFramebuffer;
- (BOOL) presentFramebuffer;

@end


@implementation ImageTargetsEAGLView

@synthesize vapp = vapp, scene = _scene, delegate;


// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer

+ (Class) layerClass {
    return [CAEAGLLayer class];
}


// Override of AR_EAGLVIEW methods



//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id) initWithFrame: (CGRect) frame appSession: (SampleApplicationSession*) app {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:2.0f];
        }
        
        // Create the OpenGL ES context
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        // The EAGLContext must be set for each thread that wishes to use it.
        // Set it the first time this method is called (on the main thread)
        if (context != [EAGLContext currentContext]) {
            [EAGLContext setCurrentContext:context];
        }
        
        offTargetTrackingEnabled = NO;
        trackingScene = NO;
        
        [self initShaders];
    }
    
    return self;
}


- (void) dealloc {
    
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext: nil];
    }

    for (int i = 0; i < kNumAugmentationTextures; ++i) {
        augmentationTexture[i] = nil;
    }
    
    _scene = nil;
    delegate = nil;
}


- (void) setScene: (Scene*) aScene {
    _scene = aScene;
    
    // Textures require access to the story object
    if (aScene != nil) {
        [self setupTexturesOfScene: aScene];
        
        // Reorder scene objects for correct rendering order
        [self reorderObjectsOfScene: aScene];
    }
    
}


- (void) finishOpenGLESCommands {
    
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext: context];
        glFinish();
    }
}


- (void) freeOpenGLESResources {
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}


- (void) setOffTargetTrackingMode:(BOOL) enabled {
    offTargetTrackingEnabled = enabled;
}



//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method periodically on a background thread ***


- (void) renderFrameQCAR {
    [self setFramebuffer];
 
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Renderer::getInstance().drawVideoBackground();
 
    // Enable depth test
    glEnable(GL_DEPTH_TEST);
    
    // We must detect if background reflection is active and adjust the culling direction.
    // If the reflection is active, this means the pose matrix has been reflected as well,
    // therefore standard counter clockwise face culling will result in "inside out" models.
    if (offTargetTrackingEnabled) {
        glDisable(GL_CULL_FACE);
    } else {
        glEnable(GL_CULL_FACE);
    }
    glCullFace(GL_BACK);
    if(QCAR::Renderer::getInstance().getVideoBackgroundConfig().mReflection == QCAR::VIDEO_BACKGROUND_REFLECTION_ON)
        glFrontFace(GL_CW);  //Front camera
    else
        glFrontFace(GL_CCW);   //Back camera


    // Render Trackables
    if (state.getNumTrackableResults() > 0) {
 
        // Get the trackable
        const QCAR::TrackableResult* result = state.getTrackableResult(0);
        const QCAR::Trackable& trackable = result->getTrackable();
        
        // Find 'scene' based on the trackable name
        NSString* trackableName = [NSString stringWithUTF8String: trackable.getName()];
//        NSAssert ([trackableName isEqualToString: _scene.targetImgName],
//                  @"ImageTargetsEAGLView.renderFrameQCAR: scene and trackable name do not match");
        
        if (_scene != nil) {
            
            // Inform delegate that we found the target image
            if (!trackingScene) {
                [self.delegate startTrackingScene: _scene];
                trackingScene = YES;
            }

            Shader* shader = nil;
        
            // Render oglObjects in scene
            for (OglObject* oglObj in _scene.object3D.oglObjects) {
                
                // Which shader should be used?
                if (oglObj.material != nil) {
                    
                    Material* material = oglObj.material;
                    Texture* texture = [material textureMap];
                    
                    if (texture != nil) {
                        shader = textureLightShader;
                        textureLightShader.oglObject = oglObj;
                        textureLightShader.light = _scene.light;
                    }
                    else if ([material.name isEqualToString: kClipObjectMaterial]) {
                        shader = clipPlaneShader;
                        clipPlaneShader.oglObject = oglObj;
                        clipPlaneShader.light = _scene.light;
                    }
                    else {
                        shader = materialShader;
                        materialShader.oglObject = oglObj;
                        materialShader.light = _scene.light;
                    }
                    
                    // Let shader fill OpenGL pipeline
                    if (shader != nil) {
                        [shader calcInParams: vapp.projectionMatrix forTrackable: result];
                        [shader activate];
                        [shader pushInParams];
                        [shader enableVertexParams];
                        [shader drawScene];
                        [shader disableVertexParams];
                        [shader deactivate];
                    }
                }
            }
        }
    }
    
    else {
        // Inform delegate that tracking has ended
        if (trackingScene) {
            [self.delegate endTrackingScene: nil];
            trackingScene = NO;
        }
    }

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
  
  
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];
  }



/*  NEW IMPLEMENTATION
 
- (void)renderFrameQCAR
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    // We must detect if background reflection is active and adjust the culling direction.
    // If the reflection is active, this means the pose matrix has been reflected as well,
    // therefore standard counter clockwise face culling will result in "inside out" models.
    if (offTargetTrackingEnabled) {
        glDisable(GL_CULL_FACE);
    } else {
        glEnable(GL_CULL_FACE);
    }
    glCullFace(GL_BACK);
    if(QCAR::Renderer::getInstance().getVideoBackgroundConfig().mReflection == QCAR::VIDEO_BACKGROUND_REFLECTION_ON)
        glFrontFace(GL_CW);  //Front camera
    else
        glFrontFace(GL_CCW);   //Back camera
 
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const QCAR::TrackableResult* result = state.getTrackableResult(i);
        const QCAR::Trackable& trackable = result->getTrackable();

        //const QCAR::Trackable& trackable = result->getTrackable();
        QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(result->getPose());
        
        // OpenGL 2
        QCAR::Matrix44F modelViewProjection;
        
        if (offTargetTrackingEnabled) {
            SampleApplicationUtils::rotatePoseMatrix(90, 1, 0, 0,&modelViewMatrix.data[0]);
            SampleApplicationUtils::scalePoseMatrix(kObjectScaleOffTargetTracking, kObjectScaleOffTargetTracking, kObjectScaleOffTargetTracking, &modelViewMatrix.data[0]);
        } else {
            SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
            SampleApplicationUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);
        }
        
        SampleApplicationUtils::multiplyMatrix(&vapp.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
        
        glUseProgram(shaderProgramID);
        
        if (offTargetTrackingEnabled) {
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.vertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.normals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.texCoords);
        } else {
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotVertices);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotNormals);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotTexCoords);
        }
        
        // [shader enableVertexParams];
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        // Choose the texture based on the target name
        int targetIndex = 0; // "stones"
        if (!strcmp(trackable.getName(), "chips"))
            targetIndex = 1;
        else if (!strcmp(trackable.getName(), "tarmac"))
            targetIndex = 2;
        
        glActiveTexture(GL_TEXTURE0);
        
        if (offTargetTrackingEnabled) {
            glBindTexture(GL_TEXTURE_2D, augmentationTexture[3].textureID);
        } else {
            glBindTexture(GL_TEXTURE_2D, augmentationTexture[targetIndex].textureID);
        }
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
        glUniform1i(texSampler2DHandle, 0);
        
        if (offTargetTrackingEnabled) {
            glDrawArrays(GL_TRIANGLES, 0, (int)buildingModel.numVertices);
        } else {
            glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)teapotIndices);
        }
        
        // [shader disableVertexParams];
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        SampleApplicationUtils::checkGlError("EAGLView renderFrameQCAR");
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];
}

*/

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management
////////////////////////////////////////////////////////////////////////////////

// Initialise OpenGL textures
- (void) setupTexturesOfScene: (Scene*) aScene {
    
    if (aScene == nil) {
        NSLog(@"ImagesTargetsEAGLView.setupTextures: scene object is nil");
        return;
    }
    
    for (OglObject* oglObj in aScene.object3D.oglObjects) {
        
        Material* mat = [oglObj material];
            
        if (mat != nil && [mat textureMap] != nil) {
            // Setup texture map in OpenGL
            GLuint textureID;
            Texture* texture = [mat textureMap];
            glGenTextures(1, &textureID);
            [texture setTextureID: textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_RGBA,
                         [texture width],
                         [texture height],
                         0,
                         GL_RGBA,
                         GL_UNSIGNED_BYTE,
                         (GLvoid*)[texture pngData]
                         );
        }
    }
}


- (void) reorderObjectsOfScene: (Scene*) aScene {

    if (aScene == nil) {
        NSLog(@"ImagesTargetsEAGLView.reorderObjectsOfScene: scene object is nil");
        return;
    }
    
    NSMutableArray* newObj3DList = [NSMutableArray new];
    
    // Put objects with material.name = kClipObjectMaterial in front of new object list
    for (OglObject* oglObj in aScene.object3D.oglObjects) {
        
        Material* mat = [oglObj material];
        
        if (mat != nil && [mat.name isEqualToString: kClipObjectMaterial]) {
            [newObj3DList insertObject: oglObj atIndex: 0];
        }
        else {
            [newObj3DList addObject: oglObj];
        }
    }
    
    aScene.object3D.oglObjects = newObj3DList;
}


// Initialise OpenGL 2.x shaders

- (void) initShaders {
    
    // Create texture shader instance ---------------------------------------------------------------------------
    textureShader = [TextureShader newShader];
    textureShader->programID = ShaderUtils::createProgramFromBuffer(textureVertexShader, textureFragmentShader);
    [textureShader setupInParams];
    ShaderUtils::checkGlError("setupShaders: textureShader");
    NSAssert (textureShader->programID > 0, @"setupShaders: textureShader ID is 0");
    
    // Create texture light shader instance ---------------------------------------------------------------------------
    textureLightShader = [TextureLightShader newShader];
    textureLightShader->programID = ShaderUtils::createProgramFromBuffer(textureLightVertexShader, textureLightFragmentShader);
    [textureLightShader setupInParams];
    ShaderUtils::checkGlError("setupShaders: textureLightShader");
    NSAssert (textureLightShader->programID > 0, @"setupShaders: textureLightShader ID is 0");
    
    // Create material shader instance ---------------------------------------------------------------------------
    materialShader = [MaterialShader newShader];
    materialShader->programID = ShaderUtils::createProgramFromBuffer(materialVertexShader, materialFragmentShader);
    [materialShader setupInParams];
    ShaderUtils::checkGlError("setupShaders: materialShader");
    NSAssert (materialShader->programID > 0, @"setupShaders: materialShader ID is 0");

    // Create clip plane shader instance ---------------------------------------------------------------------------
    clipPlaneShader = [ClipPlaneShader newShader];
    clipPlaneShader->programID = ShaderUtils::createProgramFromBuffer(clipPlaneVertexShader, clipPlaneFragmentShader);
    [clipPlaneShader setupInParams];
    ShaderUtils::checkGlError("setupShaders: clipPlaneShader");
    NSAssert (clipPlaneShader->programID > 0, @"setupShaders: clipPlaneShader ID is 0");

}


- (void) createFramebuffer {
    
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void) deleteFramebuffer {
    
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void) setFramebuffer {
    
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL) presentFramebuffer {
    
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
