//
//  SceneMapViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 23/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "SceneMapViewController.h"
#import "ImageTargetsViewController.h"
#import "HalfSizePresentationController.h"
#import "HintViewController.h"


#define kARGamePinAnnotationIdent @"ARGamePinAnnotationView"



@implementation SceneMapViewController

@synthesize scene, sceneMapViewTitle, mapView, cacheFocusButton, userLocation, hintView, hintTextView,
            mapTypeToggleButton;


// Initialisation --------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self != nil) {
        locationManager = [CLLocationManager new];
        userLocation = nil;
    }
    
    return self;
}


- (void) dealloc {
    locationManager = nil;
    scene = nil;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Initialize outlets
    NSString* viewTitle = NSLocalizedString(@"SCENE_VIEW_TITLE", @"SceneMapView title");
    sceneMapViewTitle.title = viewTitle;
    
    cacheFocusButton.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    
    if (scene != nil) {
        // Set cache location
        [mapView addAnnotation: scene.cache];
        mapView.delegate = self;
    }
    
    // Let view show user location
    if (locationManager == nil) {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
    }
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
        [locationManager startUpdatingLocation];
    }
    else {
        [locationManager requestWhenInUseAuthorization];
    }
    
    // Let view show user tracking button
    NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];

    MKUserTrackingBarButtonItem* userTrackingItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView: self.mapView];
    [toolbarItems addObject: userTrackingItem];
    [toolbarItems addObjectsFromArray: self.toolbar.items];
    [self.toolbar setItems: toolbarItems];
    
}



// Annotation View Customisation ---------------------------------------------------------------

- (MKAnnotationView*) mapView: (MKMapView*) theMapView viewForAnnotation: (id<MKAnnotation>) annotation {
    
    // We don't have a view for user location pin
    if ([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    // Try to dequeue an existing pin view first
    MKPinAnnotationView* pinView = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier: kARGamePinAnnotationIdent];
    
    // If no pin view already exists, create a new one
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation: annotation
                                                  reuseIdentifier: kARGamePinAnnotationIdent];
    }
    
    pinView.pinTintColor = [UIColor purpleColor];
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;
    
    // Add info button
    UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    [infoButton addTarget: nil action: @selector(showHint:) forControlEvents: UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = infoButton;
    
    // Add custom image
    UIImageView* treasureMapImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"treasure-map-icon-32.png"]];
    pinView.leftCalloutAccessoryView = treasureMapImage;
    
    // Prepare detail view
    pinView.detailCalloutAccessoryView = nil;
    
    return pinView;
}




// CLLocationManagerDelegates ------------------------------------------------------------------

- (void) locationManager: (CLLocationManager*) manager didChangeAuthorizationStatus: (CLAuthorizationStatus) status {

    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        mapView.showsUserLocation = YES;
        [manager startUpdatingLocation];
    }
}


- (void) locationManager: (CLLocationManager*) manager didFailWithError: (NSError*) error {
    
    // Show error message to user
    NSLog(@"SceneMapViewController: locationManager didFailWithError: %@", error);
    NSString* locationErrorTitel = NSLocalizedString(@"CACHE_LOCATION_FAILURE_TITLE", @"Location failure message title");
    NSString* locationErrorMsg = NSLocalizedString(@"CACHE_LOCATION_FAILURE_MSG", @"Location failure message");
    
    [self showAlertWithTitle: locationErrorTitel errorMessage: locationErrorMsg];
}


- (void) zoomToUserLocationAndCache: (CLLocation*) newUserLocation {
    // Zoom map view to include user location and annotation (cache)
    CLLocationCoordinate2D userLoc = newUserLocation.coordinate;
    CLLocationCoordinate2D annotationLoc = scene.cache.coordinate;
    
    // Make map points
    MKMapPoint userPoint = MKMapPointForCoordinate(userLoc);
    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotationLoc);
    
    // Make map rects with 0 size
    MKMapRect userRect = MKMapRectMake(userPoint.x, userPoint.y, 0, 0);
    MKMapRect annotationRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
    
    // Make union of those two rects
    MKMapRect unionRect = MKMapRectUnion(userRect, annotationRect);
    
    // You have the smallest possible rect containing both locations
    MKMapRect unionRectThatFits = [mapView mapRectThatFits: unionRect];
    UIEdgeInsets insets = UIEdgeInsetsMake(50, 50, 50, 50);
    MKMapRect biggerRect = [self.mapView mapRectThatFits: unionRectThatFits edgePadding: insets];
    
    [mapView setVisibleMapRect: biggerRect animated: YES];
}


- (void) locationManager: (CLLocationManager*) manager didUpdateLocations: (NSArray*) locations {
    
    CLLocation* newUserLocation = [locations lastObject];
    
    if (self.userLocation == nil) {
        [self zoomToUserLocationAndCache: newUserLocation];
    }

    self.userLocation = newUserLocation;
}


// Actions -------------------------------------------------------------------------------------

- (IBAction) detectArtifact: (id) sender {
    
    // Goto next scene
    [self performSegueWithIdentifier: @"ImageTargetsView" sender: self];
}


- (IBAction) showHint: (id) sender {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    HintViewController* hintViewController = (HintViewController*)
        [storyboard instantiateViewControllerWithIdentifier: @"HintViewController"];
    
    // Setup presentation & animation config
    [self showDimBackgroundView];
    
    hintViewController.modalPresentationStyle = UIModalPresentationCustom;
    hintViewController.transitioningDelegate = self;
    hintViewController.delegate = self;
    hintViewController.hintText1 = scene.cache.text;
    
    [self presentViewController: hintViewController animated: true completion: nil];
    
}


- (IBAction) focusOnCache: (id) sender {
    
    [self zoomToUserLocationAndCache: self.userLocation];
}


- (IBAction) toggleMapType: (id) sender {
    if (mapView.mapType == MKMapTypeStandard) {
        mapView.mapType = MKMapTypeSatellite;
        
        // Set background of button
        /*
        UIImage* btnBckgImg = [[UIImage imageNamed: @"toolbar_btn_bg.png"]
                               resizableImageWithCapInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
        [mapTypeToggleButton setBackgroundImage: btnBckgImg
                                       forState: UIControlStateNormal
                                     barMetrics: UIBarMetricsDefault];
        mapTypeToggleButton.tintColor = [UIColor whiteColor];
        */
    }
    else {
        mapView.mapType = MKMapTypeStandard;
        
        // Reset background
        /*
        [mapTypeToggleButton setBackgroundImage: nil
                                       forState: UIControlStateNormal
                                     barMetrics: UIBarMetricsDefault];
        mapTypeToggleButton.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        */
    }
}


// UIViewControllerTransitioningDelegate --------------------------------------------------------

- (UIPresentationController*) presentationControllerForPresentedViewController: (UIViewController *) presented
                                                      presentingViewController: (UIViewController *) presenting sourceViewController: (UIViewController *) source {
    
    HalfSizePresentationController* hsPresentationController =
        [[HalfSizePresentationController alloc] initWithPresentedViewController: presented
                                                       presentingViewController: presenting];
    return hsPresentationController;

}


// HintViewControllerDelegate --------------------------------------------------------------------

- (void) hintViewDismissed {
    [self hideDimBackgroundView];
}


// Segue methods --------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString: @"ImageTargetsView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [ImageTargetsViewController class]]) {
            
            // Get reference to the destination view controller
            ImageTargetsViewController* imageTargetsViewController = (ImageTargetsViewController*) destController;
        
            // Pass the scene location
            imageTargetsViewController.scene = self.scene;
        }
    }
}




@end
