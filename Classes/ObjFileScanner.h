//
//  ObjFileScanner.h
//  AR-Quest
//
//  Created by Reto Marti on 23.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Scanner.h"

// Known Symbols
typedef enum ObjFileSymbol {
    // General symbols
	sym_UNKNOWN,			// Unknown symbol
    sym_EOL,                // End of line (LF)
	sym_EOT,				// End of text
	
    // Line header keywords
	sym_V,					// Vertex line header
	sym_VN,                 // Normal line header
	sym_VT,                 // Texture line header
	sym_F,                  // Face line header
	sym_O,					// Object line header
	sym_MTLLIB,				// Material library line header
    sym_USEMTL,             // Use material line header
    sym_S,                  // Smooth shading ON / OFF
    sym_G,                  // Vertex group
    
    sym_INT,                // Integer number
    sym_FLOAT,				// Float number
	sym_IDENT,				// Identifier, e.g. object name, matlib name

	// Misc symbols
	sym_SLASH,       		// '/'
    sym_L_BRACKET,       	// '('
    sym_R_BRACKET       	// ')'
    
} ObjFileSymbol;


// Scanner Position
typedef struct ObjFileScanPosition {
	NSUInteger idx;
	NSUInteger lineNr;
	NSUInteger colNr;
	ObjFileSymbol sym;
} ObjFileScanPosition;


// Scanner State
typedef struct ObjFileScanState {
	ObjFileScanPosition pos;
	ObjFileScanPosition tokenStart;
} ObjFileScanState;


// Keyword Table Entry
#define MAX_KEYWORDS   20



/*------------------------------------------------------------
  Class Scanner: instances of this class implement a lexical
  analyzer of the WaveFront OBJ file format. The scanner expects 
  a text containing \n end of line charaters.
-------------------------------------------------------------*/

@interface ObjFileScanner : Scanner {
	@protected 
	const char* text;
	
	// Keyword table
	NSString* keyword [MAX_KEYWORDS];
    ObjFileSymbol keyword_sym [MAX_KEYWORDS];
    uint keywordCount;
	
	// Position
	ObjFileScanPosition pos;
	ObjFileScanPosition tokenStart;
	
	// Character on pos
	char ch;
}

// Creation
+ (ObjFileScanner*) newScanner;

// Initialization
- (void) setText: (const char*) aText;
- (void) reset;

// Scanning
- (void) readNextSym;
- (void) readNextLine;

// Accessors
- (ObjFileSymbol) sym;      // current symbol
- (NSString*) token;        // current token
- (NSString*) symName: (ObjFileSymbol) aSymbol; // end-user readable string of given symbol
- (BOOL) atEOT;				// end-of-text eached?
- (NSUInteger) lineNr;		// current line number
- (NSUInteger) colNr;		// urrent column number

@end
