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

#define kARGamePinAnnotationIdent @"ARGamePinAnnotationView"



@implementation SceneMapViewController

@synthesize scene, sceneMapViewTitle, mapView, cacheFocusButton, userLocation, detailAnnotationView, hintTextView;


// Initialisation --------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    
    if (self != nil) {
        locationManager = [[CLLocationManager alloc] init];
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
        locationManager = [[CLLocationManager alloc] init];
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


- (void) zoomToLocationAndCache {
    // Zoom map view to include user location and annotation (cache)
    CLLocationCoordinate2D userLoc = self.userLocation.coordinate;
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


-(void) locationManager: (CLLocationManager*) manager didUpdateLocations: (NSArray*) locations {
    
    if (self.userLocation == nil) {
        self.userLocation = [locations lastObject];

        [self zoomToLocationAndCache];
    }

}


// Actions -------------------------------------------------------------------------------------

- (IBAction) detectArtifact: (id) sender {
    
    // Goto next scene
    [self performSegueWithIdentifier: @"ImageTargetsView" sender: self];
}


- (IBAction) showHint: (id) sender {
    
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton* button = (UIButton*) sender;
        
        // We need the PinView to show / hide a hint
        UIView* parent = [button superview];
        while (parent!= nil && ![parent isKindOfClass:[MKPinAnnotationView class]]) {
            parent = parent.superview;
        }
        
        if (parent != nil) {
            MKPinAnnotationView* pinView = (MKPinAnnotationView*) parent;
            
            if (pinView.detailCalloutAccessoryView == nil) {
                // Show hint
                // hintTextView.frame = detailAnnotationView.frame;
                // hintTextView.text = scene.cache.text;
                pinView.detailCalloutAccessoryView = detailAnnotationView;
                pinView.detailCalloutAccessoryView.bounds = CGRectMake(0.0, 0.0, 150.0, 70.0);
            }
            else {
                // hide hint
                pinView.detailCalloutAccessoryView = nil;
            }
        }
    }
}


- (IBAction) focusOnCache: (id) sender {
    
    [self zoomToLocationAndCache];
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
