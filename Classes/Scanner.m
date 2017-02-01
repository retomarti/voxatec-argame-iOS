//
//  Scanner.m
//  AR-Quest
//
//  Created by Reto Marti on 22.02.13.
//
//-------------------------------------------------------------------------------

#import "Scanner.h"



@implementation Scanner


// Sets ------------------------------------------------------------------------------------------

BOOL isDigit (char aChar) {
    return aChar >= '0' && aChar <= '9';
}


BOOL isIdentStartChar (char aChar) {
    return aChar == '_' || aChar == '.' || (aChar >= 'a' && aChar <= 'z') || (aChar >= 'A' && aChar <= 'Z');
}


BOOL isIdentChar (char aChar) {
    return aChar == '_' || aChar == '.' || aChar == '-' || (aChar >= 'a' && aChar <= 'z') || (aChar >= 'A' && aChar <= 'Z');
}


BOOL isSeparator (char aChar) {
    return (aChar == SPACE || aChar == TAB);
}


BOOL isControlChar (char aChar) {
    return ((aChar < SPACE) || (aChar > 126)) && (aChar != LF) && (aChar != CR);
}

@end
