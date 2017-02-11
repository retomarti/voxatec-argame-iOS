//
//  OglObject.h
//  AR-Quest
//
//  Created by Reto Marti on 08.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Material.h"
#include <OpenGLES/gltypes.h>


typedef struct {
    GLfloat x;
    GLfloat y;
} Vector2D;

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Vector3D;


@interface OglObject : NSObject {
@protected
    GLuint numVertices;
    GLuint numNormals;
    GLuint numTexCoords;
    
    Vector3D* vertices;
    Vector3D* normals;
    Vector2D* texCoords;
    
    double scaleFactor;

    Material* material;
}
@property (atomic, strong) NSString* name;

@property (atomic) GLuint numVertices;
@property (atomic) GLuint numNormals;
@property (atomic) GLuint numTexCoords;

@property (atomic) Vector3D* vertices;
@property (atomic) Vector3D* normals;
@property (atomic) Vector2D* texCoords;

@property (atomic) double scaleFactor;

@property (atomic, strong) Material* material;
@end

