//
//  MtlFileScanner.m
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import "MtlFileScanner.h"



@implementation MtlFileScanner


// Creation  ---------------------------------------------------------------------------------

+ (MtlFileScanner*) newScanner {
    MtlFileScanner* scanner = [MtlFileScanner new];
    return scanner;
}



// Initialization ------------------------------------------------------------------------------------------

- (void) initKeywordTable {
    keyword[0] = @"newmtl";      keyword_sym[0] = sym_mtl_NEWMTL;
    keyword[1] = @"Ka";          keyword_sym[1] = sym_mtl_Ka;
    keyword[2] = @"Ks";          keyword_sym[2] = sym_mtl_Ks;
    keyword[3] = @"Kd";          keyword_sym[3] = sym_mtl_Kd;
    keyword[4] = @"Ns";          keyword_sym[4] = sym_mtl_Ns;
    keyword[5] = @"map_Ka";      keyword_sym[5] = sym_mtl_Map_Ka;
    keyword[6] = @"map_Ks";      keyword_sym[6] = sym_mtl_Map_Ks;
    keyword[7] = @"map_Kd";      keyword_sym[7] = sym_mtl_Map_Kd;
    
    keywordCount = 8;
}


- (id) init {
    self = [super init];
    if (self) {
        [self resetState];
        [self initKeywordTable];
    }
    return self;
}


- (void) setText: (const char*) aText {
    text = aText;
    
    [self resetState];
}



// State ----------------------------------------------------------------------------------

- (MtlFileScanState) state {
    MtlFileScanState aState;
    
    aState.pos = pos;
    aState.tokenStart = tokenStart;
    return aState;
}


- (void) setState: (MtlFileScanState) aState {
    pos = aState.pos;
    tokenStart = aState.tokenStart;
    
    if (text) {
        ch = text[pos.idx];
    }
}


- (void) resetState {
    pos.idx = 0;
    pos.lineNr = 0;
    pos.colNr = 0;
    pos.sym = sym_mtl_UNKNOWN;
    
    tokenStart = pos;
    
    if (text) {
        ch = text[0];
    }
}


- (void) reset {
    [self setText: nil];
}



// Helpers --------------------------------------------------------------------------------

- (void) readNextChar {
    
    if (![self atEOT]) {
        
        pos.idx++;
        pos.colNr++;
        ch = text[pos.idx];
        
    }
}


- (void) readEOL {
    // UNIX: CR only, Windows: CR LF, MacOSX: LF only
    NSAssert (ch == LF || ch == CR, @"Scanner position not at start of eol");
    
    while (![self atEOT] && (ch == CR || ch == LF)) {
        [self readNextChar];
    }
    
    pos.lineNr++;
    pos.colNr = 0;
    pos.sym = sym_mtl_EOL;
}


- (MtlFileSymbol) lookupKeyword: (NSString*) aIdent {
    int i = 0;
    BOOL found = NO;
    
    while (!found && i < keywordCount) {
        NSString* keyw = keyword[i];
        found = [keyw isEqualToString: aIdent];
        i++;
    }
    
    if (found)
        return keyword_sym[i-1];
    else
        return sym_mtl_IDENT;
}



// Comment -------------------------------------------------------------------------------

- (void) readComment {
    NSAssert (ch == '#', @"Scanner position not at start of comment");
    // '#'
    [self readNextChar];
    
    // Look for LF / EOT
    while (![self atEOT] && !(ch == CR || ch == LF)) {
        [self readNextChar];
    }
    
    // Read over CR/LF
    if (![self atEOT])
        [self readEOL];
}



// Identifier ------------------------------------------------------------------------------

- (void) readIdent {
    [self readNextChar];
    
    if (isIdentStartChar(ch))
        [self readNextChar];
    
    while (isIdentChar(ch) || isDigit(ch)) {
        [self readNextChar];
    }
    
    NSString* identToken = [self token];
    pos.sym = [self lookupKeyword: identToken];
}



// Numbers ---------------------------------------------------------------------------------

- (void) readNumber {
    if (ch == '-' || ch == '+')
        [self readNextChar];
    
    while (isDigit(ch)) {
        [self readNextChar];
    }
    
    if (ch == '.') {
        [self readNextChar];
        
        while (isDigit(ch)) {
            [self readNextChar];
        }
        pos.sym = sym_mtl_FLOAT;
    }
    else
        pos.sym = sym_mtl_INT;
}



// Scanning ------------------------------------------------------------------------------

- (void) readNextSym {
    
    // Read over separators & white space
    while (![self atEOT] && (isSeparator(ch) || isControlChar(ch))) {
        [self readNextChar];
    }
    
    // Read over comment
    while (ch == '#')
        [self readComment];
    
    // EOL ?
    if (ch == CR || ch == LF) {
        [self readEOL];
    }
    
    // Identifier ?
    else if (isIdentStartChar(ch)) {
        tokenStart = pos;
        [self readIdent];
    }
    
    // Integer?
    else if (isDigit(ch) || ch == '-') {
        tokenStart = pos;
        [self readNumber];
    }
    
    // One or two char symbols
    else
        switch (ch) {                
                // EOT
            case NUL:	pos.sym = sym_mtl_EOT; break;
                
                // Minus
            case '-':	pos.sym = sym_mtl_MINUS; [self readNextChar]; break;
                
                // Left Bracket
            case '(':	pos.sym = sym_mtl_L_BRACKET; [self readNextChar]; break;
                
                // Right Bracket
            case ')':	pos.sym = sym_mtl_R_BRACKET; [self readNextChar]; break;
                
                // Unknown
            default :	pos.sym = sym_mtl_UNKNOWN; [self readNextChar];
        }
}


- (void) readNextLine {
    // Read over symbols of current line
    while (![self atEOT] && [self sym] != sym_mtl_EOL) {
        [self readNextSym];
    }
    
    if ([self sym] == sym_mtl_EOL)
        [self readNextSym];
}



// Accessors ---------------------------------------------------------------------------------

- (MtlFileSymbol) sym {
    return pos.sym;
}


- (NSString*) token {
    NSString* string = [[NSString alloc] initWithBytes: &text[tokenStart.idx]
                                                length: pos.idx-tokenStart.idx
                                              encoding: NSASCIIStringEncoding];
    return string;
}


- (NSString*) symName: (MtlFileSymbol) aSymbol {
    
    switch (aSymbol) {
        case sym_mtl_UNKNOWN:			return @"unknown";
        case sym_mtl_EOT:				return @"end-of-text";
        case sym_mtl_IDENT:				return @"identifier";
        case sym_mtl_INT:				return @"integer";
        case sym_mtl_FLOAT:				return @"float";
            
            // Minus
        case sym_mtl_MINUS:             return @"-";
            
            // Keywords
        case sym_mtl_NEWMTL:            return @"newmtl";
        case sym_mtl_Ka:				return @"Ka";
        case sym_mtl_Ks:				return @"Ks";
        case sym_mtl_Kd:				return @"Kd";
        case sym_mtl_Map_Ka:			return @"map_Ka";
        case sym_mtl_Map_Ks:			return @"map_Ks";
        case sym_mtl_Map_Kd:			return @"map_Kd";

        default:					return @"unknown";
    }
}


- (BOOL) atEOT {
    return text[pos.idx] == NUL;
}


- (NSUInteger) lineNr {
    return pos.lineNr;
}


- (NSUInteger) colNr {
    return pos.colNr;
}


@end
