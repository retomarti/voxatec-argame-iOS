//
//  Scene.h
//  AR-Quest
//
//  Created by Reto Marti on 02.02.13.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "NamedObject.h"
#import "Cache.h"
#import "Object3D.h"
#import "Riddle.h"
#import "Light.h"
#import "File.h"


@interface Scene : NamedObject {
}
// Scene
@property int seqNr;

// Cache
@property (atomic, strong) Cache* cache;

// Image target objects
@property (atomic, strong) NSString* targetImgName;
@property (atomic, strong) File* targetImgXmlFile;
@property (atomic, strong) File* targetImgDataFile;

// 3D objects
@property (atomic, strong) Object3D* object3D;
@property (atomic, strong) Riddle* riddle;
@property (atomic, strong) Light* light;

@end
