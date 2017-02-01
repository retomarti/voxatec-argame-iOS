//
//  ActivityIndicatorView.m
//  AR-Quest
//
//  Created by Reto Marti on 22.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "ActivityIndicatorView.h"

// Geometry
#define kIndicatorSize 40
#define kIndicatorLabelWidth 200
#define kIndicatorLabelOffset 0
#define kVibrancyViewMargin 10


@implementation ActivityIndicatorView

// Initialisation

- (id) init {
    self = [super init];
    
    if (self) {
        // Init glassPane
        // UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight];
        // glassPane = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
        glassPane = [UIVisualEffectView new];
        glassPane.backgroundColor = [UIColor blackColor];
        glassPane.alpha = 0.6;
        
        // Init vibrancyView
        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
        vibrancyView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];

        // Init activityIndicator
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        // Init label
        label = [[UILabel alloc] init];
        
        [self setupView];
    }
    
    return self;
}

/*
- (id) initWithCoder:(NSCoder*) aDecoder {
    self = [self initWithText: @""];
    
    if (self) {
        
    }
    
    return self;
}
*/

- (id) initWithText:(NSString*) text {
    self = [self init];
    
    if (self) {
        label.text = text;
    }
    
    return self;
}


- (void) setupView {
    // Add my elements
    [self addSubview: glassPane];
    [self addSubview: vibrancyView];
    [vibrancyView addSubview: activityIndicator];
    [vibrancyView addSubview: label];
    [activityIndicator startAnimating];
}


// View management

- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    // Set glassPane size
    // UIWindow* window = [UIApplication sharedApplication].windows.firstObject;
    // self.frame = window.frame;

    CGRect viewRect = [[UIScreen mainScreen] bounds];
    self.frame = viewRect;
    CGFloat height = self.frame.size.height;
    CGFloat width  = self.frame.size.width;
    
    // Glass Pane
    glassPane.frame = self.frame;
    
    // Vibrancy View
    CGRect vibViewRect = CGRectMake(
        width/2 - (kVibrancyViewMargin + kIndicatorSize + kIndicatorLabelOffset + kIndicatorLabelWidth) / 2,
        height / 2 - kIndicatorSize / 2 - kVibrancyViewMargin,
        2*kVibrancyViewMargin + kIndicatorSize + kIndicatorLabelOffset + kIndicatorLabelWidth,
        kIndicatorSize + 2*kVibrancyViewMargin
    );
    vibrancyView.frame = vibViewRect;
    vibrancyView.layer.cornerRadius = 8.0;
    vibrancyView.layer.masksToBounds = true;
    
    // Activity indicator
    activityIndicator.frame = CGRectMake(kVibrancyViewMargin,
                                         kVibrancyViewMargin,
                                         kIndicatorSize,
                                         kIndicatorSize);
    activityIndicator.color = [UIColor blackColor];
    
    // Label
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(kVibrancyViewMargin + kIndicatorSize + kIndicatorLabelOffset,
                             kVibrancyViewMargin,
                             kIndicatorLabelWidth,
                             kIndicatorSize);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize: 16];
}


- (void) show {
    // Add glass pane
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    
    if (self.superview == nil) {
        [currentWindow addSubview: self];
    }
    
    glassPane.hidden = false;
    self.hidden = false;
}


- (void) hide {
    glassPane.hidden = true;
    self.hidden = true;
}

@end
