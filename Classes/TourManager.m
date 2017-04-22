//
//  TourManager.m
//  AR-Quest
//
//  Created by Reto Marti on 03.02.13.
//
//----------------------------------------------------------------------------------------

#import "TourManager.h"
#import "City.h"
#import "Cache.h"
#import "Story.h"
#import "Scene.h"
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
        theAdventure = nil;
        theStory = nil;
        theScene = nil;
        sceneDataLoaded = NO;
        gameStatus = [GameStatus loadInstance];
        parser = [ObjFileParser new];
    }
    
    return self;
}


- (void) dealloc {
    adventures = nil;
    theAdventure = nil;
    theStory = nil;
    theScene = nil;
    delegate = nil;
    gameStatus = nil;
    parser = nil;
    fileMapTable = nil;
}



// Story workflow ------------------------------------------------------------------------------------------

- (void) startStory: (Story*) story {
    theStory = story;
    [gameStatus startStory: story];
}


- (void) continueStory: (Story*) story {
    theStory = story;
    [gameStatus continueStory: story];
}


- (Scene*) gotoFirstScene {
    Scene* firstScene = [theStory firstScene];
    
    if (firstScene != theScene) {
        theScene = firstScene;
        sceneDataLoaded = NO;
        [gameStatus startScene: theScene ofStory: theStory];
    }
    
    return theScene;
}


- (Scene*) gotoNextScene: (Scene*) currentScene {
    [gameStatus endScene: currentScene ofStory: theStory];
    theScene = [theStory nextSceneTo: currentScene];
    sceneDataLoaded = NO;
    
    if (theScene != nil) {
        [gameStatus startScene: theScene ofStory: theStory];
    }
    
    return theScene;
}


- (BOOL) isLastScene: (Scene*) scene {
    return scene == [theStory lastScene];
}


- (Scene*) gotoCurrentScene {
    // Get last started scene of theStory
    Scene* sceneProxy = [gameStatus lastStartedSceneOfStory: theStory];
    
    if (sceneProxy != nil) {
        Scene* currScene = [theStory sceneWithId: sceneProxy.id];
        if (currScene != theScene) {
            theScene = currScene;
            sceneDataLoaded = NO;
        }
    }
    else {
        theScene = [theStory firstScene];
        sceneDataLoaded = NO;
        [gameStatus startScene: theScene ofStory: theStory];
    }
    
    return theScene;
}


- (void) endStory: (Story*) currentStory {
    [gameStatus endStory: currentStory];
    theStory = nil;
    theScene = nil;
    sceneDataLoaded = NO;
}


// Game status ---------------------------------------------------------------------------------------------

- (GameStatus*) gameStatus {
    return gameStatus;
}


- (Story*) currentStory {
    return theStory;
}


- (Scene*) currentScene {
    return theScene;
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
        
        NSArray* cityList = parsedObject;
        
        for (NSDictionary* cityDict in cityList) {
            
            // City
            City* city = [City new];
            city.id = [cityDict valueForKey: @"id"];
            city.name = [[cityDict valueForKey: @"name"] decodeHTMLCharacterEntities];
            NSArray* advList = [cityDict valueForKey: @"adventureList"];
            
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
                    story.city = city;
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
        }
        
        // Inform delegate
        [self.delegate didFinishLoadingAdventures: adventures];

    }
    
    @catch (NSException *exception) {
        NSError* error = [[NSError alloc] initWithDomain: exception.name code: 0 userInfo: exception.userInfo];
        [self.delegate didFailLoadingAdventuresWithError: error];
    }
}


- (void) loadNearbyAdventures: (CLLocation*) userLocation {
    
    CLLocationCoordinate2D coord = [userLocation coordinate];
    NSNumber* gpsLat = [NSNumber numberWithDouble: coord.latitude];
    NSNumber* gpsLng = [NSNumber numberWithDouble: coord.longitude];
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString* urlString = [NSString stringWithFormat: @"%@/nearby-adventure-caches?lang=%@&gpsLong=%@&gpsLat=%@",
                                                      kHostAddress, lang, [gpsLng stringValue], [gpsLat stringValue]];
    
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
        NSNumber* scaleFactor = [obj3DDict valueForKey: @"objScaleFactor"];
        obj3D.objScaleFactor = [scaleFactor doubleValue];
        
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
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%u?lang=%@",
                           kHostAddress,
                           @"objects3D",
                           obj3DId,
                           lang];
    
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
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@?lang=%@",
                           kHostAddress,
                           @"files/obj",
                           obj3D.id,
                           lang];
    
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
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@?lang=%@",
                           kHostAddress,
                           @"files/mtl",
                           obj3D.id,
                           lang];
    
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
        NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@/%@?lang=%@",
                               kHostAddress,
                               @"files/mtl",
                               obj3D.id,
                               textureFile.name,
                               lang];
        
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
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@?lang=%@",
                           kHostAddress,
                           @"files/target-dat",
                           cache.cacheGroupId,
                           lang];
    
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
    NSString* lang   = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@?lang=%@",
                           kHostAddress,
                           @"files/target-xml",
                           cache.cacheGroupId,
                           lang];
    
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
    
    if (!sceneDataLoaded) {
        // Load all files & notify asynchronously
        theScene = aScene;
        [self loadObject3DForScene: aScene];
    }
    else {
        [self.delegate didFinishPreparingScene: aScene];
    }
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
    NSError* error = [parser parseObjFile: obj3D.obj3DFile ofObject: obj3D];
    
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
            if (error == nil) {
                [self.delegate didFinishPreparingScene: theScene];
                sceneDataLoaded = YES;
            }
            else {
                [self.delegate didFailPreparingSceneWithError: error];
                sceneDataLoaded = NO;
            }
            
        }
    }
}


- (void) fileDidFailLoading: (NSString*) urlString withError: (NSError*) error {
    
    @synchronized(self) {
        [self.delegate didFailPreparingSceneWithError: error];
    }
}


@end
