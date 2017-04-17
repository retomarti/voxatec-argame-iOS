//
//  Story.h
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#ifndef Story_h
#define Story_h

#import "NamedObject.h"
#import "Scene.h"
#import "Cache.h"


@interface Story : NamedObject <NSCoding> {
}

@property (atomic, strong) NSMutableArray* scenes;
@property (atomic, strong) NSNumber* price;

+ (Story*) newStory;
- (Scene*) firstScene;
- (Scene*) nextSceneTo: (Scene*) scene;
- (Scene*) lastScene;
- (Scene*) sceneWithId: (NSNumber*) sceneId;
- (Scene*) sceneWithName: (NSString*) sceneName;

@end


#endif /* Story_h */
