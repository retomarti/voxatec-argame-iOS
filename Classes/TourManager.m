//
//  TourManager.m
//  AR-Quest
//
//  Created by Reto Marti on 03.02.13.
//
//----------------------------------------------------------------------------------------

#import "TourManager.h"
#import "Story.h"
#import "Scene.h"
#import "Cache.h"
#import "Riddle.h"
#import "File.h"
#import "FileManager.h"
#import "NSString+HTML.h"


// Contants
#define kHostAddress @"http://argame-rest-server.us-west-2.elasticbeanstalk.com"
// #define kHostAddress @"http://192.168.0.192:9090/argame"
#define kTimeoutIntvl 10 // [secs]

#define kTargetImgXmlFileName @"argame_caches.xml"
#define kTargetImgDatFileName @"argame_caches.dat"


// Shared manager
static TourManager* theManager = nil;



@implementation TourManager

@synthesize delegate, adventures;


// Initialisation -----------------------------------------------------------------------------------------------------

+ (TourManager*) theManager {
    if (theManager == nil)  {
        theManager = [TourManager new];
    }
    return theManager;
}

- (id) init {
    self = [super init];
    
    if (self) {
        parser = [ObjFileParser new];
    }
    
    return self;
}


- (void) dealloc {
    adventures = nil;
    theStory = nil;
    theScene = nil;
    delegate = nil;
    parser = nil;
    fileMapTable = nil;
}



// Story workflow -----------------------------------------------------------------------------------------------------

- (void) startStory: (Story*) story {
    theStory = story;
}


- (void) gotoNextScene: (Scene*) currentScene {
}


// Load Adventures -----------------------------------------------------------------------------------------

- (Cache*) loadCacheFromDict: (NSDictionary*) cacheDict {
    
    Cache* cache = [Cache new];
    
    cache.id = [cacheDict valueForKey: @"id"];
    cache.name = [[cacheDict valueForKey: @"name"] decodeHTMLCharacterEntities];
    cache.text = [[cacheDict valueForKey: @"text"] decodeHTMLCharacterEntities];
    cache.street = [[cacheDict valueForKey: @"street"] decodeHTMLCharacterEntities];
    
    cache.cacheGroupId = [cacheDict valueForKey: @"cacheGroupId"];
    cache.targetImageName = [cacheDict valueForKey: @"targetImageName"];
    
    CLLocationCoordinate2D coord;
    coord.latitude = [[cacheDict valueForKey: @"gpsLatitude"] doubleValue];
    coord.longitude = [[cacheDict valueForKey: @"gpsLongitude"] doubleValue];
    cache.gpsCoordinates = coord;
    
    return cache;
}


- (void) loadAdventuresFromJSON: (NSData*) jsonResponse {
    
    NSError* error = nil;
    NSArray* parsedObject = [NSJSONSerialization JSONObjectWithData: jsonResponse options: 0 error: &error];
    
    if (error != nil) {
        [self.delegate didFailLoadingAdventuresWithError: error];
        NSLog(@"TourManager: error loading JSON response %s", [[error localizedDescription] UTF8String]);
    }
    
    @try {
        
        // Read parsedObject into adventures
        adventures = [NSMutableArray new];
        
        NSArray* advList = parsedObject;
        
        for (NSDictionary* advDict in advList) {
            
            // Adventure
            Adventure* adv = [Adventure newAdventure];
            adv.id = [advDict valueForKey: @"id"];
            adv.name = [[advDict valueForKey: @"name"] decodeHTMLCharacterEntities];
            adv.text = [[advDict valueForKey: @"text"] decodeHTMLCharacterEntities];
            [adventures addObject: adv];
            
            // Stories
            adv.stories = [NSMutableArray new];
            NSArray* storyList = [advDict valueForKey: @"storyList"];
            
            for (NSDictionary* storyDict in storyList) {
                // Story
                Story* story = [Story newStory];
                story.id = [storyDict valueForKey: @"id"];
                story.name = [[storyDict valueForKey: @"name"] decodeHTMLCharacterEntities];
                story.text = [[storyDict valueForKey: @"text"] decodeHTMLCharacterEntities];
                story.scenes = [NSMutableArray new];
                [adv.stories addObject: story];

                // Scenes
                NSArray* sceneList = [storyDict valueForKey: @"sceneList"];
                
                for (NSDictionary* sceneDict in sceneList) {
                    
                    // Scene
                    Scene* scene = [Scene new];
                    scene.id = [sceneDict valueForKey:@"id"];
                    scene.name = [[sceneDict valueForKey:@"name"] decodeHTMLCharacterEntities];
                    scene.seqNr = [[sceneDict valueForKey: @"seqNr"] intValue];
                    scene.text = [[sceneDict valueForKey:@"text"] decodeHTMLCharacterEntities];
                    Vector3D lightLoc = {0.0, 0.0, 1.0};
                    scene.light     = [Light newPointLightAt: lightLoc];

                    [story.scenes addObject: scene];
                    
                    // Cache
                    NSDictionary* cacheDict = [sceneDict valueForKey: @"cache"];
                    scene.cache = [self loadCacheFromDict: cacheDict];
                    
                    // Object3D
                    NSDictionary* obj3DDict = [sceneDict valueForKey: @"object3D"];
                    Object3D* obj3D = [Object3D new];
                    obj3D.id = [obj3DDict valueForKey: @"id"];
                    obj3D.name = [[obj3DDict valueForKey: @"name"] decodeHTMLCharacterEntities];
                    obj3D.text = [[obj3DDict valueForKey: @"tex"] decodeHTMLCharacterEntities];
                    scene.object3D = obj3D;
                    
                    // Riddle
                    NSDictionary* riddleDict = [sceneDict valueForKey: @"riddle"];
                    Riddle* riddle = [Riddle new];
                    riddle.id = [riddleDict valueForKey: @"id"];
                    riddle.challenge = [[riddleDict valueForKey: @"challengeText"] decodeHTMLCharacterEntities];
                    riddle.response = [[riddleDict valueForKey: @"responseText"] decodeHTMLCharacterEntities];
                    scene.riddle = riddle;
                }
            }
        }
        
        // Inform delegate
        [self.delegate didFinishLoadingAdventures: adventures];

    }
    
    @catch (NSException *exception) {
        NSError* error = [[NSError alloc] initWithDomain: exception.name code: 0 userInfo: exception.userInfo];
        [self.delegate didFailLoadingAdventuresWithError: error];
    }
}


- (void) loadNearbyAdventures {
    
    NSString* urlString = [NSString stringWithFormat:@"%@/%@", kHostAddress, @"adventure-caches"];
    
    // Create task to load nearbyAdventures from server
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData *data,
                                 NSURLResponse *response,
                                 NSError *error) {

                if ([NSThread isMainThread]) {
                    if (!error) {
                        [self loadAdventuresFromJSON: data];
                    } else {
                        [self.delegate didFailLoadingAdventuresWithError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            [self loadAdventuresFromJSON: data];
                        } else {
                            [self.delegate didFailLoadingAdventuresWithError: error];
                        }
                    });
                }
                
            }] resume];
}



// Load Object3D of Scene -----------------------------------------------------------------------------------------------------

- (void) loadTextureFileListFrom: (NSArray*) textureArray forObject3D: (Object3D*) object3D {
    NSAssert (textureArray != nil, @"TourManager.loadTextureFileIdList: tetureFileArray is nil");
    
    // texture files
    NSMutableArray* textureFileList = [NSMutableArray new];
    
    for (NSDictionary* texture in textureArray) {
        
        File* file = [File new];
        file.id = [texture valueForKey: @"id"];
        file.name = [texture valueForKey: @"name"];
        file.contentType = [texture valueForKey: @"imageType"];
        
        [textureFileList addObject: file];
    }
    object3D.textureFiles = textureFileList;
}


- (void) loadObject3DforScene: (Scene*) scene fromJSON: (NSData*) jsonResponse {
    
    NSError* error = nil;
    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData: jsonResponse options: 0 error: &error];
    
    if (error != nil) {
        [self didFailLoadingObject3DWithError: error];
    }
    
    @try {
        // Read parsedObject into object3D attribute
        NSDictionary* obj3DDict = parsedObject;
        
        // object 3D
        Object3D* obj3D = [Object3D new];
        obj3D.id = [obj3DDict valueForKey: @"id"];
        obj3D.name = [[obj3DDict valueForKey: @"name"] decodeHTMLCharacterEntities];
        obj3D.text = [[obj3DDict valueForKey: @"text"] decodeHTMLCharacterEntities];
        obj3D.obj3DFileName = [obj3DDict valueForKey: @"objFileName"];
        obj3D.materialFileName = [obj3DDict valueForKey: @"mtlFileName"];
        
        NSAssert(obj3D.obj3DFileName != nil, @"TourManager: objFileName is nil");
        NSAssert(obj3D.materialFileName != nil, @"TourManager: mtlFileName is nil");

        // texture file list
        NSArray* textureFileArray = [obj3DDict valueForKey: @"textureList"];
        [self loadTextureFileListFrom: textureFileArray forObject3D: obj3D];
        
        scene.object3D = obj3D;
    }
    
    @catch (NSException *exception) {
        NSError* error = [[NSError alloc] initWithDomain: exception.name code: 0 userInfo: exception.userInfo];
        [self didFailLoadingObject3DWithError: error];
    }
    
}


- (void) loadObject3DForScene: (Scene*) scene {
    
    NSAssert(scene.object3D != nil, @"TourManager: object3D of scene is nil");
    
    Object3D* obj3D = scene.object3D;
    unsigned int obj3DId = (unsigned int) [obj3D.id unsignedIntegerValue];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%u",
                           kHostAddress,
                           @"objects3D",
                           obj3DId];
    
    // Create task to load 3D objects for scene from server
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData* data,
                                 NSURLResponse* response,
                                 NSError* error) {

                if ([NSThread isMainThread]) {
                    if (!error) {
                        [self loadObject3DforScene: scene fromJSON: data];
                        [self didFinishLoadingObject3D: obj3D];
                   } else {
                        [self didFailLoadingObject3DWithError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            [self loadObject3DforScene: scene fromJSON: data];
                            [self didFinishLoadingObject3D: obj3D];
                        } else {
                            [self didFailLoadingObject3DWithError: error];
                        }
                    });
                }
                
            }] resume];
}



//--- Load Scene Files ---------------------------------------------------------------------------------------------------

- (void) load3DObjectFileForScene: (Scene*) aScene {
    // Request obj file from server
    
    Object3D* obj3D = aScene.object3D;
    
    NSAssert(obj3D != nil, @"TourManager: object3D is nil");
    NSAssert(obj3D.id != nil, @"TourManager: object3D id is nil");
    
    // Allocate new obj file
    File* objFile = [File new];
    objFile.id = obj3D.id;
    objFile.name = obj3D.obj3DFileName;
    obj3D.obj3DFile = objFile;
    
    // Send http request for file
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",
                           kHostAddress,
                           @"files/obj",
                           obj3D.id];
    
    // Put file name into fileMapTable dictionary for storing
    [fileMapTable setObject: obj3D.obj3DFile forKey: urlString];
    
    // Create task to load file from server
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData *data,
                                 NSURLResponse *response,
                                 NSError *error) {
                
                if ([NSThread isMainThread]) {
                    if (!error) {
                        objFile.content = data;
                        [self loadObject3DforScene: theScene fromJSON: data];
                        [self fileDidFinishLoading: urlString];
                    } else {
                        [self fileDidFailLoading: urlString withError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            objFile.content = data;
                            [self fileDidFinishLoading: urlString];
                        } else {
                            [self fileDidFailLoading: urlString withError: error];
                        }
                    });
                }
                
            }] resume];

}


- (void) load3DObjectMaterialFileForScene: (Scene*) aScene {
    // Request material file from server

    Object3D* obj3D = aScene.object3D;
    
    NSAssert(obj3D != nil, @"TourManager: object3D is nil");
    NSAssert(obj3D.id != nil, @"TourManager: object3D id is nil");
    
    // Allocate new mtl file
    File* mtlFile = [File new];
    mtlFile.id = obj3D.id;
    mtlFile.name = obj3D.materialFileName;
    obj3D.materialFile = mtlFile;
    
    // Send http request for file
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",
                           kHostAddress,
                           @"files/mtl",
                           obj3D.id];
    
    // Put file name into fileMapTable dictionary for storing
    [fileMapTable setObject: obj3D.materialFile forKey: urlString];
    
    // Create task to load file from server
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData *data,
                                 NSURLResponse *response,
                                 NSError *error) {

                if ([NSThread isMainThread]) {
                    if (!error) {
                        mtlFile.content = data;
                        [self fileDidFinishLoading: urlString];
                    } else {
                        [self fileDidFailLoading: urlString withError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            mtlFile.content = data;
                            [self fileDidFinishLoading: urlString];
                        } else {
                            [self fileDidFailLoading: urlString withError: error];
                        }
                    });
                }
      
            }] resume];
}


- (void) loadTextureFilesForScene: (Scene*) aScene {
    // Request texture files from server

    Object3D* obj3D = aScene.object3D;
    
    NSAssert(obj3D != nil, @"TourManager: object3D is nil");
    NSAssert(obj3D.id != nil, @"TourManager: object3D id is nil");
    
    // Iterate over all texture files
    for (File* textureFile in obj3D.textureFiles) {
        NSAssert(textureFile.id != nil, @"TourManager: texture file id is nil");
        NSAssert(textureFile.name != nil, @"TourManager: texture file name is nil");
        
        // Send http request for file
        NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@/%@",
                               kHostAddress,
                               @"files/mtl",
                               obj3D.id,
                               textureFile.name];
        
        // Put file name into fileMapTable dictionary for storing
        [fileMapTable setObject: textureFile forKey: urlString];
        
        // Create task to load file from server
        NSURLSession* session = [NSURLSession sharedSession];
        [[session dataTaskWithURL: [NSURL URLWithString: urlString]
                completionHandler: ^(NSData* data,
                                     NSURLResponse* response,
                                     NSError* error) {

                    if ([NSThread isMainThread]) {
                        if (!error) {
                            textureFile.content = data;
                            [self fileDidFinishLoading: urlString];
                        } else {
                            [self fileDidFailLoading: urlString withError: error];
                        }
                    }
                    else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            //Update UI in UI thread here
                            if (!error) {
                                textureFile.content = data;
                                [self fileDidFinishLoading: urlString];
                            } else {
                                [self fileDidFailLoading: urlString withError: error];
                            }
                        });
                    }
                    
                }] resume];
    }
}


- (void) loadTargetDataFileForScene: (Scene*) aScene {
    // Request target image data file from server
    
    Cache* cache = aScene.cache;
    
    NSAssert(cache != nil, @"TourManager: cache is nil");
    NSAssert(cache.cacheGroupId != nil, @"TourManager: cacheGroup of cache is nil");
    
    // Create target image data file
    File* targetImgDataFile = [File new];
    targetImgDataFile.id = cache.cacheGroupId;
    targetImgDataFile.name = kTargetImgDatFileName;
    aScene.targetImgDataFile = targetImgDataFile;
    
    // Send http request for file
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",
                           kHostAddress,
                           @"files/target-dat",
                           cache.cacheGroupId];
    
    // Put file name into fileMapTable dictionary for storing
    [fileMapTable setObject: aScene.targetImgDataFile forKey: urlString];
    
    // Create task to load file from server
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData* data,
                                 NSURLResponse* response,
                                 NSError* error) {

                if ([NSThread isMainThread]) {
                    if (!error) {
                        aScene.targetImgDataFile.content = data;
                        [self fileDidFinishLoading: urlString];
                    } else {
                        [self fileDidFailLoading: urlString withError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            aScene.targetImgDataFile.content = data;
                            [self fileDidFinishLoading: urlString];
                        } else {
                            [self fileDidFailLoading: urlString withError: error];
                        }
                    });
                }
                
            }] resume];
}


- (void) loadTargetXmlFileForScene: (Scene*) aScene {
    // Request target image xml file from server
    Cache* cache = aScene.cache;
    
    NSAssert(cache != nil, @"TourManager: cache is nil");
    NSAssert(cache.cacheGroupId != nil, @"TourManager: cacheGroup of cache is nil");
    
    // Create target image data file
    File* targetImgXmlFile = [File new];
    targetImgXmlFile.id = cache.cacheGroupId;
    targetImgXmlFile.name = kTargetImgXmlFileName;
    aScene.targetImgXmlFile = targetImgXmlFile;
    
    // Send http request for file
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",
                           kHostAddress,
                           @"files/target-xml",
                           cache.cacheGroupId];
    
    // Put file name into fileMapTable dictionary for storing
    [fileMapTable setObject: aScene.targetImgXmlFile forKey: urlString];
    
    // Create task to load file from server
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL: [NSURL URLWithString: urlString]
            completionHandler: ^(NSData* data,
                                 NSURLResponse* response,
                                 NSError* error) {

                if ([NSThread isMainThread]) {
                    if (!error) {
                        aScene.targetImgXmlFile.content = data;
                        [self fileDidFinishLoading: urlString];
                    } else {
                        [self fileDidFailLoading: urlString withError: error];
                    }
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //Update UI in UI thread here
                        if (!error) {
                            aScene.targetImgXmlFile.content = data;
                            [self fileDidFinishLoading: urlString];
                        } else {
                            [self fileDidFailLoading: urlString withError: error];
                        }
                    });
                }
                
            }] resume];
}


- (void) prepareSceneForSearch: (Scene*) aScene {
    NSAssert(aScene != nil, @"TourManager: aScene is nil for preparing");
    
    theScene = aScene;
    [self loadObject3DForScene: aScene];
}


- (void) loadObject3DFilesForScene: (Scene*) aScene {
    
    // Delete files of previous scene
    [[FileManager theManager] deleteAllFiles];
    
    // Clear connection dictionary
    if (fileMapTable == nil)
        fileMapTable = [NSMapTable strongToStrongObjectsMapTable];
    else
        [fileMapTable removeAllObjects];
    
    // Remember scene for callback methods
    theScene = aScene;
    
    // Request all files from server
    [self load3DObjectFileForScene: theScene];
    [self load3DObjectMaterialFileForScene: theScene];
    [self loadTextureFilesForScene: theScene];
    [self loadTargetDataFileForScene: theScene];
    [self loadTargetXmlFileForScene: theScene];

}


- (NSError*) parseObj3DFilesForScene: (Scene*) aScene {
    
    Object3D* obj3D = aScene.object3D;
    NSError* error = [parser parseObjFile: obj3D.obj3DFile];
    
    if (error == nil)
        obj3D.oglObjects = parser.oglObjects;

    return error;
}


// Notifications ---------------------------------------------------------------------------------------------------

- (void) didFinishLoadingObject3D: (Object3D*) object3D {
    NSAssert(theScene != nil, @"TourManager: theScene is nil after loading object3D");
    [self loadObject3DFilesForScene: theScene];
}


- (void) didFailLoadingObject3DWithError: (NSError*) error {
    [self.delegate didFailPreparingSceneWithError: error];
}


- (void) fileDidFinishLoading: (NSString*) urlString {
    
    @synchronized(self) {
        NSAssert (fileMapTable != nil && [fileMapTable count] > 0, @"TourManager: file maping table is empty");
    
        File* file = [fileMapTable objectForKey: urlString];
        NSAssert (file != nil, @"TourManager: no file name found in fileMapTable for URL");
    
        [[FileManager theManager] storeFile: file];
        [fileMapTable removeObjectForKey: urlString];
        
        NSLog(@"TourManager: object3D file '%s' loaded", [file.name UTF8String]);
        
        // All scene files received?
        if ([fileMapTable count] == 0) {
            
            NSLog(@"TourManager: object3D files loaded");

            // Parse obj3D file
            NSError* error = [self parseObj3DFilesForScene: theScene];
            
            NSLog(@"TourManager: object3D files parsed");
            
            // Reset connection map
            [fileMapTable removeAllObjects];
            
            // Inform delegate
            if (error == nil)
                [self.delegate didFinishPreparingScene: theScene];
            else {
                [self.delegate didFailPreparingSceneWithError: error];
            }
            
            theScene = nil;
        }
    }
}


- (void) fileDidFailLoading: (NSString*) urlString withError: (NSError*) error {
    
    @synchronized(self) {
        [self.delegate didFailPreparingSceneWithError: error];
    }
}


@end