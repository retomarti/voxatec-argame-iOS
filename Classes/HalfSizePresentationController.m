//
//  HalfSizePresentationController.m
//  AR-Quest
//
//  Created by Reto Marti on 04.02.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "HalfSizePresentationController.h"

#define kOffsetX 10.0
#define kOffsetY 20.0


@implementation HalfSizePresentationController


- (CGRect) frameOfPresentedViewInContainerView {
    return CGRectMake(kOffsetX,
                      self.containerView.bounds.size.height/2 - kOffsetY,
                      self.containerView.bounds.size.width - 2*kOffsetX,
                      self.containerView.bounds.size.height/2);
}

- (BOOL) shouldPresentInFullscreen {
    return NO;
}

@end
