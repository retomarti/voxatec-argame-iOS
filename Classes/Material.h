//
//  Material.h
//  AR-Quest
//
//  Created by Reto Marti on 07.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Texture.h"


typedef struct {
    float ambientCoeff[4];  // r,g,b,alpha, 0..1.0
    float diffuseCoeff[4];
    float specularCoeff[4];
    float specularExp;      // specular exponent
    float shininess;        // 0..1.0
    float opacity;          // 0..1.0 (total opaque)
} LightReflectionDef;


@interface Material : NSObject {
    @public
    LightReflectionDef lightReflection;
    
    // Texture map definitions
    Texture* map_ambient;   // ambient texture map
    Texture* map_specular;  // specular texture map
    Texture* map_diffuse;   // diffuse texture map
}

@property (atomic, strong) NSString* name;

- (Texture*) textureMap;

+ (Material*) gold;
+ (Material*) silver;
+ (Material*) bronze;

@end
