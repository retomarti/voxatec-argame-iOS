//
//  Material.m
//  AR-Quest
//
//  Created by Reto Marti on 07.02.13.
//
//-------------------------------------------------------------------------------

#import "Material.h"



@implementation Material

@synthesize name;

/* Material definitions according to: http://devernay.free.fr/cours/opengl/materials.html */


- (Texture*) textureMap {
    if (map_ambient != nil)
        return map_ambient;
    else if (map_specular != nil)
        return map_specular;
    else
        return map_diffuse;
}


+ (Material*) gold {
    Material* mat = [Material new];
    
    // lightReflection
    float ambCoeff[4] = {0.24725, 0.1995, 0.0745, 1.0};
    float diffCoeff[4] = {0.75164, 0.60648, 0.22648, 1.0};
    float specCoeff[4] = {0.628281, 0.555802, 0.366065, 1.0};
    
    memcpy(mat->lightReflection.ambientCoeff, ambCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.diffuseCoeff, diffCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.specularCoeff, specCoeff, sizeof(float) * 4);

    mat->lightReflection.specularExp = 5;
    mat->lightReflection.shininess = 0.8;
    mat->lightReflection.opacity = 1.0;

    return mat;
}


+ (Material*) silver {
    Material* mat = [Material new];
    
    // lightReflection
    float ambCoeff[4] = {0.19225, 0.19225, 0.19225, 1.0};
    float diffCoeff[4] = {0.50754, 0.50754, 0.50754, 1.0};
    float specCoeff[4] = {0.508273, 0.508273, 0.508273, 1.0};
    
    memcpy(mat->lightReflection.ambientCoeff, ambCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.diffuseCoeff, diffCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.specularCoeff, specCoeff, sizeof(float) * 4);

    mat->lightReflection.specularExp = 5;
    mat->lightReflection.shininess = 0.8;
    mat->lightReflection.opacity = 1.0;
    
    return mat;
}


+ (Material*) bronze {
    Material* mat = [Material new];
    
    // lightReflection
    float ambCoeff[4] = {0.2125, 0.1275, 0.054, 1.0};
    float diffCoeff[4] = {0.714, 0.4284, 0.18144, 1.0};
    float specCoeff[4] = {0.393548, 0.271906, 0.166721, 1.0};
    
    memcpy(mat->lightReflection.ambientCoeff, ambCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.diffuseCoeff, diffCoeff, sizeof(float) * 4);
    memcpy(mat->lightReflection.specularCoeff, specCoeff, sizeof(float) * 4);
    
    mat->lightReflection.specularExp = 4;
    mat->lightReflection.shininess = 0.2;
    mat->lightReflection.opacity = 1.0;

    return mat;
}


- (void) dealloc {
    name = nil;
    
    map_ambient = nil;
    map_specular = nil;
    map_diffuse = nil;
}


@end
