//
//  ObjFileScanner.m
//  AR-Quest
//
//  Created by Reto Marti on 23.02.08.
//  Copyright 2008 VOXATEC. All rights reserved.
//-------------------------------------------------------------------------------

#import "ObjFileScanner.h"



@implementation ObjFileScanner

// Creation  ---------------------------------------------------------------------------------

+ (ObjFileScanner*) newScanner {
    ObjFileScanner* scanner = [ObjFileScanner new];
    return scanner;
}



// Initialization ------------------------------------------------------------------------------------------

- (void) initKeywordTable {
    keyword[0] = @"v";      keyword_sym[0] = sym_V;
    keyword[1] = @"vn";     keyword_sym[1] = sym_VN;
    keyword[2] = @"vt";     keyword_sym[2] = sym_VT;
    keyword[3] = @"f";      keyword_sym[3] = sym_F;
    keyword[4] = @"o";      keyword_sym[4] = sym_O;
    keyword[5] = @"mtllib"; keyword_sym[5] = sym_MTLLIB;
    keyword[6] = @"usemtl"; keyword_sym[6] = sym_USEMTL;
    keyword[7] = @"s";      keyword_sym[7] = sym_S;
    keyword[8] = @"g";      keyword_sym[8] = sym_G;
    
    keywordCount = 9;
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

- (ObjFileScanState) state {
    ObjFileScanState aState;
    
    aState.pos = pos;
    aState.tokenStart = tokenStart;
    return aState;
}


- (void) setState: (ObjFileScanState) aState {
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
    pos.sym = sym_UNKNOWN;
    
    tokenStart = pos;
    
    if (text) {
        ch = text[0];
    }
}


- (void) reset {
    [self setText: nil];
}



// Helpers --------------------------------------------------------------------------------

- (ObjFileSymbol) lookupKeyword: (NSString*) aIdent {
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
        return sym_IDENT;
}


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
    pos.sym = sym_EOL;
}


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
        pos.sym = sym_FLOAT;
    }
    else
        pos.sym = sym_INT;
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
            case NUL:	pos.sym = sym_EOT; break;
                        
            // Slash
            case '/':	pos.sym = sym_SLASH; [self readNextChar]; break;
                            
            // Left Bracket
            case '(':	pos.sym = sym_L_BRACKET; [self readNextChar]; break;
                
            // Right Bracket
            case ')':	pos.sym = sym_R_BRACKET; [self readNextChar]; break;
                
            // Unknown
            default :	pos.sym = sym_UNKNOWN; [self readNextChar];
        }
}


- (void) readNextLine {
    // Read over symbols of current line
    while (![self atEOT] && ([self sym] != sym_EOL)) {
        [self readNextSym];
    }

    if ([self sym] == sym_EOL)
        [self readNextSym];
}



// Accessors ---------------------------------------------------------------------------------

- (ObjFileSymbol) sym {
    return pos.sym;
}


- (NSString*) token {
    NSString* string = [[NSString alloc] initWithBytes: &text[tokenStart.idx] 
                                         length: pos.idx-tokenStart.idx 
                                         encoding: NSASCIIStringEncoding];
    return string;
}


- (NSString*) symName: (ObjFileSymbol) aSymbol {
    
    switch (aSymbol) {
        case sym_UNKNOWN:			return @"unknown"; 
        case sym_EOT:				return @"end-of-text";
        case sym_IDENT:				return @"identifier";
        case sym_INT:				return @"integer";
        case sym_FLOAT:				return @"float";

        // Brackets
        case sym_SLASH:             return @"/";
        
        // Keywords
        case sym_V:				    return @"v";
        case sym_VN:				return @"vn";
        case sym_VT:				return @"vt";
        case sym_F:				    return @"f";
        case sym_MTLLIB:			return @"mtllib";
        case sym_USEMTL:			return @"usemtl";
        
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
