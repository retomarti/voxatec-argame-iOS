//
//  Story.m
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


#import "Story.h"


@implementation Story

@synthesize scenes, price;


// Initialisation ------------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self) {
        scenes = [[NSMutableArray alloc] init];
        price = [NSNumber numberWithFloat: 5.0];
    }
    
    return self;
}


+ (Story*) newStory {
    Story* story = [[Story alloc] init];
    return story;
}


- (void) dealloc {
    scenes = nil;
}


- (Scene*) firstScene {
    return [scenes firstObject];
}

- (Scene*) lastScene {
    return [scenes lastObject];
}


- (Scene*) nextSceneTo: (Scene*) scene {
    if (scene == nil || scene == [self lastScene])
        return nil;
    else {
        NSUInteger idx = [scenes indexOfObject: scene];
        Scene* nextScene = [scenes objectAtIndex: idx+1];
        return nextScene;
    }
}


- (Scene*) sceneWithId: (NSNumber*) sceneId {
    Scene* scene = nil;
    
    // Iterate over scenes
    for (scene in scenes) {
        if (scene.id == sceneId)
            return scene;
    }
    
    // not found
    return nil;
}


- (Scene*) sceneWithName: (NSString*) sceneName {
    
    if (sceneName == nil)
        return nil;
    
    Scene* scene = nil;
    
    // Iterate over scenes
    for (scene in scenes) {
        if ([sceneName isEqualToString: scene.name])
             return scene;
    }
    
    // not found
    return nil;
}


// NSCoding protocol ----------------------------------------------------------------------

- (instancetype) initWithCoder: (NSCoder*) decoder {
    self = [super initWithCoder: decoder];
    
    if (self != nil) {
        self.scenes = [decoder decodeObjectForKey: @"scenes"];
        self.price = [decoder decodeObjectForKey: @"price"];
    }
    return self;
}


- (void) encodeWithCoder: (NSCoder*) encoder {
    [super encodeWithCoder: encoder];
    
    // version
    [encoder encodeObject: self.scenes forKey: @"scenes"];
    [encoder encodeObject: self.price forKey: @"price"];
}



@end
