//
//  SceneViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 16.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "SceneViewController.h"
#import "SceneMapViewController.h"


#define kARGamePinAnnotationIdent @"ARGamePinAnnotationView"


@implementation SceneViewController


@synthesize adventure, sceneViewTitle, adventureNameLabel, story, storyNameLabel, scene, sceneNameLabel,
            cacheNrLabel, sceneTextView, sceneMapView, speechSynthesizer;


// Initialisation

- (void) dealloc {
    adventure = nil;
    adventureNameLabel = nil;
    story = nil;
    storyNameLabel = nil;
    scene = nil;
    sceneNameLabel = nil;
    cacheNrLabel = nil;
    sceneTextView = nil;
    sceneMapView = nil;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (scene != nil) {
        // Initialise outlets
        NSString* viewTitle = NSLocalizedString(@"SCENE_VIEW_TITLE", @"SceneView title");
        sceneViewTitle.title = viewTitle;
        adventureNameLabel.text = adventure.name;
        storyNameLabel.text = story.name;
        
        sceneNameLabel.text = scene.name;
        NSString* cacheLabel = NSLocalizedString(@"SCENE_CACHE_NR_LABEL", @"Cache number label");
        cacheNrLabel.text = [NSString stringWithFormat: cacheLabel, scene.seqNr];
        sceneTextView.text = scene.text;
        
        // Remove insets in sceneTextView
        sceneTextView.textContainerInset = UIEdgeInsetsMake(0, -3, 0, 0);
        
        // sceneMapView
        if (scene != nil) {
            // Set cache location
            [sceneMapView addAnnotation: scene.cache];
            sceneMapView.delegate = self;
            
            // Set tap callback
        }

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



// Annotation View Customisation ---------------------------------------------------------------

- (MKAnnotationView*) mapView: (MKMapView*) theMapView viewForAnnotation: (id<MKAnnotation>) annotation {
    
    // We don't have a view for user location pin
    if ([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    // Try to dequeue an existing pin view first
    MKPinAnnotationView* pinView = (MKPinAnnotationView*) [sceneMapView dequeueReusableAnnotationViewWithIdentifier: kARGamePinAnnotationIdent];
    
    // If no pin view already exists, create a new one
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation: annotation
                                                  reuseIdentifier: kARGamePinAnnotationIdent];
    }
    
    pinView.pinTintColor = [UIColor purpleColor];
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    
    // Add custom image
    UIImageView* treasureMapImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"treasure-map-icon-32.png"]];
    pinView.leftCalloutAccessoryView = treasureMapImage;
    
    // Prepare detail view
    pinView.detailCalloutAccessoryView = nil;
    
    return pinView;
}


// Actions ------------------------------------------------------------------------------------------------

- (IBAction) speakText: (id) sender {
    if (speechSynthesizer == nil) {
        speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    
    @try {
        if (![speechSynthesizer isSpeaking] && ![speechSynthesizer isPaused]) {
            // Start speaking
            AVSpeechUtterance* speechUtterance = [AVSpeechUtterance speechUtteranceWithString: sceneTextView.text];
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


- (void) showCacheOnMap:(id)sender {
    // Goto map showing the cache
    [self performSegueWithIdentifier: @"SceneMapView" sender: self];

}


// Segue methods ------------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SceneMapView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [SceneMapViewController class]]) {
            
            // Get reference to the destination view controller
            SceneMapViewController* sceneMapViewController = (SceneMapViewController*) destController;
            
            // Pass the cache location
            sceneMapViewController.scene = self.scene;
        }
    }
}


@end
