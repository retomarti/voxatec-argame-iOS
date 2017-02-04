//
//  AppAboutViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <QuartzCore/QuartzCore.h>
#import "AppAboutViewController.h"
#import "TourManager.h"
#import "AdventureListViewController.h"


@implementation AppAboutViewController


@synthesize adventures, augmentedRealityTitleLabel, findNearbyAdventuresButton, activityIndicator;


// Initialisation -----------------------------------------------------------------------------------------


- (void) dealloc {
    adventures = nil;
    activityIndicator = nil;
}



// View management

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Setup title
    NSString* titleText = NSLocalizedString(@"ADV_AUGMENTED_REALITY_ADVENTURES_TITLE", @"Augmented Reality Adventure Title");
    augmentedRealityTitleLabel.title = titleText;

    // Setup button
    NSString* buttonText = NSLocalizedString(@"ADV_FIND_NEARBY_ADVENTURES_TEXT", @"Find nearby Adventures button text");
    [findNearbyAdventuresButton setTitle: buttonText forState: UIControlStateNormal];
    [findNearbyAdventuresButton.layer setBorderWidth: 0.5f];
    [findNearbyAdventuresButton.layer setBorderColor: [[UIColor grayColor] CGColor]];
    findNearbyAdventuresButton.enabled = YES;
}


- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    
    /*
    // Make a bottom line to the navigation bar
    CGFloat lineWidth = 1.0;
    UIColor* lineColor = [UIColor grayColor];
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    CGRect bottomBorderRect = CGRectMake(0,
                                         CGRectGetHeight(navigationBar.frame),
                                         CGRectGetWidth(navigationBar.frame),
                                         lineWidth);
    UIView* bottomBorder = [[UIView alloc] initWithFrame: bottomBorderRect];
    [bottomBorder setBackgroundColor: lineColor];
    [navigationBar addSubview:bottomBorder];
    */
}


// Action methods -----------------------------------------------------------------------------------------

- (IBAction) findNearbyAdventures: (id) sender {
    
    // Disable button
    findNearbyAdventuresButton.enabled = NO;
    
    // Turn-on network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    
    // Loud tour infos
    TourManager* theManager = [TourManager theManager];
    theManager.delegate = self;
    [theManager loadNearbyAdventures];
}


// TourManager delegate methods ----------------------------------------------------------------------------

- (void) didFinishLoadingAdventures: (NSArray*) anAdventureList {
    
    adventures = anAdventureList;
    
    // Turn-off network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    
    // Enable button
    findNearbyAdventuresButton.enabled = YES;

    // Goto next scene
    [self performSegueWithIdentifier: @"AdventureListView" sender: self];
}


- (void) didLoadFractionOfAdventures: (float) fraction; {
    [activityIndicator setProgress: fraction animated: YES];
}


- (void) didFailLoadingAdventuresWithError: (NSError*) error {
    
    // Turn-off network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];

    // Show error to user
    if (error != nil) {
        NSString* errorTitle = NSLocalizedString(@"GEN_SERVER_ACCESS_PROBLEM_DLG_TITLE", "Server access problem dialog title");
        NSString* errorMsg = error.localizedDescription;
        
        if (error.localizedFailureReason != nil) {
            errorMsg = [errorMsg stringByAppendingString: error.localizedFailureReason];
            
            if (error.localizedRecoverySuggestion != nil) {
                errorMsg = [errorMsg stringByAppendingString: error.localizedRecoverySuggestion];
            }
        }
        
        [self showAlertWithTitle: errorTitle errorMessage: errorMsg];
    }
}


// Segue methods --------------------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString: @"AdventureListView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass:[AdventureListViewController class]]) {

            // Get reference to the destination view controller
            AdventureListViewController* advListViewController = (AdventureListViewController*) destController;
        
            // Pass adventures to destination controller
            advListViewController.adventures = adventures;
        }
    }
}


@end
