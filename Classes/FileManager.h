//
//  FileManager.h
//  AR-Quest
//
//  Created by Reto Marti on 16.02.13.
//
//-------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "File.h"


@interface FileManager : NSObject {
@protected
    NSMutableDictionary* fileList;
}

+ (FileManager*) theManager;

- (File*) fileWithName: (NSString*) fileName;
- (NSString*) pathOfFile: (File*) file;
- (void) loadFileContent: (File*) file;
- (void) storeFile: (File*) file;
- (void) deleteFile: (File*) file;
- (void) deleteAllFiles;

@end
