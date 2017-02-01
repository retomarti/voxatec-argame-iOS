//
//  File.h
//  AR-Quest
//
//  Created by Reto Marti on 03/02/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#ifndef File_h
#define File_h

#import "NamedObject.h"


@interface File: NamedObject {
    
}
@property (atomic, strong) NSString* contentType;
@property (atomic, strong) NSData* content;

@end


#endif /* File_h */
