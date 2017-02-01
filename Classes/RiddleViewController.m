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

#define kIntroText @"Bevor du das nächsten Cache suchen kannst, musst du zuerst das folgende Rätsel lösen."
#define kValidationResultTextOK @"Gratulation. Du hast das Rätsel gelöst und kannst nun das nächste Versteck suchen gehen."
#define kValidationResultTextFail @"Deine Antwort ist leider falsch. Probier es doch noch einmal."



@implementation RiddleViewController

@synthesize scene, riddleViewTitle, introTextView,
            challengeNameLabel, challengeTextView, responseNameLabel, responseTextView,
            validateButton, validationResultTextView, gotoNextSceneButton;


// Initialisation

- (void) dealloc {
    scene = nil;
    challengeNameLabel = nil;
    challengeTextView = nil;
    responseNameLabel = nil;
    responseTextView = nil;
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
            introTextView.text = kIntroText;
            challengeTextView.text = scene.riddle.challenge;
            responseTextView.delegate = self;
            validateButton.hidden = false;
            validationResultTextView.hidden = true;
            gotoNextSceneButton.hidden = true;
        }
    }
}

// Actions ------------------------------------------------------------------------------------------------

- (void) validateResponse:(id)sender {
    NSString* playerResponse = [self.responseTextView.text uppercaseString];
    NSString* correctResponse = [scene.riddle.response uppercaseString];
    
    if ([playerResponse isEqualToString: correctResponse]) {
        // Response was correct
        validationResultTextView.text = kValidationResultTextOK;
        validationResultTextView.hidden = false;
        validationResultTextView.textColor = [UIColor colorWithRed: 0.245 green: 0.578 blue: 0.317 alpha: 1.0];;
        gotoNextSceneButton.hidden = false;
        validateButton.hidden = true;
    }
    else {
        // Response was wrong
        validationResultTextView.text = kValidationResultTextFail;
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

