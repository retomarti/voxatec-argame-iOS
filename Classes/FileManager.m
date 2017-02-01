//
//  FileManager.m
//  AR-Quest
//
//  Created by Reto Marti on 16.02.13.
//
//-------------------------------------------------------------------------------

#import "FileManager.h"


// Shared cache
static FileManager* theManager = nil;


@implementation FileManager


// Initialisation ---------------------------------------------------------------

+ (FileManager*) theManager {
    if (theManager == nil)  {
        theManager = [[FileManager alloc] init];
    }
    return theManager;

}


- (id) init {
    self = [super init];
    
    if (self) {
        fileList = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void) dealloc {
    fileList = nil;
}


// fileList management ----------------------------------------------------------


- (File*) fileWithName: (NSString*) fileName {
    File* file = [fileList objectForKey: fileName];
    return file;
}


- (NSString*) pathOfFile: (File*) file {
    if (file == nil)
        return nil;
    else {
        // PRODUCTION (we load file from cache directory)
        NSArray*  dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docsDir  = [dirPaths objectAtIndex: 0];
        NSString* filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: file.name]];
        return filePath;
    }
}


- (void) putFile: (File*) file {
    NSAssert(file != nil && file.name != nil, @"FileManager.updateFileList: file or file name is nil");
    
    File* aFile = [fileList objectForKey: file.name];
    
    if (aFile == nil) {
        [fileList setObject: file forKey: file.name];
    }
}


- (void) removeFile: (File*) file {
    NSAssert(file != nil && file.name != nil, @"FileManager.updateFileList: file or file name is nil");

    [fileList removeObjectForKey: file.name];
}


- (void) removeAll {
    [fileList removeAllObjects];
}



// File operations -------------------------------------------------------------


- (void) loadFileContent: (File*) file {
    
    // DEBUG (we load files from resource
    // NSBundle* mainBundle  = [NSBundle mainBundle];
    // NSString* filePath = [mainBundle pathForResource: fileName ofType: fileType];
    
    NSAssert(file != nil && file.name != nil, @"FileManager.loadFileContent: file or filename is nil");

    // PRODUCTION (we load file from cache directory)
    NSString* filePath = [self pathOfFile: file];

    // Read file content into a string
    NSError* error = nil;
    NSMutableData* fileData = [NSMutableData dataWithContentsOfFile: filePath
                                                            options: NSDataReadingMappedIfSafe
                                                              error: &error];
    
    if (error != nil) {
        NSLog(@"FileManager.contentOfFile: %@", [error localizedDescription]);
        NSException* exception = [NSException
                                  exceptionWithName: error.domain
                                  reason: error.localizedFailureReason
                                  userInfo: error.userInfo];
        @throw exception;
    }
    
    file.content = fileData;
}


- (void) storeFile: (File*) file {
    
    NSAssert (file != nil && file.name != nil, @"FileManager.storeFile: file or file name is nil");
    NSAssert (file.content != nil, @"FileManager.storeFile: file content is nil");
    
    NSArray*  dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir  = [dirPaths objectAtIndex: 0];
    NSString* filePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: file.name]];
        
    // Store receivedData into a file
    NSError* error = nil;
    [file.content writeToFile: filePath options: NSDataWritingAtomic error: &error];
        
    if(error != nil) {
        NSLog(@"FileManager.storeFile: %@", [error localizedDescription]);
        NSException* exception = [NSException
                                    exceptionWithName: error.domain
                                    reason: error.localizedFailureReason
                                    userInfo: error.userInfo];
        @throw exception;
    }
    
    [self putFile: file];
}


- (void) deleteFile: (File*) file {
    [self removeFile: file];
}


- (void) deleteAllFiles {
    [self removeAll];
}


@end
