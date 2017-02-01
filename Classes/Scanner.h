//
//  Scanner.h
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>


// Characters
#define NUL		0x00
#define SPACE	0x20
#define TAB		0x09
#define LF		0x0A
#define CR		0x0D


@interface Scanner : NSObject

BOOL isDigit (char aChar);
BOOL isIdentStartChar (char aChar);
BOOL isIdentChar (char aChar);
BOOL isSeparator (char aChar);
BOOL isControlChar (char aChar);

@end
