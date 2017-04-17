//
//  Adventure.m
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


#import "Adventure.h"



@implementation Adventure

@synthesize stories;


- (id) init {
    self = [super init];
    
    if (self) {
        stories = [[NSMutableArray alloc] init];
    }
    
    return self;
}


+ (Adventure*) newAdventure {
    Adventure* adventure = [[Adventure alloc] init];
    return adventure;
}


- (void) dealloc {
    stories = nil;
}


- (Story*) lastStory {
    return [stories lastObject];
}


- (Story*) nextStoryTo: (Story*) story {
    if (story == nil || story == [self lastStory])
        return nil;
    else {
        NSUInteger idx = [stories indexOfObject: story];
        Story* nextStory = [stories objectAtIndex: idx+1];
        return nextStory;
    }
}


@end
