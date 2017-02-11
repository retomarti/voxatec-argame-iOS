//
//  RiddleViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 16.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "Story.h"
#import "Scene.h"
#import "TourManager.h"


@interface RiddleViewController : UIViewController <UITextFieldDelegate>

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem* riddleViewTitle;
@property (strong, nonatomic) IBOutlet UITextView* introTextView;
@property (strong, nonatomic) IBOutlet UILabel* challengeNameLabel;
@property (strong, nonatomic) IBOutlet UITextView* challengeTextView;
@property (strong, nonatomic) IBOutlet UILabel* responseNameLabel;
@property (strong, nonatomic) IBOutlet UITextField* responseTextView;
@property (strong, nonatomic) IBOutlet UIButton* validateButton;
@property (strong, nonatomic) IBOutlet UITextView* validationResultTextView;
@property (strong, nonatomic) IBOutlet UIButton* gotoNextSceneButton;


// Data model
@property (strong, nonatomic) Scene* scene;

// Actions
- (IBAction) validateResponse: (id) sender;

// UITextField delegate
- (BOOL) textFieldShouldReturn: (UITextField*) textField;

@end
