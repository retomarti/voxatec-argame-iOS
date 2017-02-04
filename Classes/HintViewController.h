//
//  HintViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 03.02.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>


@protocol HintViewControllerDelegate
@optional
- (void) hintViewDismissed;
@end


@interface HintViewController : UIViewController

// Properties
@property (strong, nonatomic) NSString* hintText1;
@property (strong, nonatomic) NSString* hintText2;
@property (strong, nonatomic) id <HintViewControllerDelegate> delegate;

// Outlets
@property (strong, nonatomic) IBOutlet UIVisualEffectView* visualEffectView;
@property (strong, nonatomic) IBOutlet UISegmentedControl* hintSegmentControl;
@property (strong, nonatomic) IBOutlet UITextView* hintTextView;
@property (strong, nonatomic) IBOutlet UIButton* dismissButton;

// Actions
- (IBAction) dismissHint: (id) sender;
- (IBAction) hintSelectionChanged: (id) sender;


@end
