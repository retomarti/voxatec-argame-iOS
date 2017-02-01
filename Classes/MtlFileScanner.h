//
//  MtlFileScanner.h
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "Scanner.h"


// Known Symbols
typedef enum MtlFileSymbol {
    // General symbols
	sym_mtl_UNKNOWN,			// Unknown symbol
    sym_mtl_EOL,                // End of line (LF)
	sym_mtl_EOT,				// End of text
	
    // Line header keywords
    sym_mtl_NEWMTL,             // newmtl
	sym_mtl_Ka,					// Ambient light coefficient
	sym_mtl_Ks,                 // Specular light coefficient
	sym_mtl_Kd,                 // Diffuse light coefficient
    sym_mtl_Ns,                 // Specular light exponent
    sym_mtl_Map_Ka,             // Ambient texture map
    sym_mtl_Map_Ks,             // Specular texture map
    sym_mtl_Map_Kd,             // Diffuse texture map
    
    sym_mtl_INT,                // Integer number
    sym_mtl_FLOAT,				// Float number
	sym_mtl_IDENT,				// Identifier, e.g. object name, matlib name
    
	// Misc symbols
	sym_mtl_MINUS,       		// '-'
    sym_mtl_L_BRACKET,          // '('
    sym_mtl_R_BRACKET           // ')'
    
} MtlFileSymbol;


// Scanner Position
typedef struct MtlFileScanPosition {
	NSUInteger idx;
	NSUInteger lineNr;
	NSUInteger colNr;
	MtlFileSymbol sym;
} MtlFileScanPosition;


// Scanner State
typedef struct MtlFileScanState {
	MtlFileScanPosition pos;
	MtlFileScanPosition tokenStart;
} MtlFileScanState;


// Keyword Table Entry
#define MAX_KEYWORDS   20



@interface MtlFileScanner : Scanner {
    @protected
    const char* text;

    // Keyword table
    NSString* keyword [MAX_KEYWORDS];
    MtlFileSymbol keyword_sym [MAX_KEYWORDS];
    uint keywordCount;

    // Position
    MtlFileScanPosition pos;
    MtlFileScanPosition tokenStart;

    // Character on pos
    char ch;
}

// Creation
+ (MtlFileScanner*) newScanner;

// Initialization
- (void) setText: (const char*) aText;
- (void) reset;

// Scanning
- (void) readNextSym;
- (void) readNextLine;

// Accessors
- (MtlFileSymbol) sym;
- (NSString*) token;
- (NSString*) symName: (MtlFileSymbol) aSymbol;
- (BOOL) atEOT;				// returns whether end-of-text is reached
- (NSUInteger) lineNr;		// returns current line number
- (NSUInteger) colNr;		// returns current column number

@end
