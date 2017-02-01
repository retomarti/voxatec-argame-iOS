//
//  AppNavigationController.h
//  AR-Quest
//
//  Created by Reto Marti on 29.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>


@interface AppNavigationController : UINavigationController

// Statusbar overrides
- (BOOL) prefersStatusBarHidden;
- (UIStatusBarStyle) preferredStatusBarStyle;

@end
