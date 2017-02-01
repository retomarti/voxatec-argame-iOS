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

@end
