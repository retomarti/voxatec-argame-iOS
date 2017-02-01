//
//  Riddle.h
//  AR-Quest
//
//  Created by Reto Marti on 04/02/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#ifndef Riddle_h
#define Riddle_h

#import "ARObject.h"

@interface Riddle : ARObject  {
}

@property (atomic, strong) NSString* challenge;
@property (atomic, strong) NSString* response;

- (Boolean) isResponseCorrect: (NSString*) aResponse;

@end


#endif /* Riddle_h */
