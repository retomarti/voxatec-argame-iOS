/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>

#import <QCAR/UIGLViewProtocol.h>

#import "Texture.h"
#import "SampleApplicationSession.h"
#import "SampleApplication3DModel.h"
#import "SampleGLResourceHandler.h"

#import "Scene.h"
#import "TextureShader.h"
#import "TextureLightShader.h"
#import "MaterialShader.h"
#import "ClipPlaneShader.h"


#define kNumAugmentationTextures 4


@protocol SceneTrackerDelegate
@optional
- (void) startTrackingScene: (Scene*) aScene;
- (void) endTrackingScene: (Scene*) aScene;
@end



// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ImageTargetsEAGLView : UIView <UIGLViewProtocol, SampleGLResourceHandler> {
@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // Shader instances
    TextureShader* textureShader;
    TextureLightShader* textureLightShader;
    MaterialShader* materialShader;
    ClipPlaneShader* clipPlaneShader;

    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
    
    BOOL offTargetTrackingEnabled;
    BOOL trackingScene;
    
    SampleApplication3DModel * buildingModel;
}

@property (nonatomic, weak) SampleApplicationSession* vapp;
@property (atomic, strong) id <SceneTrackerDelegate> delegate;
@property (nonatomic, strong) Scene* scene;

- (id) initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app;
- (void) finishOpenGLESCommands;
- (void) freeOpenGLESResources;
- (void) setOffTargetTrackingMode:(BOOL) enabled;

@end
