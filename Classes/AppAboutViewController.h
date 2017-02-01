//
//  AppAboutViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "ARGameViewController.h"
#import "TourManager.h"


@interface AppAboutViewController : ARGameViewController <TourManagerDelegate> {
    
}

@property (atomic, retain) NSArray* adventures;

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem* augmentedRealityTitleLabel;
@property (strong, nonatomic) IBOutlet UIProgressView* activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton* findNearbyAdventuresButton;

// Actions
- (IBAction) findNearbyAdventures: (id) sender;

@end
