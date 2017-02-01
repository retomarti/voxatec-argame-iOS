//
//  MtlFileParser.m
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import "MtlFileParser.h"
#import "FileManager.h"


// Exceptions
NSString* kMtlFileSyntaxErrorException = @"MtlFileParser.SyntaxError.Exception";


@implementation MtlFileParser


// Initialization  --------------------------------------------------------------------

- (void) setScanner: (MtlFileScanner*) aScanner {
    scanner = aScanner;
}


- (MtlFileScanner*) scanner {
    return scanner;
}


- (id) init {
    self = [super init];
    if (self) {
        [self setScanner: [MtlFileScanner newScanner]];
        self.materials = [NSMutableArray new];
        self.material = nil;
    }
    return self;
}


- (Material*) materialWithName: (NSString*) aMaterialName {
    int idx = 0;
    Material* mat = nil;
    
    while (idx < [self.materials count] && mat == nil) {
        Material* material = [self.materials objectAtIndex: idx];
        NSString* materialName = [material name];
        if ([materialName isEqualToString: aMaterialName] ||
            [materialName isEqualToString: [aMaterialName stringByAppendingString: @".dds"]])
            mat = material;
        idx++;
    }
    
    return mat;
}


// Creation  ----------------------------------------------------------------------------------------------------------

+ (MtlFileParser*) newParser {
    MtlFileParser* parser = [MtlFileParser new];
    return parser;
}


- (void) dealloc {
    scanner = nil;
    self.materials = nil;
    self.material = nil;
}



// Syntax Error  ------------------------------------------------------------------------------------------------------

- (void) reportErrorOnLine: (NSUInteger) aLineNr
                  atColumn: (NSUInteger) aColNr
               expectedSym: (NSString*) expSym
               detectedSym: (NSString*) detSym {
    
    // Create error
    SyntaxError* error = [SyntaxError newErrorOnLine: aLineNr atColumn: aColNr expectedSym: expSym detectedSym: detSym];
    
    // Create exception
    NSMutableDictionary* errDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    [errDict setObject: error forKey: @"syntaxError"];
    
    NSException* exception = [NSException exceptionWithName: kMtlFileSyntaxErrorException
                                                     reason: [error errorMsg]
                                                   userInfo: errDict];
    
    // Raise exception
    [exception raise];
}



- (SyntaxError*) syntaxErrorFromException: (NSException*) aException {
    NSAssert([[aException name] isEqualToString: kMtlFileSyntaxErrorException], @"Wrong kind of exception");
    
    // Get info from exception
    SyntaxError* error = [[aException userInfo] objectForKey: @"syntaxError"];
    
    return error;
}


// Helper  --------------------------------------------------------------------------------------

- (NSString*) symName: (MtlFileSymbol) aSymbol {
    return nil;
}


- (BOOL) tryMatchSym: (MtlFileSymbol) aSymbol {
    return [scanner sym] == aSymbol;
}


- (BOOL) tryMatchSym: (MtlFileSymbol) aSymbol token: (NSString*) aToken {
    if ([self tryMatchSym: aSymbol]) {
        return ([aToken isEqualToString: [scanner token]]);
    }
    else
        return NO;
}


- (void) matchSym: (MtlFileSymbol) aSymbol {
    if (![self tryMatchSym: aSymbol]) {
        // Raise error
        [self reportErrorOnLine: [scanner lineNr]
                       atColumn: [scanner colNr]
                    expectedSym: [scanner symName: aSymbol]
                    detectedSym: [scanner token]];
    }
    else {
        [scanner readNextSym];
    }
}


- (void) matchSyms: (MtlFileSymbol[]) aSymbolList nrOfSyms: (int) aSymCount {
    if (![self tryMatchSyms: aSymbolList nrOfSyms: aSymCount]) {
        
        // Raise error
        NSString* expSymbols = @"";
        
        for (int idx=0; idx < aSymCount; idx++) {
            MtlFileSymbol sym = aSymbolList[idx];
            NSString* symName = [scanner symName: sym];
            [expSymbols stringByAppendingString: symName];
            if (idx < aSymCount - 1) {
                [expSymbols stringByAppendingString: @","];
            }
        }
        
        [self reportErrorOnLine: [scanner lineNr]
                       atColumn: [scanner colNr]
                    expectedSym: expSymbols
                    detectedSym: [scanner token]];
    }
    else {
        [scanner readNextSym];
    }
}


- (void) matchSymNoRead: (MtlFileSymbol) aSymbol {
    if (![self tryMatchSym: aSymbol]) {
        // Raise error
        [self reportErrorOnLine: [scanner lineNr]
                       atColumn: [scanner colNr]
                    expectedSym: [scanner symName: aSymbol]
                    detectedSym: [scanner token]];
    }
}


- (BOOL) tryMatchSyms: (MtlFileSymbol[]) aSymbolList nrOfSyms: (int) aSymCount {
    BOOL matched = NO;
    int i = 0;
    
    while (!matched && i < aSymCount) {
        matched = [scanner sym] == aSymbolList[i];
        i++;
    }
    
    return matched;
}



// Parsing  ----------------------------------------------------------------------------------


- (void) ambient_light_coeff {
    // Ka <float> <float> <float> EOL
    
    [self matchSym: sym_mtl_Ka];

    NSString* coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.ambientCoeff[0] = [coeffStr floatValue];
    
    coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.ambientCoeff[1] = [coeffStr floatValue];

    coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.ambientCoeff[2] = [coeffStr floatValue];

    self.material->lightReflection.ambientCoeff[3] = 1.0;
    
    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) specular_light_coeff {
    // Ks <float> <float> <float> EOL
    
    [self matchSym: sym_mtl_Ks];
    
    NSString* coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.specularCoeff[0] = [coeffStr floatValue];
    
    coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.specularCoeff[1] = [coeffStr floatValue];
    
    coeffStr = [scanner token];
    [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.specularCoeff[2] = [coeffStr floatValue];
    
    self.material->lightReflection.specularCoeff[3] = 1.0;
    
    [self matchSym: sym_mtl_EOL];
}


- (void) specular_Light_exponent {
    // Ns <float> EOL
    
    [self matchSym: sym_mtl_Ns];
    
    NSString* expStr = [scanner token];
    
    if ([scanner sym] == sym_mtl_INT) {
        [self matchSym: sym_mtl_INT];
    }
    else {
        [self matchSym: sym_mtl_FLOAT];
    }
    self.material->lightReflection.specularExp = [expStr floatValue];
    
    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) diffuse_light_coeff {
    // Kd <float> <float> <float> EOL
    
    [self matchSym: sym_mtl_Kd];
    
    // Coeff 1
    NSString* coeffStr = [scanner token];
    
    if ([scanner sym] == sym_mtl_INT)
        [self matchSym: sym_mtl_INT];
    else
        [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.diffuseCoeff[0] = [coeffStr floatValue];
    
    // Coeff 2
    coeffStr = [scanner token];

    if ([scanner sym] == sym_mtl_INT)
        [self matchSym: sym_mtl_INT];
    else
        [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.diffuseCoeff[1] = [coeffStr floatValue];
    
    // Coeff 3
    coeffStr = [scanner token];

    if ([scanner sym] == sym_mtl_INT)
        [self matchSym: sym_mtl_INT];
    else
        [self matchSym: sym_mtl_FLOAT];
    self.material->lightReflection.diffuseCoeff[2] = [coeffStr floatValue];
    
    self.material->lightReflection.diffuseCoeff[3] = 1.0;
    
    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) texture_map_options {
    
    while ([scanner sym] == sym_mtl_MINUS) {
        [scanner readNextSym];
        
        // different options
    }
    [self matchSym: sym_mtl_MINUS];
}


- (void) ambient_texture_map {
    // map_Ka {'-' option } <ident> EOL
    
    [self matchSym: sym_mtl_Map_Ka];

    if ([scanner sym] == sym_mtl_MINUS) {
        [self texture_map_options];
    }
    
    NSString* fileName = [scanner token];
    [self matchSym: sym_mtl_IDENT];

    // Create new ambient texture map
    Texture* texture = [[Texture new] initWithImageFile: fileName];
    self.material->map_ambient = texture;

    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) specular_texture_map {
    // map_Ks {'-' option } <ident> EOL
    
    [self matchSym: sym_mtl_Map_Ks];
    
    if ([scanner sym] == sym_mtl_MINUS) {
        [self texture_map_options];
    }
    
    NSString* fileName = [scanner token];
    [self matchSym: sym_mtl_IDENT];
    
    // Create new specular texture map
    Texture* texture = [[Texture new] initWithImageFile: fileName];
    self.material->map_specular = texture;
    
    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) diffuse_texture_map {
    // map_Kd {'-' option } <ident> EOL
    
    [self matchSym: sym_mtl_Map_Kd];
    
    if ([scanner sym] == sym_mtl_MINUS) {
        [self texture_map_options];
    }
    
    NSString* fileName = [scanner token];
    [self matchSym: sym_mtl_IDENT];
    
    // Create new specular texture map
    Texture* texture = [[Texture new] initWithImageFile: fileName];
    self.material->map_diffuse = texture;
    
    MtlFileSymbol syms[] = {sym_mtl_EOL, sym_mtl_EOT};
    [self matchSyms: syms nrOfSyms: 2];
}


- (void) new_material {
    // newmtrl <IDENT> EOL
    [self matchSym: sym_mtl_NEWMTL];
    
    if ([scanner sym] == sym_mtl_L_BRACKET) {
        [scanner readNextSym];
    }
    
    NSString* matName = [scanner token];
    [self matchSym: sym_mtl_IDENT];
    
    // Create new material
    self.material  = [Material silver];  // silver is our default
    self.material.name = matName;
    [self.materials addObject: self.material];
    
    if ([scanner sym] == sym_mtl_R_BRACKET) {
        [scanner readNextSym];
    }
    
    [self matchSym: sym_mtl_EOL];
}


- (void) parseLines {
    // { <new-material> }
    
    while (![scanner atEOT]) {
        
        switch ([scanner sym]) {
                
            case sym_mtl_NEWMTL:
                [self new_material];
                break;
            
            case sym_mtl_Ka:
                [self ambient_light_coeff];
                break;

            case sym_mtl_Ks:
                [self specular_light_coeff];
                break;

            case sym_mtl_Kd:
                [self diffuse_light_coeff];
                break;
                
            case sym_mtl_Ns:
                [self specular_Light_exponent];
                break;
                
            case sym_mtl_Map_Ka:
                [self ambient_texture_map];
                break;
                
            case sym_mtl_Map_Ks:
                [self specular_texture_map];
                break;
                
            case sym_mtl_Map_Kd:
                [self diffuse_texture_map];
                break;
                
            default:
                [scanner readNextLine];
                break;
        }
    }
}


- (SyntaxError*) parseText: (const char*) aText {
    
    SyntaxError* error = nil;
    
    @try {
        [self reset];
        [scanner setText: aText];
        [scanner readNextSym];
        [self parseLines];
    }
    
    @catch (NSException* exception) {
        // Syntax error?
        if ([[exception name] isEqualToString: kMtlFileSyntaxErrorException]) {
            error = [self syntaxErrorFromException: exception];
        }
        else
            NSLog(@"ObjFileParser error: %s", [[exception reason] UTF8String]);
    }
    
    return error;
}


- (SyntaxError*) parseMtlFileWithName: (NSString*) fileName {
    
    // Read file content
    FileManager* fileManager = [FileManager theManager];
    File* mtlFile = [fileManager fileWithName: fileName];
    NSAssert(mtlFile != nil, @"MtlFileParser: mtl file with name '%s' not found.", [fileName UTF8String]);
    
    [fileManager loadFileContent: mtlFile];

    if (mtlFile.content == nil)
        return FALSE;
    
    [self reset];
    SyntaxError* synError = [self parseText: [mtlFile.content bytes]]; // NSData
        
    return synError;
}


- (void) reset {
    [scanner reset];
    
    self.material = nil;
    [self.materials removeAllObjects];
}


@end
