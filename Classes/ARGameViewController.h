//
//  ARGameViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 30.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>


@interface ARGameViewController : UIViewController {
    @protected
    UIView* dimBackgroundView;
}

// Some common functions to our ViewControllers
- (void) showMessageWithTitle: (NSString*) title message: (NSString*) message;
- (void) showAlertWithTitle: (NSString*) title errorMessage: (NSString*) message;
- (void) showDimBackgroundView;
- (void) hideDimBackgroundView;

@end
