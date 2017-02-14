//
//  ObjFileParser.m
//  AR-Quest
//
//  Created by Reto Marti on 23.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import "ObjFileParser.h"
#import "FileManager.h"
#import "OglObject.h"
#import "SemanticError.h"


// Exceptions
NSString* kObjFileSyntaxErrorException = @"ObjFileParser.SyntaxError.Exception";
NSString* kFileNotFoundException = @"ObjFileParser.FileNotFound.Exception";

#define kGroupIndexVertex               0
#define kGroupIndexTextureCoordIndex	1
#define kGroupIndexNormalIndex			2



@implementation ObjFileParser

// Initialization  --------------------------------------------------------------------

- (void) setScanner: (ObjFileScanner*) aScanner {
    scanner = aScanner;
}


- (void) setMtlFileParser: (MtlFileParser*) aParser {
    mtlFileParser = aParser;
}


- (ObjFileScanner*) scanner {
    return scanner;
}


- (id) init {
    self = [super init];
    if (self) {
        [self setScanner: [ObjFileScanner newScanner]];
        [self setMtlFileParser: [MtlFileParser new]];
        self.oglObjects = [NSMutableArray new];
    }
    return self;
}



// Creation  ----------------------------------------------------------------------------------------------------------

+ (ObjFileParser*) newParser {
    ObjFileParser* parser = [ObjFileParser new];
    return parser;
}


- (void) dealloc {
    scanner = nil;
    mtlFileParser = nil;
    self.oglObjects = nil;
}



// Error  ----------------------------------------------------------------------------------------------------------

- (void) reportSyntaxError: (SyntaxError*) aError {
    
    // Create exception
    NSMutableDictionary* errDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    [errDict setObject: aError forKey: @"syntaxError"];
    
    NSException* exception = [NSException exceptionWithName: kObjFileSyntaxErrorException
                                                     reason: [aError errorMsg]
                                                   userInfo: errDict];
    
    // Raise exception
    [exception raise];
}


- (void) reportSyntaxErrorOnLine: (NSUInteger) aLineNr
                        atColumn: (NSUInteger) aColNr
                     expectedSym: (NSString*) expSym
                     detectedSym: (NSString*) detSym {
    
    // Create error
    SyntaxError* error = [SyntaxError newErrorOnLine: aLineNr atColumn: aColNr expectedSym: expSym detectedSym: detSym];
    
    // Create exception
    NSMutableDictionary* errDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    [errDict setObject: error forKey: @"syntaxError"];
    
    NSException* exception = [NSException exceptionWithName: kObjFileSyntaxErrorException
                                          reason: [error errorMsg]
                                          userInfo: errDict];
    
    // Raise exception
    [exception raise];
}


- (void) reportMtlFileNotFoundError: (NSString*) fileName
                             onLine: (NSUInteger) aLineNr
                           atColumn: (NSUInteger) aColNr {
    // Create error
    SemanticError* error = [SemanticError fileNotFoundError: fileName onLine: aLineNr atColumn: aColNr];
    
    // Create exception
    NSMutableDictionary* errDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    [errDict setObject: error forKey: @"fileNotFoundError"];
    
    NSException* exception = [NSException exceptionWithName: kObjFileSyntaxErrorException
                                                     reason: [error errorMsg]
                                                   userInfo: errDict];
    
    // Raise exception
    [exception raise];
}



- (SyntaxError*) syntaxErrorFromException: (NSException*) aException {
    NSAssert([[aException name] isEqualToString: kObjFileSyntaxErrorException], @"Wrong kind of exception");
    
    // Get info from exception
    SyntaxError* error = [[aException userInfo] objectForKey: @"syntaxError"];
    
    return error;
}


- (SemanticError*) fileNotFoundErrorFromException: (NSException*) aException {
    NSAssert([[aException name] isEqualToString: kFileNotFoundException], @"Wrong kind of exception");
    
    // Get info from exception
    SemanticError* error = [[aException userInfo] objectForKey: @"fileNotFoundError"];
    
    return error;
}


// Helper  --------------------------------------------------------------------------------------

- (NSString*) symName: (ObjFileSymbol) aSymbol {
    return nil;
}


- (BOOL) tryMatchSym: (ObjFileSymbol) aSymbol {
    return [scanner sym] == aSymbol;
}


- (BOOL) tryMatchSym: (ObjFileSymbol) aSymbol token: (NSString*) aToken {
    if ([self tryMatchSym: aSymbol]) {
        return ([aToken isEqualToString: [scanner token]]);
    }
    else
        return NO;
}


- (void) matchSym: (ObjFileSymbol) aSymbol {
    if (![self tryMatchSym: aSymbol]) {
        
        // Raise error
        [self reportSyntaxErrorOnLine: [scanner lineNr]
                             atColumn: [scanner colNr]
                          expectedSym: [scanner symName: aSymbol]
                          detectedSym: [scanner token]];
    }
    else {
        [scanner readNextSym];
    }
}


- (void) matchSymNoRead: (ObjFileSymbol) aSymbol {
    if (![self tryMatchSym: aSymbol]) {
        // Raise error
        [self reportSyntaxErrorOnLine: [scanner lineNr]
                             atColumn: [scanner colNr]
                          expectedSym: [scanner symName: aSymbol]
                          detectedSym: [scanner token]];
    }
}


- (BOOL) tryMatchSyms: (ObjFileSymbol[]) aSymbolList nrOfSyms: (int) aSymCount {
    BOOL matched = NO;
    int i = 0;
    
    while (!matched && i < aSymCount) {
        matched = [scanner sym] == aSymbolList[i];
        i++;
    }
    
    return matched;
}



// Declarations  ----------------------------------------------------------------------------

- (void) material_include {
    // mtrllib <material-file-name> eol
    [self matchSym: sym_MTLLIB];

    NSString* matFileName = [scanner token];
    [self matchSym: sym_IDENT];
    
    SyntaxError* error = [mtlFileParser parseMtlFileWithName: matFileName];
    
    if (error != nil)
        [self reportSyntaxError: error];
    
    [self matchSym: sym_EOL];
}


- (void) vertexCoordinates3D {
    // CoordX
    NSString* coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    vertices[vertexCount].x = [coordStr floatValue];
    
    // CoordY
    coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    vertices[vertexCount].y = [coordStr floatValue];
    
    // CoordZ
    coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    vertices[vertexCount].z = [coordStr floatValue];
    
    // Define variables for object translation & scaling
    sumVertex.x = sumVertex.x + vertices[vertexCount].x;
    sumVertex.y = sumVertex.y + vertices[vertexCount].y;
    sumVertex.z = sumVertex.z + vertices[vertexCount].z;
    maxVertex.x = MAX(vertices[vertexCount].x, maxVertex.x);
    maxVertex.y = MAX(vertices[vertexCount].y, maxVertex.y);
    maxVertex.z = MAX(vertices[vertexCount].z, maxVertex.z);
    minVertex.x = MIN(vertices[vertexCount].x, minVertex.x);
    minVertex.y = MIN(vertices[vertexCount].y, minVertex.y);
    minVertex.z = MIN(vertices[vertexCount].z, minVertex.z);

    vertexCount++;
}


- (void) vertex_definitions {
    // v <coordX> <coordY> <coordZ> eol
    while ([scanner sym] == sym_V) {
        [scanner readNextSym];
        [self vertexCoordinates3D];
        [self matchSym: sym_EOL];
    }
}


- (void) normalCoordinates3D {
    // CoordX
    NSString* coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    normals[normalCount].x = [coordStr floatValue];
    
    // CoordY
    coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    normals[normalCount].y = [coordStr floatValue];
    
    // CoordZ
    coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    normals[normalCount].z = [coordStr floatValue];
    
    normalCount++;
}


- (void) normal_definitions {
    // vn <coordX> <coordY> <coordZ> eol
    while ([scanner sym] == sym_VN) {
        [scanner readNextSym];
        [self normalCoordinates3D];
        [self matchSym: sym_EOL];
    }
}


- (void) textureCoordinates2D {
    // CoordX
    NSString* coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    texCoords[texCoordCount].x = [coordStr floatValue];
    
    // CoordY
    coordStr = [scanner token];
    [self matchSym: sym_FLOAT];
    texCoords[texCoordCount].y = [coordStr floatValue];
    
    texCoordCount++;
}


- (void) texture_definitions {
    // vt <coordX> <coordY> eol
    while ([scanner sym] == sym_VT) {
        [scanner readNextSym];
        [self textureCoordinates2D];
        [self matchSym: sym_EOL];
    }
}


- (void) material_usage {
    // usemtrl ['('] <material-name> [')'] eol
    if ([scanner sym] == sym_USEMTL) {
        [scanner readNextSym];
        
        if ([scanner sym] == sym_L_BRACKET) {
            [scanner readNextSym];
        }
        
        // Assign material to current object
        NSString* mtlName = [scanner token];
        [self matchSym: sym_IDENT];
        OglObject* currObj = [self.oglObjects lastObject];
        Material* material = [mtlFileParser materialWithName: mtlName];
        
        // Material found?
        if (material == nil) {
            [self reportMtlFileNotFoundError: mtlName onLine: [scanner lineNr] atColumn: [scanner colNr]];
        }
             
        currObj.material = [mtlFileParser materialWithName: mtlName];
        
        if ([scanner sym] == sym_R_BRACKET) {
            [scanner readNextSym];
        }
        
        [self matchSym: sym_EOL];
    }
}


- (void) smooth_shading {
    // s <on-or-off-flag>
    if ([scanner sym] == sym_S) {
        [scanner readNextSym];
        
        if ([scanner sym] == sym_IDENT || [scanner sym] == sym_INT) {
            // off or 1
            [scanner readNextSym];
        }
        [self matchSym: sym_EOL];
    }
}


- (void) face_definition {
    // f <index-group> '/' <index-group> '/' <index-group> EOL
    if ([scanner sym] == sym_F) {
        [scanner readNextSym];

        // group 1
        // vertex coord indices
        NSString* idxStr = [scanner token];
        [self matchSym: sym_INT];
        faceIdxGroups[faceCount].v1Idx = [idxStr intValue] - 1;   // index values start in OBJ files at 1
        
        if ([scanner sym] == sym_SLASH) {
            [scanner readNextSym];
            
            // texture coord indices
            if ([scanner sym] == sym_INT) {
                idxStr = [scanner token];
                [scanner readNextSym];
                faceIdxGroups[faceCount].t1Idx = [idxStr intValue] - 1;
            }
            else
                faceIdxGroups[faceCount].t1Idx = 0;
            
            [self matchSym: sym_SLASH];
            
            // normal coord indices
            idxStr = [scanner token];
            [self matchSym: sym_INT];
            faceIdxGroups[faceCount].n1Idx = [idxStr intValue]-1;
        }

        // group 2
        // vertex coord indices
        idxStr = [scanner token];
        [self matchSym: sym_INT];
        faceIdxGroups[faceCount].v2Idx = [idxStr intValue] - 1;   // index values start in OBJ files at 1
        
        if ([scanner sym] == sym_SLASH) {
            [scanner readNextSym];
            
            // texture coord indices
            if ([scanner sym] == sym_INT) {
                idxStr = [scanner token];
                [scanner readNextSym];
                faceIdxGroups[faceCount].t2Idx = [idxStr intValue] - 1;
            }
            else
                faceIdxGroups[faceCount].t2Idx = 0;
            
            [self matchSym: sym_SLASH];
            
            // normal coord indices
            idxStr = [scanner token];
            [self matchSym: sym_INT];
            faceIdxGroups[faceCount].n2Idx = [idxStr intValue]-1;
        }

        // group 3
        // vertex coord indices
        idxStr = [scanner token];
        [self matchSym: sym_INT];
        faceIdxGroups[faceCount].v3Idx = [idxStr intValue] - 1;   // index values start in OBJ files at 1
        
        if ([scanner sym] == sym_SLASH) {
            [scanner readNextSym];
            
            // texture coord indices
            if ([scanner sym] == sym_INT) {
                idxStr = [scanner token];
                [scanner readNextSym];
                faceIdxGroups[faceCount].t3Idx = [idxStr intValue] - 1;
            }
            else
                faceIdxGroups[faceCount].t3Idx = 0;
           
            [self matchSym: sym_SLASH];
            
            // normal coord indices
            idxStr = [scanner token];
            [self matchSym: sym_INT];
            faceIdxGroups[faceCount].n3Idx = [idxStr intValue]-1;
        }
        
        // If we are not at EOL then we probably have a non-triangle face
        // -> change model to triangulated faces !!!
        
        [self matchSym: sym_EOL];
        
        faceCount++;
    }
}


- (void) face_group_definition {
    // g [ <group-name> ] EOL
    if ([scanner sym] == sym_G) {
        [scanner readNextSym];
        
        if ([scanner sym] == sym_IDENT) {
            [scanner readNextSym];
        }
        [self matchSym: sym_EOL];
    }
}


- (void) face_definitions {
    ObjFileSymbol lineStarts[4] = {sym_F, sym_USEMTL, sym_S, sym_G};
    
    while ([self tryMatchSyms: lineStarts nrOfSyms: 4]) {
        
        switch ([scanner sym]) {
                
            case sym_F:
                [self face_definition];
                break;
                
            case sym_USEMTL:
                [self material_usage];
                break;
                
            case sym_S:
                [self smooth_shading];
                break;
                
            case sym_G:
                [self face_group_definition];
                break;
                
            default:
                [scanner readNextLine];
                break;
        } 
    }
}


- (void) object_geom_definition {
    [self vertex_definitions];
    [self texture_definitions];
    [self normal_definitions];
    [self face_definitions];
    
}


- (void) object_declaration {
    // o <object-name> eol
    [self matchSym: sym_O];
    
    NSString* objName = [scanner token];
    [self matchSym: sym_IDENT];
    
    // Create new object
    OglObject* oglObject = [OglObject new];
    oglObject.name = objName;
    
    // Close ranges of previous object
    [self.oglObjects addObject: oglObject];
    if (objectCount > 0) {
        objFaceRanges[objectCount-1].toIdx = faceCount;
        objTexCoordRanges[objectCount-1].toIdx = texCoordCount;
    }
    
    // Open ranges of new object
    objFaceRanges[objectCount].fromIdx = faceCount;
    objTexCoordRanges[objectCount].fromIdx = texCoordCount;
    
    [self matchSym: sym_EOL];
    
    objectCount++;
}


- (void) object_declaration_default {
    // Create new object
    OglObject* oglObject = [OglObject new];
    oglObject.name = @"obj_dflt";
    
    // Close ranges of previous object
    [self.oglObjects addObject: oglObject];
    if (objectCount > 0) {
        objFaceRanges[objectCount-1].toIdx = faceCount;
        objTexCoordRanges[objectCount-1].toIdx = texCoordCount;
    }
    
    // Open ranges of new object
    objFaceRanges[objectCount].fromIdx = faceCount;
    objTexCoordRanges[objectCount].fromIdx = texCoordCount;
    
    objectCount++;
}


- (void) parseObjects {
    // <material-include> { object-definition }
    if ([scanner sym] == sym_MTLLIB)
        [self material_include];
    
    while ([scanner sym] == sym_O || [scanner sym] == sym_V) {
        // object definition
        if ([scanner sym] == sym_O)
            [self object_declaration];
        else
            [self object_declaration_default];
        
        [self object_geom_definition];
    }
}


// Counting Lines  ---------------------------------------------------------------------------

- (void) parseLines {
    
    // Reset count variables
    vertexCount = 0;
    normalCount = 0;
    texCoordCount = 0;
    faceCount = 0;
    objectCount = 0;
    materialCount = 0;

    while (![scanner atEOT]) {
        
        switch ([scanner sym]) {
                
            case sym_V:
                vertexCount++;
                [scanner readNextLine];
                break;

            case sym_VN:
                normalCount++;
                [scanner readNextLine];
                break;

            case sym_VT:
                texCoordCount++;
                [scanner readNextLine];
                break;

            case sym_F:
                faceCount++;
                [scanner readNextLine];
                break;
                
            case sym_O:
                objectCount++;
                [scanner readNextLine];
                break;
                
            default:
                [scanner readNextLine];
                break;
        }
    }
}



// Parsing  ----------------------------------------------------------------------------------


Vector3D subtr3D (Vector3D v1, Vector3D v2) {
    // v1 - v2
    Vector3D vs;
    
    vs.x = v1.x - v2.x;
    vs.y = v1.y - v2.y;
    vs.z = v1.z - v2.z;
    
    return vs;
}


Vector3D scale3D (Vector3D v, float factor) {
    // v * factor
    Vector3D vs;
    
    vs.x = v.x * factor;
    vs.y = v.y * factor;
    vs.z = v.z * factor;
    
    return vs;
}


Vector2D subtr2D (Vector2D v1, Vector2D v2) {
    // v1 - v2
    Vector2D vs;
    
    vs.x = v1.x - v2.x;
    vs.y = v1.y - v2.y;
    
    return vs;
}


Vector2D scale2D (Vector2D v, float factor) {
    // v * factor
    Vector2D vs;
    
    vs.x = v.x * factor;
    vs.y = v.y * factor;
    
    return vs;
}


GLuint absIndex (int idx, unsigned int count) {
    // Converts negative indices to absolute indices
    if (idx >= 0)
        return idx;
    else
        return count + idx + 1;
}


- (NSError*) parseText: (const char*) aText {

    NSError* error = nil;
    
    @try {
        NSDate* start = [NSDate date];
        
        // Pass 1: Count different line types first to allocate geometry structs
        // --------------------------------------------------------------------
        [self reset];
        [scanner setText: aText];
        [scanner readNextSym];
        [self parseLines];
        NSLog(@"Objects: %u, Vertices: %d, Normals: %d, TexCoors: %d, Faces: %d",
              objectCount, vertexCount, normalCount, texCoordCount, faceCount);
        
        // Allocate local arrays
        vertices          = malloc(sizeof(Vector3D) * vertexCount);
        normals           = malloc(sizeof(Vector3D) * normalCount);
        texCoords         = malloc(sizeof(Vector2D) * texCoordCount);
        faceIdxGroups     = malloc(sizeof(IndexGroup) * faceCount);
        objFaceRanges     = malloc(sizeof(IndexRange) * objectCount);
        objTexCoordRanges = malloc(sizeof(IndexRange) * objectCount);
        
        // Pass 2: Parse text & create vertex, normal & texCoords for whole file
        // ---------------------------------------------------------------------

        // Reuse our count variables for second pass
        vertexCount   = 0;
        normalCount   = 0;
        texCoordCount = 0;
        faceCount     = 0;
        objectCount   = 0;
        
        // Variables used for mesh normalizing and translation (into bounding box (-0.5, -0.5, -0.5) to (0.5, 0.5, 0.5)
        maxVertex.x = FLT_MIN; maxVertex.y = FLT_MIN; maxVertex.z = FLT_MIN;
        minVertex.x = FLT_MAX; minVertex.y = FLT_MAX; minVertex.z = FLT_MAX;
        sumVertex.x = 0.0; sumVertex.y = 0.0; sumVertex.z = 0.0;

        [scanner setText: aText];
        [scanner readNextSym];
        [self parseObjects];
        NSLog(@"Objects: %u, Vertices: %d, Normals: %d, TexCoors: %d, Faces: %d",
              objectCount, vertexCount, normalCount, texCoordCount, faceCount);
       
        // Pass 3: Create vertex, normal & texCoords per oglObject
        // ---------------------------------------------------------------------
        
        // Define scaling & translation parameters to normalize mesh
        Vector3D center, diff;
        center.x = sumVertex.x / vertexCount;
        center.y = sumVertex.y / vertexCount;
        center.z = sumVertex.z / vertexCount;
        diff.x   = maxVertex.x - minVertex.x;
        diff.y   = maxVertex.y - minVertex.y;
        diff.z   = maxVertex.z - minVertex.z;
        
        float scaleFactor = 1.0;
        if (diff.x >= diff.y && diff.x >= diff.z)
            scaleFactor   = 1.0 / diff.x;
        else if (diff.y >= diff.x && diff.y >= diff.z)
            scaleFactor   = 1.0 / diff.y;
        else
            scaleFactor   = 1.0 / diff.z;
        
        // Scale with object3D specific factor
        scaleFactor = scaleFactor * object3D.objScaleFactor;
        
        // Close index ranges of last object
        if (objectCount > 0) {
            objFaceRanges[objectCount-1].toIdx = faceCount;
            objTexCoordRanges[objectCount-1].toIdx = texCoordCount;
        }
        
        // Iterate over all detected objects
        for (int objIdx=0; objIdx < [self.oglObjects count]; objIdx++) {
            
            OglObject* object        = [self.oglObjects objectAtIndex: objIdx];
            IndexRange objFaceRange  = objFaceRanges[objIdx];
            IndexRange texCoordRange = objTexCoordRanges[objIdx];
            GLuint objFaceCount      = objFaceRange.toIdx - objFaceRange.fromIdx;
            GLuint objTexCoordCount  = texCoordRange.toIdx - texCoordRange.fromIdx;
            
            // Allocate OglObject instance variables
            object.vertices    = malloc(sizeof(Vector3D) * objFaceCount * 3);
            object.normals     = malloc(sizeof(Vector3D) * objFaceCount * 3);
            object.texCoords   = malloc(sizeof(Vector2D) * objFaceCount * 3);
            
            // Define vertices, normals & texCoords of object
            for (int fIdx = 0; fIdx < objFaceCount; fIdx++) {
                
                IndexGroup grp = faceIdxGroups[objFaceRange.fromIdx + fIdx];
                
                // vertices are scaled by factor 'scaleFactor'
                object.vertices[3*fIdx+0]  = scale3D(vertices[absIndex(grp.v1Idx, vertexCount)], scaleFactor);
                object.vertices[3*fIdx+1]  = scale3D(vertices[absIndex(grp.v2Idx, vertexCount)], scaleFactor);
                object.vertices[3*fIdx+2]  = scale3D(vertices[absIndex(grp.v3Idx, vertexCount)], scaleFactor);
                
                // normals
                object.normals[3*fIdx+0]   = normals[absIndex(grp.n1Idx, normalCount)];
                object.normals[3*fIdx+1]   = normals[absIndex(grp.n2Idx, normalCount)];
                object.normals[3*fIdx+2]   = normals[absIndex(grp.n3Idx, normalCount)];
                
                // texture coordinates (may be empty!!!)
                object.texCoords[3*fIdx+0] = texCoords[absIndex(grp.t1Idx, texCoordCount)];
                object.texCoords[3*fIdx+1] = texCoords[absIndex(grp.t2Idx, texCoordCount)];
                object.texCoords[3*fIdx+2] = texCoords[absIndex(grp.t3Idx, texCoordCount)];
            }
            
            // Save count variables to oglObject
            object.numVertices = objFaceCount * 3;
            object.numNormals = objFaceCount * 3;
            object.numTexCoords = objFaceCount * 3;
            
        }
        
        // free temp memory
        free(vertices); vertices = nil;
        free(normals); normals = nil;
        free(texCoords); texCoords = nil;
        free(faceIdxGroups); faceIdxGroups = nil;
        free(objFaceRanges); objFaceRanges = nil;
        free(objTexCoordRanges); objTexCoordRanges = nil;
        
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        NSLog(@"elapsed time: %f", timeInterval);
    }
    
    @catch (NSException* exception) {
        // Syntax error?
        if ([[exception name] isEqualToString: kObjFileSyntaxErrorException]) {
            error = [self syntaxErrorFromException: exception];
            NSLog(@"ObjFileParser error: %s", [[exception reason] UTF8String]);
        }
        else if ([[exception name] isEqualToString: kFileNotFoundException]) {
            error = [self fileNotFoundErrorFromException: exception];
            NSLog(@"ObjFileParser error: %s", [[exception reason] UTF8String]);
        }
        else
            NSLog(@"ObjFileParser error: %s", [[exception reason] UTF8String]);
    }
    
    return error;
}


- (NSError*) parseObjFile: (File*) objFile ofObject: (Object3D*) obj3D {
    NSLog(@"ObjFileParser: parsing file %s...", [objFile.name UTF8String]);
    
    self->object3D = obj3D;
    
    // Read file content
    if (objFile.content == nil) {
        [[FileManager theManager] loadFileContent: objFile];
    }
    
    if (objFile.content == nil)
        return FALSE;
    
    [self reset];
    NSError* synError = [self parseText: [objFile.content bytes]]; // NSData
        
    return synError;
}


- (void) reset {
    [scanner reset];
    self.oglObjects = [NSMutableArray new];
}


@end
