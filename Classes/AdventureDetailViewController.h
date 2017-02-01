//
//  AdventureDetailViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 20.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Adventure.h"


@interface AdventureDetailViewController : UIViewController

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem *detailViewTitle;
@property (strong, nonatomic) IBOutlet UILabel *adventureLabel;
@property (strong, nonatomic) IBOutlet UILabel *adventureNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *adventureTextView;

// Data model
@property (strong, nonatomic) Adventure* adventure;

// Utilities
@property (strong, nonatomic) AVSpeechSynthesizer* speechSynthesizer;

// Actions
- (IBAction) speakText: (id) sender;

@end
