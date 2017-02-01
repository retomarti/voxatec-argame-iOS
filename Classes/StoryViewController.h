//
//  StoryViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 23/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ARGameViewController.h"
#import "Adventure.h"
#import "Story.h"
#import "Scene.h"
#import "TourManager.h"
#import "ActivityIndicatorView.h"


@interface StoryViewController : ARGameViewController <TourManagerDelegate> {
    @protected
    ActivityIndicatorView* activityIndicatorView;
}

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem* storyViewTitle;
@property (strong, nonatomic) IBOutlet UILabel* adventureNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* storyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* subtitleLabel;
@property (strong, nonatomic) IBOutlet UITextView* storyTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* startStoryButton;

// Data model
@property (strong, nonatomic) Adventure* adventure;
@property (strong, nonatomic) Story* story;
@property (strong, nonatomic) Scene* scene;

// Utilities
@property (strong, nonatomic) AVSpeechSynthesizer* speechSynthesizer;

// Actions
- (IBAction) speakText: (id) sender;
- (IBAction) startStory: (id) sender;

// Segue methods (unwind)
- (IBAction) gotoNextScene: (UIStoryboardSegue*) sender;

@end
