//
//  MtlFileParser.h
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MtlFileScanner.h"
#import "SyntaxError.h"
#import "Material.h"


@interface MtlFileParser : NSObject {
    @protected
	MtlFileScanner* scanner;
}
@property (atomic, retain) NSMutableArray* materials;
@property (atomic, retain) Material* material;

- (SyntaxError*) parseMtlFileWithName: (NSString*) fileName;
- (Material*) materialWithName: (NSString*) aMaterialName;

@end
