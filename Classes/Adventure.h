//
//  Adventure.h
//  AR-Quest
//
//  Created by Reto Marti on 20/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------


#ifndef Adventure_h
#define Adventure_h

#import "NamedObject.h"
#import "Story.h"


@interface Adventure : NamedObject {
}

@property (atomic, strong) NSMutableArray* stories;

+ (Adventure*) newAdventure;
- (Story*) nextStoryTo: (Story*) story;
   
   
@end


#endif /* Adventure_h */
