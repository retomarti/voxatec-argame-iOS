//
//  NamedObject.h
//  AR-Quest
//
//  Created by Reto Marti on 13/05/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#ifndef NamedObject_h
#define NamedObject_h

#import "ARObject.h"


@interface NamedObject : ARObject <NSCoding> {
}

@property (atomic, strong) NSString* name;
@property (atomic, strong) NSString* text;

@end


#endif /* NamedObject_h */
