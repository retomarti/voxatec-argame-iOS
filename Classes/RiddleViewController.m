//
//  RiddleViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 16.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "RiddleViewController.h"


@implementation RiddleViewController

@synthesize scene, riddleViewTitle, introTextView,
            challengeNameLabel, challengeTextView, responseNameLabel, responseTextView,
            validateButton, validationResultTextView, gotoNextSceneButton, gotoNextStoryButton;


// Initialisation

- (void) dealloc {
    scene = nil;
    challengeNameLabel = nil;
    challengeTextView = nil;
    responseNameLabel = nil;
    responseTextView = nil;
    gotoNextSceneButton = nil;
    gotoNextStoryButton = nil;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (scene != nil) {
        // Initialise outlets
        NSString* viewTitle = NSLocalizedString(@"RIDDLE_VIEW_TITLE", @"RiddleView Titel");
        riddleViewTitle.title = viewTitle;
        
        NSString* labelText = NSLocalizedString(@"RIDDLE_CHALLENGE_LABEL_TEXT", @"Challenge Label Text");
        challengeNameLabel.text = labelText;
        
        labelText = NSLocalizedString(@"RIDDLE_RESPONSE_LABEL_TEXT", @"Response Label Text");
        responseNameLabel.text = labelText;
        
        NSString* buttonText = NSLocalizedString(@"RIDDLE_VALIDATE_BUTTON_TEXT", @"Validate Button Text");
        validateButton.titleLabel.text = buttonText;
        
        buttonText = NSLocalizedString(@"RIDDLE_NEXT_SCENE_BUTTON_TEXT", @"Goto Next Scene Button Text");
        gotoNextSceneButton.titleLabel.text = buttonText;
        
        if (scene.riddle != nil && scene.riddle.challenge != nil) {
            introTextView.text = NSLocalizedString(@"RIDDLE_INTRO_TEXT", @"Riddle Intro Text");
            challengeTextView.text = scene.riddle.challenge;
            responseTextView.delegate = self;
            validateButton.hidden = false;
            validationResultTextView.hidden = true;
            gotoNextSceneButton.hidden = true;
            gotoNextStoryButton.hidden = true;
        }
    }
}

// Actions ------------------------------------------------------------------------------------------------

- (void) validateResponse:(id)sender {
    // Hide keyboard
    [self.view endEditing:YES];
    
    NSString* playerResponse = [self.responseTextView.text uppercaseString];
    NSString* correctResponse = [scene.riddle.response uppercaseString];
    
    if ([playerResponse isEqualToString: correctResponse]) {
        // Response was correct
        validateButton.hidden = true;
        
        // Activate nextScene / nextStory button
        if ([[TourManager theManager] isLastScene: scene]) {
            validationResultTextView.text = NSLocalizedString(@"RIDDLE_SUCCESS_TEXT_TO_NEXT_STORY", @"Riddle OK Text & next Story");
            validationResultTextView.hidden = false;
            validationResultTextView.textColor = [UIColor colorWithRed: 0.245 green: 0.578 blue: 0.317 alpha: 1.0];;
            gotoNextStoryButton.hidden = false;
        }
        else {
            validationResultTextView.text = NSLocalizedString(@"RIDDLE_SUCCESS_TEXT_TO_NEXT_CACHE", @"Riddle OK Text & next Cache");
            validationResultTextView.hidden = false;
            validationResultTextView.textColor = [UIColor colorWithRed: 0.245 green: 0.578 blue: 0.317 alpha: 1.0];;
            gotoNextSceneButton.hidden = false;
        }
    }
    else {
        // Response was wrong
        validationResultTextView.text = NSLocalizedString(@"RIDDLE_FAILURE_TEXT", @"Riddle Failure Text");
        validationResultTextView.hidden = false;
        validationResultTextView.textColor = [UIColor redColor];
    }
}


// UITextField delegate -----------------------------------------------------------------------------------

-(BOOL) textFieldShouldReturn: (UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}



@end

