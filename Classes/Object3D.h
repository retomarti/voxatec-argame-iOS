//
//  Object3D.h
//  AR-Quest
//
//  Created by Reto Marti on 03.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#include <OpenGLES/gltypes.h>
#import "NamedObject.h"
#import "Material.h"
#import "File.h"


@interface Object3D : NamedObject {
}
// Bean properties
@property (atomic, strong) NSString* obj3DFileName;
@property (atomic, strong) NSString* materialFileName;
@property (atomic, strong) File* obj3DFile;
@property (atomic, strong) File* materialFile;
@property (atomic, strong) NSArray* textureFiles;

// Rendering properties
@property (atomic, strong) NSArray* oglObjects;
@end


