//
//  Light.h
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "OglObject.h"


@interface Light : NSObject {
    @public
    float position[4];      // in world coords
    float ambientColor[4];  // r,g,b,alpha, 0..1.0
    float diffuseColor[4];
    float specularColor[4];
}

+ (Light*) newPointLightAt: (Vector3D) location;

@end
