//
//  HintViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 03.02.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "HintViewController.h"


@implementation HintViewController

@synthesize visualEffectView, hintSegmentControl, hintText1, hintText2, hintTextView, dismissButton,
            delegate;



// View management -----------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Configure background view
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight];
    visualEffectView.effect = blurEffect;
    visualEffectView.layer.cornerRadius = 20.0;
    visualEffectView.layer.masksToBounds = true;
    
    // Setup control texts
    NSString* segmentText = NSLocalizedString(@"SCENE_HINT_SEG_BTN_1_TEXT", @"Title of segement button 1");
    [hintSegmentControl setTitle: segmentText forSegmentAtIndex: 0];
    segmentText = NSLocalizedString(@"SCENE_HINT_SEG_BTN_2_TEXT", @"Title of segement button 2");
    [hintSegmentControl setTitle: segmentText forSegmentAtIndex: 1];
    
    // Set hint text
    hintTextView.text = hintText1;
    
    // Setup dismiss button
    NSString* dismissButtonText = NSLocalizedString(@"SCENE_HINT_DISMISS_BTN_TEXT", @"Title of dismiss button");
    dismissButton.titleLabel.text = dismissButtonText;
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Actions --------------------------------------------------------------------------------

- (IBAction) dismissHint: (id) sender {
    [self dismissViewControllerAnimated: YES completion: nil];
    [self.delegate hintViewDismissed];
}

- (IBAction) hintSelectionChanged: (id) sender {
    if (sender == hintSegmentControl) {
        if (hintSegmentControl.selectedSegmentIndex == 0) {
            hintTextView.text = hintText1;
        }
        else {
            hintTextView.text = hintText2;
        }
    }
}

@end
