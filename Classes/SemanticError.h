//
//  SemanticError.h
//  AR-Quest
//
//  Created by Reto Marti on 23.01.17.
//  Copyright © 2017 Voxatec. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface SemanticError : NSError

@property (nonatomic) NSUInteger lineNr;
@property (nonatomic) NSUInteger colNr;
@property (nonatomic, retain) NSString* errorMsg;

// Standard errors
+ (SemanticError*) fileNotFoundError: (NSString*) fileName onLine: (NSUInteger) lineNr atColumn: (NSUInteger) colNr;

@end
