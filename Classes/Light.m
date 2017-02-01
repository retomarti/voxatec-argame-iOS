//
//  Light.m
//  AR-Quest
//
//  Created by Reto Marti on 08.02.13.
//
//-------------------------------------------------------------------------------

#import "Light.h"


@implementation Light


+ (Light*) newPointLightAt: (Vector3D) location {
    
    Light* light = [Light new];
    
    float pos[4] = {location.x, location.y, location.z, 0.0};
    memcpy(light->position, pos, sizeof(float) * 4);
    
    float color[4] = {1.0, 1.0, 1.0, 1.0};   // white light
    memcpy(light->ambientColor, color, sizeof(float) * 4);
    memcpy(light->diffuseColor, color, sizeof(float) * 4);
    memcpy(light->specularColor, color, sizeof(float) * 4);
    
    return light;
}


@end
