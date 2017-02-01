//
//  File.m
//  AR-Quest
//
//  Created by Reto Marti on 03/02/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "File.h"


@implementation File

@synthesize contentType, content;


- (void) dealloc {
    contentType = nil;
    content = nil;
}



@end