//
//  AdventureDetailViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 20.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "AdventureDetailViewController.h"


@interface AdventureDetailViewController ()

@end



@implementation AdventureDetailViewController

@synthesize adventure, detailViewTitle, adventureLabel, adventureNameLabel, subtitleLabel, adventureTextView, speechSynthesizer;


// View management ------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initialise outlets
    NSString* titleText = NSLocalizedString(@"ADV_DETAIL_VIEW_TITLE", @"AdventureDetailView title");
    detailViewTitle.title = titleText;
    adventureNameLabel.text = adventure.name;
    NSString* aboutLabel = NSLocalizedString(@"ADV_WHATS_ABOUT_LABEL", @"What's about");
    subtitleLabel.text = aboutLabel;
    adventureTextView.text = adventure.text;
    
    // Remove insets in adventureTextView
    adventureTextView.textContainerInset = UIEdgeInsetsMake(0, -3, 0, 0);
}


- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear: animated];
    
    // Reset speechSynthesizer
    if (speechSynthesizer != nil) {
        [speechSynthesizer stopSpeakingAtBoundary: AVSpeechBoundaryWord];
        speechSynthesizer = nil;
    }
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Actions ------------------------------------------------------------------------------------------------

- (IBAction) speakText: (id) sender {
    if (speechSynthesizer == nil) {
        speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    
    @try {
        if (![speechSynthesizer isSpeaking] && ![speechSynthesizer isPaused]) {
            // Start speaking
            AVSpeechUtterance* speechUtterance = [AVSpeechUtterance speechUtteranceWithString: adventureTextView.text];
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
        NSLog(@"SpeechSynthesizer: failure. The device is probably set to mute.");
    }
}

@end
