//
//  ObjFileParser.h
//  AR-Qest
//
//  Created by Reto Marti on 23.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "File.h"
#import "ObjFileScanner.h"
#import "SyntaxError.h"
#import "MtlFileParser.h"
#import "OglObject.h"


typedef struct {
    GLuint fromIdx;
    GLuint toIdx;
} IndexRange;

// Trianguar face structure
typedef struct {
    GLuint v1Idx;  // vertex index
    GLuint t1Idx;  // texture index
    GLuint n1Idx;  // normal index
    
    GLuint v2Idx;  // vertex index
    GLuint t2Idx;  // texture index
    GLuint n2Idx;  // normal index
    
    GLuint v3Idx;  // vertex index
    GLuint t3Idx;  // texture index
    GLuint n3Idx;  // normal index
} IndexGroup;


/*------------------------------------------------------------
  Class Parser: instances of this class implement a syntactic
  analyzer of WaveFront OBJ file formats. An encountered syntax 
  error is returned directly by the method 'parseText'.
  Note: the models must be in triangular face form!
-------------------------------------------------------------*/

@interface ObjFileParser : NSObject {
	@protected
	ObjFileScanner* scanner;
    MtlFileParser* mtlFileParser;
    
    GLuint objectCount;
    GLuint vertexCount;
    GLuint normalCount;
    GLuint texCoordCount;
    GLuint faceCount;
    GLuint materialCount;
    
    Vector3D* vertices;
    Vector3D* normals;
    Vector2D* texCoords;
    IndexGroup* faceIdxGroups;
    IndexRange* objFaceRanges;
    IndexRange* objTexCoordRanges;

    Vector3D sumVertex;
    Vector3D maxVertex;
    Vector3D minVertex;
}

// Objects created out of obj file after parseObjFileWithName
@property (atomic, retain) NSMutableArray* oglObjects;

// Creation
+ (ObjFileParser*) newParser;

// Parsing
- (NSError*) parseObjFile: (File*) objFile;

@end
