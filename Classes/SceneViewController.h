//
//  SceneViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 16.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ARGameViewController.h"
#import "Scene.h"
#import "TourManager.h"


@interface SceneViewController : ARGameViewController

// Outlet
@property (strong, nonatomic) IBOutlet UINavigationItem* sceneViewTitle;
@property (strong, nonatomic) IBOutlet UILabel* adventureNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* storyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* sceneNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* cacheNrLabel;
@property (strong, nonatomic) IBOutlet UITextView* sceneTextView;

// Data model
@property (strong, nonatomic) Adventure* adventure;
@property (strong, nonatomic) Story* story;
@property (strong, nonatomic) Scene* scene;

// Utilities
@property (strong, nonatomic) AVSpeechSynthesizer* speechSynthesizer;

// Actions
- (IBAction) speakText: (id) sender;
- (IBAction) showCacheOnMap: (id) sender;

@end
