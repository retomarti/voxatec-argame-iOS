/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import "ImageTargetsViewController.h"
#import "ARQuestAppDelegate.h"
#import "FileManager.h"
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ObjectTracker.h>
#import <QCAR/Trackable.h>
#import <QCAR/CameraDevice.h>

// #import "SampleAppMenuViewController.h"
#import "RiddleViewController.h"



@interface ImageTargetsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *ARViewPlaceholder;

@end



@implementation ImageTargetsViewController

@synthesize imageTargetsViewTitle, tapGestureRecognizer, vapp, eaglView, scene, audioPlayer, showRiddleButton;


- (CGRect) getCurrentARViewFrame {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect viewFrame = screenBounds;
    
    // If this device has a retina display, scale the view bounds
    // for the AR (OpenGL) view
    if (YES == vapp.isRetinaDisplay) {
        viewFrame.size.width *= 2.0;
        viewFrame.size.height *= 2.0;
    }
    return viewFrame;
}


- (void) loadView {
    
    // Custom initialization
    self.title = @"Search Artifact";
    
    if (self.ARViewPlaceholder != nil) {
        [self.ARViewPlaceholder removeFromSuperview];
        self.ARViewPlaceholder = nil;
    }
    
    extendedTrackingEnabled = YES;
    continuousAutofocusEnabled = YES;
    flashEnabled = NO;
    frontCameraEnabled = NO;
    
    vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
    
    CGRect viewFrame = [self getCurrentARViewFrame];
    
    eaglView = [[ImageTargetsEAGLView alloc] initWithFrame:viewFrame appSession:vapp];
    [self setView:eaglView];
    ARQuestAppDelegate *appDelegate = (ARQuestAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = eaglView;
    
    // double tap used to also trigger the menu
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapGestureAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // a single tap will trigger a single autofocus operation
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
    if (doubleTap != NULL) {
        [tapGestureRecognizer requireGestureRecognizerToFail:doubleTap];
    }
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissARViewController)
                                                 name:@"kDismissARViewController"
                                               object:nil];
    
    // we use the iOS notification to pause/resume the AR when the application goes (or come back from) background
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    
    // initialize AR
    UIInterfaceOrientation intfOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [vapp initAR:QCAR::GL_20 orientation: intfOrientation];

    // show loading animation while AR is being initialized
    [self showLoadingAnimation];
}

- (void) pauseAR {
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR {
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    // on resume, we reset the flash
    QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
    flashEnabled = NO;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.showingMenu = NO;
    
    // Init outlets
    NSString* viewTitle = NSLocalizedString(@"IMG_TARGETS_VIEW_TITLE", @"ImageTargetsView Title");
    imageTargetsViewTitle.title = viewTitle;
    
    // Do any additional setup after loading the view.
    // [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addGestureRecognizer: tapGestureRecognizer];
    
    // Set scene access
    self.eaglView.scene = self.scene;
    self.eaglView.delegate = self;
    
    // Initialize audioPlayer
    NSString* soundFilePath = [[NSBundle mainBundle] pathForResource: @"Magic_wand" ofType: @"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: soundFilePath] error: nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    
    // UIButton
    NSString* buttonText = NSLocalizedString(@"IMG_TARGETS_SHOW_RIDDLE_BUTTON_TEXT", @"Show Riddle Button Text");
    showRiddleButton.title = buttonText;
    showRiddleButton.enabled = false;
}


-(void) viewDidUnload {
    [super viewDidUnload];
    
    self.eaglView.delegate = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
}


- (void) viewWillDisappear:(BOOL) animated {
    // on iOS 7, viewWillDisappear may be called when the menu is shown
    // but we don't want to stop the AR view in that case
    if (self.showingMenu) {
        return;
    }
    
    [vapp stopAR:nil];
    
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [self finishOpenGLESCommands];
    
    ARQuestAppDelegate *appDelegate = (ARQuestAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.glResourceHandler = nil;
    
    [super viewWillDisappear:animated];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    scene = nil;
    audioPlayer = nil;
}

- (void) finishOpenGLESCommands {
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}

- (void) freeOpenGLESResources {
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - loading animation

- (void) showLoadingAnimation {
    
    CGRect indicatorBounds;
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    int smallerBoundsSize = MIN(mainBounds.size.width, mainBounds.size.height);
    int largerBoundsSize = MAX(mainBounds.size.width, mainBounds.size.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        indicatorBounds = CGRectMake(smallerBoundsSize / 2 - 12,
                                     largerBoundsSize / 2 - 12, 24, 24);
    }
    else {
        indicatorBounds = CGRectMake(largerBoundsSize / 2 - 12,
                                     smallerBoundsSize / 2 - 12, 24, 24);
    }
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}


- (void) hideLoadingAnimation {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
}


#pragma mark - SampleApplicationControl

// Initialize the application trackers
- (bool) doInitTrackers {
    
    // Initialize the object tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ObjectTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize ObjectTracker.");
        return false;
    }
    return true;
}


// load the data associated to the trackers
- (bool) doLoadTrackersData {
    
    File* xmlDataFile = scene.targetImgXmlFile;
    QCAR::DataSet* cacheDataSet = [self loadObjectTrackerDataSet: xmlDataFile];

    if (cacheDataSet == NULL) {
        NSLog(@"Failed to load datasets");
        return NO;
    }
    if (! [self activateDataSet: cacheDataSet]) {
        NSLog(@"Failed to activate dataset");
        return NO;
    }

    return YES;
}


// start the application trackers
- (bool) doStartTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ObjectTracker::getClassType());
    if(tracker == 0) {
        return false;
    }
    tracker->start();
    return true;
}


// callback called when the initailization of the AR is done
- (void) onInitARDone: (NSError*) initError {
    
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
    
    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
        
        // by default, we try to set the continuous auto focus mode
        continuousAutofocusEnabled = QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
        
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
        dispatch_async( dispatch_get_main_queue(), ^{
            [self showAlertWithTitle: @"Error" errorMessage: [initError localizedDescription]];
        });
    }
}


#pragma mark - UIAlertViewDelegate

/*
- (void) alertView: (UIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDismissARViewController" object:nil];
}
*/

- (void) dismissARViewController {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void) onQCARUpdate: (QCAR::State *) state {
}


// Load the image tracker data set
- (QCAR::DataSet*) loadObjectTrackerDataSet: (File*) dataFile {
    
    NSLog(@"loadObjectTrackerDataSet (%@)", [dataFile name]);
    QCAR::DataSet * dataSet = NULL;
    
    // Get the QCAR tracker manager image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    if (NULL == objectTracker) {
        NSLog(@"ERROR: failed to get the ObjectTracker from the tracker manager");
        return NULL;
    } else {
        dataSet = objectTracker->createDataSet();
        
        if (NULL != dataSet) {
            NSLog(@"INFO: successfully loaded data set");
            
            // Load the data set from the app's resources location
            NSString* filePath = [[FileManager theManager] pathOfFile: dataFile];
            if (!dataSet->load([filePath cStringUsingEncoding:NSASCIIStringEncoding], QCAR::STORAGE_ABSOLUTE)) {
                NSLog(@"ERROR: failed to load data set");
                objectTracker->destroyDataSet(dataSet);
                dataSet = NULL;
            }
        }
        else {
            NSLog(@"ERROR: failed to create data set");
        }
    }
    
    return dataSet;
}


- (bool) doStopTrackers {
    
    // Stop the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ObjectTracker::getClassType());
    
    if (NULL != tracker) {
        tracker->stop();
        NSLog(@"INFO: successfully stopped tracker");
        return YES;
    }
    else {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return NO;
    }
}


- (bool) doUnloadTrackersData {
    
    [self deactivateDataSet: dataSetCurrent];
    dataSetCurrent = nil;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    // Destroy the data sets:
    if (!objectTracker->destroyDataSet(dataSetCurrent))
    {
        NSLog(@"Failed to destroy current data set.");
    }

    NSLog(@"datasets destroyed");
    return YES;
}


- (BOOL) activateDataSet: (QCAR::DataSet*) theDataSet {
    
    // if we've previously recorded an activation, deactivate it
    if (dataSetCurrent != nil)
    {
        [self deactivateDataSet:dataSetCurrent];
    }
    BOOL success = NO;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    if (objectTracker == NULL) {
        NSLog(@"Failed to load tracking data set because the ObjectTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!objectTracker->activateDataSet(theDataSet))
        {
            NSLog(@"Failed to activate data set.");
        }
        else
        {
            NSLog(@"Successfully activated data set.");
            dataSetCurrent = theDataSet;
            success = YES;
        }
    }
    
    // we set the off target tracking mode to the current state
    if (success) {
        [self setExtendedTrackingForDataSet: dataSetCurrent start: extendedTrackingEnabled];
    }
    
    return success;
}


- (BOOL) deactivateDataSet: (QCAR::DataSet*) theDataSet {
    
    if ((dataSetCurrent == nil) || (theDataSet != dataSetCurrent))
    {
        NSLog(@"Invalid request to deactivate data set.");
        return NO;
    }
    
    BOOL success = NO;
    
    // we deactivate the enhanced tracking
    [self setExtendedTrackingForDataSet:theDataSet start:NO];
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ObjectTracker* objectTracker = static_cast<QCAR::ObjectTracker*>(trackerManager.getTracker(QCAR::ObjectTracker::getClassType()));
    
    if (objectTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ObjectTracker has not been initialized.");
    }
    else
    {
        // Deactivate the data set:
        if (!objectTracker->deactivateDataSet(theDataSet))
        {
            NSLog(@"Failed to deactivate data set.");
        }
        else
        {
            success = YES;
        }
    }
    
    dataSetCurrent = nil;
    
    return success;
}


- (BOOL) setExtendedTrackingForDataSet: (QCAR::DataSet*) theDataSet start:(BOOL) start {
    BOOL result = YES;

    for (int tIdx = 0; tIdx < theDataSet->getNumTrackables(); tIdx++) {
        QCAR::Trackable* trackable = theDataSet->getTrackable(tIdx);
        if (start) {
            if (!trackable->startExtendedTracking())
            {
                NSLog(@"Failed to start extended tracking on: %s", trackable->getName());
                result = false;
            }
        } else {
            if (!trackable->stopExtendedTracking())
            {
                NSLog(@"Failed to stop extended tracking on: %s", trackable->getName());
                result = false;
            }
        }
    }
    return result;
}


- (bool) doDeinitTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(QCAR::ObjectTracker::getClassType());
    return YES;
}


- (void) autofocus: (UITapGestureRecognizer*) sender {
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}


- (void)cameraPerformAutoFocus {
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}


- (void) doubleTapGestureAction: (UITapGestureRecognizer*) theGesture {
}


- (void) swipeGestureAction: (UISwipeGestureRecognizer*) gesture {
}


#pragma mark - menu delegate protocol implementation

- (BOOL) menuProcess: (NSString*) itemName value: (BOOL) value {
    
    NSError * error = nil;
    if ([@"Flash" isEqualToString:itemName]) {
        bool result = QCAR::CameraDevice::getInstance().setFlashTorchMode(value);
        flashEnabled = value && result;
        return result;
    }
    else if ([@"Extended Tracking" isEqualToString:itemName]) {
        bool result = [self setExtendedTrackingForDataSet: dataSetCurrent start:value];
        if (result) {
            [eaglView setOffTargetTrackingMode:value];
        }
        extendedTrackingEnabled = value && result;
        return result;
    }
    else if ([@"Autofocus" isEqualToString:itemName]) {
        int focusMode = value ? QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO : QCAR::CameraDevice::FOCUS_MODE_NORMAL;
        bool result = QCAR::CameraDevice::getInstance().setFocusMode(focusMode);
        continuousAutofocusEnabled = value && result;
        return result;
    }
    else if ([@"Front" isEqualToString:itemName]) {
        if ([vapp stopCamera:&error]) {
            bool result = [vapp startAR:QCAR::CameraDevice::CAMERA_FRONT error:&error];
            frontCameraEnabled = result;
            if (frontCameraEnabled) {
                // Switch Flash toggle OFF, in case it was previously ON,
                // as the front camera does not support flash
                flashEnabled = NO;
            }
            return result;
        } else {
            return false;
        }
    }
    else if ([@"Rear" isEqualToString:itemName]) {
        if ([vapp stopCamera:&error]) {
            bool result = [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
            frontCameraEnabled = !result;
            return result;
        } else {
            return false;
        }
    }

    return false;
}


- (void) menuDidExit {
    self.showingMenu = NO;
}


#pragma mark - Navigation

/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue isKindOfClass:[PresentMenuSegue class]]) {
        UIViewController *dest = [segue destinationViewController];
        
        if ([dest isKindOfClass:[SampleAppMenuViewController class]]) {
            self.showingMenu = YES;
            
            SampleAppMenuViewController *menuVC = (SampleAppMenuViewController *)dest;
            menuVC.menuDelegate = self;
            menuVC.sampleAppFeatureName = @"Image Targets";
            menuVC.dismissItemName = @"Vuforia Samples";
            menuVC.backSegueId = @"BackToImageTargets";
            
            // initialize menu item values (ON / OFF)
            [menuVC setValue:extendedTrackingEnabled forMenuItem:@"Extended Tracking"];
            [menuVC setValue:continuousAutofocusEnabled forMenuItem:@"Autofocus"];
            [menuVC setValue:flashEnabled forMenuItem:@"Flash"];
            [menuVC setValue:frontCameraEnabled forMenuItem:@"Front"];
            [menuVC setValue:!frontCameraEnabled forMenuItem:@"Rear"];
        }
    }
}
*/

- (void) playStartTrackingSound {
    NSAssert(audioPlayer != nil, @"ImageTargetViewController: audioPlayer is nil");
    [audioPlayer setVolume: 1.0];
    [audioPlayer play];
}


// AVAudioPlayerDelegate ----------------------------------------------------------------------------

- (void) audioPlayerDecodeErrorDidOccur: (AVAudioPlayer*) player error:(NSError *)error {
    NSLog(@"ImageTargetViewController: audioPlayer reported an error: %s", [[error localizedDescription] UTF8String]);
}


// SceneTrackerDelegate -----------------------------------------------------------------------------

- (void) startTrackingScene: (Scene*) aScene {
    // Play sound in background thread
    [self performSelectorInBackground: @selector(playStartTrackingSound) withObject: self];
    
    // Show riddle button
    self.showRiddleButton.enabled = true;
}


- (void) endTrackingScene: (Scene*) aScene {
    // Hide riddle button
    // self.showRiddleButton.hidden = true;
}


// Actions ------------------------------------------------------------------------------------------

- (IBAction) showRiddle: (id) sender {
    // Stop tracking
    [self doStopTrackers];
    [self doUnloadTrackersData];
    
    // Goto next scene
    [self performSegueWithIdentifier: @"RiddleView" sender: self];
}


// Segue methods ------------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"RiddleView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [RiddleViewController class]]) {
            
            // Get reference to the destination view controller
            RiddleViewController* riddleViewController = (RiddleViewController*) destController;
            
            // Pass the cache location
            riddleViewController.scene = self.scene;
        }
    }
}


@end
