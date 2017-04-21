//
//  GameStatus.m
//  AR-Quest
//
//  Created by Reto Marti on 16.04.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "GameStatus.h"

// Strings used to store game status
static NSString* const GSVersionNr = @"versionNr";
static NSString* const GSStoriesStartedCount = @"storiesStartedCount";
static NSString* const GSStoriesStarted = @"storiesStarted";
static NSString* const GSStoriesEndedCount = @"storiesEndedCount";
static NSString* const GSStoriesEnded   = @"storiesEnded";



@implementation GameStatus


//-- Initialisation ----------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self) {
        storiesStarted = [NSMutableArray new];
        storiesEnded = [NSMutableArray new];
    }
    
    return self;
}


//-- Game Status Changes -----------------------------------------------------------------

- (void) startStory: (Story*) story {
    if (![self startedStoryWithId: story.id inCityWithId: story.city.id]) {
        // Create proxy story
        Story* startedStory = [Story new];
        startedStory.id = story.id;
        startedStory.name = story.name;
        startedStory.city = story.city;
        startedStory.price = story.price;
        
        [storiesStarted addObject: startedStory];
        
        [self save];
    }
}


- (void) continueStory: (Story*) story {
    NSAssert([self startedStoryWithId: story.id inCityWithId: story.city.id],
             @"GameStatus: story to be continued was not yet started");
    // nothing to do
}


- (Story*) startedStoryWithId: (NSNumber*) storyId inCityWithId: (NSNumber*) cityId {
    // Retrieve story proxy with given id
    for (Story* story in storiesStarted) {
        if ((story.id == storyId) && (story.city != nil && story.city.id == cityId))
            return story;
    }
    
    return nil; // not found
}


- (Story*) endedStoryWithId: (NSNumber*) storyId {
    // Retrieve story proxy with given id
    for (Story* story in storiesEnded) {
        if (story.id == storyId)
            return story;
    }
    
    return nil; // not found
}


- (Scene*) startedSceneWithId: (NSNumber*) sceneId ofStory: (Story*) story {
    // Retrieve scene proxy with given id
    Story* startedStory = [self startedStoryWithId: story.id inCityWithId: story.city.id];
    
    for (Scene* scene in startedStory.scenes) {
        if (scene.id == sceneId) {
            return scene;
        }
    }
    
    return nil; // not found
}


- (void) startScene: (Scene*) scene ofStory: (Story*) story {
    if (![self startedSceneWithId: scene.id ofStory: story]) {
        // Create proxy scene
        Scene* startedScene = [Scene new];
        startedScene.id = scene.id;
        startedScene.name = scene.name;
        
        // Add scene proxy to story proxy
        Story* startedStory = [self startedStoryWithId: story.id inCityWithId: story.city.id];
        [startedStory.scenes addObject: startedScene];
        
        [self save];
    }
}


- (void) endScene: (Scene*) scene ofStory: (Story*) story {
    
}


- (void) endStory: (Story*) story {
    // Move story proxy to storiesEnded
    Story* startedStory = [self startedStoryWithId: story.id inCityWithId: story.city.id];
    
    NSAssert(startedStory != nil, @"GameStatus: started story not found in status array");
    [storiesStarted removeObject: startedStory];
    [storiesEnded addObject: startedStory];
    
    [self save];
}


//-- Querying Game Status -----------------------------------------------------------------

- (BOOL) hasStoryStarted: (Story*) story {
    Story* startedStory = [self startedStoryWithId: story.id inCityWithId: story.city.id];
    return startedStory != nil;
}


- (BOOL) hasSceneStarted: (Scene*) scene ofStory: (Story*) story {
    Scene* startedScene = [self startedSceneWithId: scene.id ofStory: story];
    return startedScene != nil;
}


- (BOOL) hasStoryEnded: (Story*) story {
    Story* startedEnded = [self endedStoryWithId: story.id];
    return startedEnded != nil;
}


- (Scene*) lastStartedSceneOfStory: (Story*) story {
    Story* startedStory = [self startedStoryWithId: story.id inCityWithId: story.city.id];
    Scene* lastStartedScene = nil;
    
    if (startedStory != nil) {
        lastStartedScene = [[startedStory scenes] lastObject];
    }
    
    return lastStartedScene;
}


//-- NSCoding Delegate --------------------------------------------------------------------

+ (NSString*) filePath {
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"arquestGameStatus"];
    }
    return filePath;
}


+ (instancetype) loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameStatus filePath]];
    if (decodedData != nil) {
        GameStatus* gameStatus = [NSKeyedUnarchiver unarchiveObjectWithData: decodedData];
        return gameStatus;
    }
    
    // No status file found
    return [GameStatus new];
}


- (instancetype) initWithCoder: (NSCoder*) decoder {
    self = [self init];
    if (self) {
        // version
        NSString* versionNr = [decoder decodeObjectForKey: GSVersionNr];
        
        if ([versionNr isEqualToString: @"1.0"]) {
            // storiesStarted
            storiesStarted  = [decoder decodeObjectForKey: GSStoriesStarted];
            
            // storiesEnded
            storiesEnded = [decoder decodeObjectForKey: GSStoriesEnded];
        }
    }
    return self;
}


- (void) encodeWithCoder: (NSCoder*) encoder {
    // version
    [encoder encodeObject: @"1.0" forKey: GSVersionNr];
    
    // storiesStarted
    [encoder encodeObject: storiesStarted forKey: GSStoriesStarted];
    
    // storiesEnded
    [encoder encodeObject: storiesEnded forKey: GSStoriesEnded];
}


- (void) save {
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile: [GameStatus filePath] atomically: YES];
}

@end
