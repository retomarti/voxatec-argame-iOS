//
//  AppNavigationController.m
//  AR-Quest
//
//  Created by Reto Marti on 29.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "AppNavigationController.h"

@interface AppNavigationController ()

@end



@implementation AppNavigationController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// NavigationBar Setup -------------------------------------------------------------------------------

- (void) setupNavigationBar {
    
    // Retrieve navigationBar
    UINavigationBar* navigationBar = self.navigationBar;  // alternativ: [UINavigationBar appearance]
    
    // Set navigationBar colors
    navigationBar.tintColor = [UIColor whiteColor];
    
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"red-wood.jpg"] forBarMetrics: UIBarMetricsDefault];
    navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject: [UIColor whiteColor]
                                                                    forKey: NSForegroundColorAttributeName];
    
    // Set shadow below navigationBar
    navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    navigationBar.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    navigationBar.layer.shadowRadius = 4.0f;
    navigationBar.layer.shadowOpacity = 1.0f;
    navigationBar.layer.masksToBounds = NO;
    
}


// StatusBar Setup -----------------------------------------------------------------------------------

- (BOOL) prefersStatusBarHidden {
    // Make sure that statusbar is shown
    return NO;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
