//
//  GameStatus.h
//  AR-Quest
//
//  Created by Reto Marti on 16.04.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Story.h"


@interface GameStatus : NSObject <NSCoding> {
@protected
    NSMutableArray* storiesStarted;
    NSMutableArray* storiesEnded;
}

// Instance creation
+ (instancetype) loadInstance;

// Change game status
- (void) startStory: (Story*) story;
- (void) continueStory: (Story*) story;
- (void) startScene: (Scene*) scene ofStory: (Story*) story;
- (void) endScene: (Scene*) scene ofStory: (Story*) story;
- (void) endStory: (Story*) story;

// Querying game status
- (BOOL) hasStoryStarted: (Story*) story;
- (BOOL) hasSceneStarted: (Scene*) scene ofStory: (Story*) story;
- (BOOL) hasStoryEnded: (Story*) story;
- (Scene*) lastStartedSceneOfStory: (Story*) story;

// Persisting
- (void) save;

@end
