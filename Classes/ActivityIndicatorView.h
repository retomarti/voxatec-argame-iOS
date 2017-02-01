//
//  ActivityIndicatorView.h
//  AR-Quest
//
//  Created by Reto Marti on 22.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface ActivityIndicatorView : UIView {
    @protected
    UIActivityIndicatorView* activityIndicator;
    UILabel* label;
    UIVisualEffectView* vibrancyView;
    UIVisualEffectView* glassPane;
}

// Initialisation
- (id) initWithText: (NSString*) text;

// Visibility
- (void) show;
- (void) hide;

@end
