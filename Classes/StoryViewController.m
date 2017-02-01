//
//  StoryViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 23/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "StoryViewController.h"
#import "SceneViewController.h"
#import "RiddleViewController.h"



@implementation StoryViewController


@synthesize adventure, scene, storyViewTitle, adventureNameLabel, story, storyNameLabel, subtitleLabel, storyTextView,
            startStoryButton, speechSynthesizer;


// Initialisation

- (void) dealloc {
    adventure = nil;
    story = nil;
    adventureNameLabel = nil;
    storyNameLabel = nil;
    storyTextView = nil;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (story != nil) {
        
        // Initialise outlets
        NSString* viewTitle = NSLocalizedString(@"STORY_VIEW_TITLE", @"StoryView title");
        storyViewTitle.title = viewTitle;
        adventureNameLabel.text = adventure.name;
        storyNameLabel.text = story.name;
        NSString* aboutLabel = NSLocalizedString(@"STORY_WHAT_YOU_MAY_EXPECT_LABEL", @"What you may expect");
        subtitleLabel.text = aboutLabel;
        storyTextView.text = story.text;
        
        // Activity indicator view
        NSString* userInfo = NSLocalizedString(@"SCENE_CACHE_LOADING_INFO", @"Loading Cache Data");
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithText: userInfo];
        [activityIndicatorView hide];
        [self.view addSubview: activityIndicatorView];
        
        // Remove insets in storyTextView
        storyTextView.textContainerInset = UIEdgeInsetsMake(0, -3, 0, 0);
        
    }
    
}


- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear: animated];
    
    // Reset speechSynthesizer
    if (speechSynthesizer != nil) {
        [speechSynthesizer stopSpeakingAtBoundary: AVSpeechBoundaryWord];
        speechSynthesizer = nil;
    }
}


// Accessors

- (Scene*) firstScene {
    
    if (story.scenes != nil)
        return [story.scenes firstObject];
    else
        return nil;
}


// Actions ------------------------------------------------------------------------------------------------

- (void) startStory: (id) sender {
    // Prevent user from triggering startStory several times in parallel
    startStoryButton.enabled = false;
    
    // Show network indicator in navigation bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    // Show activity indicator view
    [activityIndicatorView show];
    
    TourManager* theTourManager = [TourManager theManager];
    theTourManager.delegate = self;
    
    self.scene = [self.story firstScene];
    [theTourManager startStory: self.story];
    [theTourManager prepareSceneForSearch: self.scene];
}


- (IBAction) speakText: (id) sender {
    if (speechSynthesizer == nil) {
        speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    
    @try {
        if (![speechSynthesizer isSpeaking] && ![speechSynthesizer isPaused]) {
            // Start speaking
            AVSpeechUtterance* speechUtterance = [AVSpeechUtterance speechUtteranceWithString: storyTextView.text];
            speechUtterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"de-DE"];
            
            [speechSynthesizer speakUtterance: speechUtterance];
        }
        else if ([speechSynthesizer isSpeaking] && ![speechSynthesizer isPaused]) {
            // Pause speaking
            [speechSynthesizer pauseSpeakingAtBoundary: AVSpeechBoundaryWord];
        }
        else if ([speechSynthesizer isPaused]) {
            // Continue speaking
            [speechSynthesizer continueSpeaking];
        }
    }
    @catch (NSException* exception) {
        NSLog(@"SpeechSynthesizer: failure. The device is probably set on mute.");
    }
}



// TourManager delegate methods ----------------------------------------------------------------------------

- (void) didFinishLoadingObject3D: object3D {
    NSAssert(object3D != nil, @"StoryViewController: loaded object3D is nil");
    
    // Let TourManager load details of first scene
    TourManager* theTourManager = [TourManager theManager];
    theTourManager.delegate = self;
    [theTourManager prepareSceneForSearch: self.scene];
}


- (void) didLoadFractionOfAdventures: (float) fraction; {
    // [activityIndicator setProgress: fraction animated: YES];
}


- (void) didFailPreparingSceneWithError: (NSError*) error {
    
    // Stop network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    
    // Hide activity indicator view
    [activityIndicatorView hide];
    
    if (error != nil) {
        // Show error to user
        
        NSString* title = NSLocalizedString(@"STORY_SERVER_ACCESS_PROBLEM_DLG_TITLE", @"Server access problem");
        NSString* errorMsg = error.localizedDescription;
        
        if (error.localizedFailureReason != nil) {
            errorMsg = [errorMsg stringByAppendingString: error.localizedFailureReason];
            
            if (error.localizedRecoverySuggestion != nil) {
                errorMsg = [errorMsg stringByAppendingString: error.localizedRecoverySuggestion];
            }
        }
        
        [self showAlertWithTitle: title errorMessage: errorMsg];
    }
}


- (void) didFinishPreparingScene: (Scene*) aScene {
    
    // Stop network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    
    // Hide activity indicator view
    [activityIndicatorView hide];

    // Enable startStory button
    startStoryButton.enabled = true;
    
    // Goto scene
    self.scene = aScene;
    [self performSegueWithIdentifier: @"SceneView" sender: self];
}



// Segue methods ------------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SceneView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [SceneViewController class]]) {
            
            // Get reference to the destination view controller
            SceneViewController* sceneViewController = (SceneViewController*) destController;
            
            // Pass the scene
            sceneViewController.adventure = self.adventure;
            sceneViewController.story = self.story;
            sceneViewController.scene = self.scene;
        }
    }
}

// Unwind segue

- (IBAction) gotoNextScene: (UIStoryboardSegue*) sender {
    
    // Prevent user from triggering another story start action
    startStoryButton.enabled = false;

    
    // Switch to next scene (if any)
    Scene* nextScene = [self.story nextSceneTo: self.scene];
    if (nextScene != nil) {
        // Show activity indicator view
        [activityIndicatorView show];
        
        // Show network indicator in navigation bar
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
        
        self.scene = nextScene;
        [[TourManager theManager] prepareSceneForSearch: nextScene];
    }
    else {
        NSString* title = NSLocalizedString(@"STORY_FINISHED_DLG_TITLE", @"Story finished dialog title");
        NSString* successMsg = NSLocalizedString(@"STORY_FINISHED_DLG_MESSAGE", @"Story finished message");
        
        [self showMessageWithTitle: title message: successMsg];
    }
    
}



@end
