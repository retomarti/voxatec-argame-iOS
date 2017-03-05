//
//  TourManager.h
//  AR-Quest
//
//  Created by Reto Marti on 03.02.13.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Adventure.h"
#import "Story.h"
#import "Scene.h"
#import "ObjFileParser.h"


// Forward declaration
// @class TourManager;


@protocol TourManagerDelegate
@optional
// Adventures loading
- (void) didFinishLoadingAdventures: (NSArray*) anAdventureList;
- (void) didLoadFractionOfAdventures: (float) fraction;
- (void) didFailLoadingAdventuresWithError: (NSError*) error;

// Scene preparation for image target tracking
- (void) didFinishPreparingScene: (Scene*) scene;
- (void) didPrepareFractionOfScene: (float) fraction;
- (void) didFailPreparingSceneWithError: (NSError*) scene;
@end


@interface TourManager : NSObject {
    @protected
    NSMutableArray* adventures;
    Adventure* theAdventure;    // Current adventure
    Story* theStory;            // Current story
    Scene* theScene;            // Current scene
    
    ObjFileParser* parser;      // obj file parser
    NSMapTable* fileMapTable;   // maps request-URL to file objects
}

@property (atomic, strong) id <TourManagerDelegate> delegate;
@property (atomic, strong) NSMutableArray* adventures;

// Singleton
+ (TourManager*) theManager;

// Tour workflow
- (void) loadNearbyAdventures: (CLLocation*) userLocation;
- (void) startStory: (Story*) story;
- (void) gotoNextScene: (Scene*) currentScene;
- (void) prepareSceneForSearch: (Scene*) scene;
- (void) gotoNextStory: (Story*) currentStory;

@end
