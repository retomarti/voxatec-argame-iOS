//
//  ARGameViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 30.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//

#import "ARGameViewController.h"

@interface ARGameViewController ()

@end

@implementation ARGameViewController


// Common functions ------------------------------------------------------------------------------------------------------------

- (void) showMessageWithTitle: (NSString*) title message: (NSString*) message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: message
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault
                                                          handler: ^(UIAlertAction * action) {}];
    
    [alert addAction: defaultAction];
    [self presentViewController: alert animated: YES completion: nil];
    
}


- (void) showAlertWithTitle: (NSString*) title errorMessage: (NSString*) message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                   message: message
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault
                                                          handler: ^(UIAlertAction * action) {}];
    
    [alert addAction: defaultAction];
    [self presentViewController: alert animated: YES completion: nil];
    
}


- (void) showDimBackgroundView {
    if (dimBackgroundView == NULL) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        dimBackgroundView = [[UIView alloc] initWithFrame:screenRect];
        dimBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }

    [self.view addSubview: dimBackgroundView];
}


- (void) hideDimBackgroundView {
    [dimBackgroundView removeFromSuperview];
}


@end
