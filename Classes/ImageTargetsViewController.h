/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import <QCAR/DataSet.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageTargetsEAGLView.h"
#import "SampleApplicationSession.h"
#import "SampleAppMenuViewController.h"
#import "ARGameViewController.h"
#import "Story.h"
#import "Scene.h"


@interface ImageTargetsViewController : ARGameViewController <SampleApplicationControl,SampleAppMenuDelegate, SceneTrackerDelegate,AVAudioPlayerDelegate> {
    QCAR::DataSet*  dataSetCurrent;
    
    // menu options
    BOOL extendedTrackingEnabled;
    BOOL continuousAutofocusEnabled;
    BOOL flashEnabled;
    BOOL frontCameraEnabled;
}

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem* imageTargetsViewTitle;
@property (strong, nonatomic) ImageTargetsEAGLView* eaglView;
@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (strong, nonatomic) SampleApplicationSession* vapp;
@property (readwrite, nonatomic) BOOL showingMenu;
@property (strong, nonatomic) UIBarButtonItem* showRiddleButton;

// Data model
@property (nonatomic, strong) Scene* scene;

// Actions
- (IBAction) showRiddle: (id)sender;

// AVAudioPlayerDelegate
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
- (void) audioPlayerDecodeErrorDidOccur: (AVAudioPlayer*) player error:(NSError *)error;

// SceneTrackerDelegate
- (void) startTrackingScene: (Scene*) aScene;
- (void) endTrackingScene: (Scene*) aScene;
@end
