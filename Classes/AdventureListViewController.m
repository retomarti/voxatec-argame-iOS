//
//  AdventureListViewController.m
//  AR-Quest
//
//  Created by Reto Marti on 23/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import "AdventureListViewController.h"
#import "Adventure.h"
#import "Story.h"
#import "StoryViewController.h"
#import "AdventureDetailViewController.h"


// Header view dimensiosn
#define kHeaderViewHeight 40.0   // pixels
#define kHeaderViewInset  10.0   // pixels



@implementation AdventureListViewController

@synthesize adventuresTitel, adventures, userLocation;


// View initialisation

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Init button list
    infoButtons = [NSMutableArray new];

    // Init outlets
    NSString* advTitleText = NSLocalizedString(@"ADV_LIST_VIEW_TITLE", @"Titel of AdventureListView");
    adventuresTitel.title = advTitleText;
    
    self.tableView.delegate = self;
}


// UITableViewSource delegate methods --------------------------------------------------------------

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section {
    return kHeaderViewHeight;
}


- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView* headerView = nil;
    
    // Title
    if (adventures != nil && section < [adventures count]) {
        Adventure* adv = [adventures objectAtIndex: section];
        
        // Header view
        CGRect frameRect = tableView.frame;
        CGRect viewRect = CGRectMake(0, 0, frameRect.size.width, kHeaderViewHeight);
        headerView = [[UIView alloc] initWithFrame: viewRect];
        headerView.backgroundColor = [UIColor colorWithRed: 0.435 green: 0.494 blue: 0.578 alpha: 0.6];
        
        // Title: adventure name
        CGRect titleRect = CGRectMake(kHeaderViewInset,
                                      0,
                                      frameRect.size.width - kHeaderViewInset,
                                      kHeaderViewHeight);
        UILabel* title = [[UILabel alloc] initWithFrame: titleRect];
        title.text = adv.name;
        title.textColor = [UIColor whiteColor];
        [headerView addSubview: title];
        
        // Info button
        UIButton* infoButton = [UIButton buttonWithType: UIButtonTypeInfoDark];
        CGRect buttonRect = CGRectMake(frameRect.size.width - infoButton.frame.size.width - kHeaderViewInset,
                                       kHeaderViewInset,
                                       infoButton.frame.size.width,
                                       infoButton.frame.size.height);
        infoButton.frame = buttonRect;
        infoButton.tintColor = [UIColor whiteColor];
        [infoButton addTarget: self action:@selector(infoButtonPressed:) forControlEvents: UIControlEventTouchUpInside];
        [infoButtons addObject: infoButton];
        [headerView addSubview: infoButton];
    }
    
    return headerView;
}


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView {
    
    if (adventures != nil)
        return [adventures count];
    else
        return 0;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section {
    
    if (adventures != nil && section < [adventures count]) {
        Adventure* adv = [adventures objectAtIndex: section];
        
        if (adv.stories != nil)
            return [adv.stories count];
        else
            return 0;
    }
    else
        return 0;
}


- (float) distOfUserLocationToStory: (Story*) story {
    Scene* firstScene = (Scene*) [[story scenes] firstObject];
    
    CLLocationCoordinate2D gpsCoords = firstScene.cache.gpsCoordinates;
    CLLocation* advStartLocation = [[CLLocation alloc] initWithLatitude: gpsCoords.latitude longitude: gpsCoords.longitude];
    
    return [userLocation distanceFromLocation: advStartLocation];
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath {
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    // Adventure & stories text
    Adventure* adv = [adventures objectAtIndex: section];
    Story* story = [adv.stories objectAtIndex: row];
    
    NSString* priceText = NSLocalizedString(@"ADV_PRICE_VALUE", @"Preis & Currency");
    NSString* distText = NSLocalizedString(@"ADV_DIST_TO_USER_LOCATION", @"Distance to user location");
    CLLocationDistance userDist = [self distOfUserLocationToStory: story];
    NSString* text = [[[NSString stringWithFormat: priceText, story.price]
                          stringByAppendingString: @", "]
                          stringByAppendingString: [NSString stringWithFormat: distText, userDist / 1000.0]];
    
    cell.textLabel.text = [story name];
    cell.detailTextLabel.text = text;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}


- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath {
    
    [self performSegueWithIdentifier: @"StoryView" sender: self];
}


// Actions ---------------------------------------------------------------------------------------------

- (void) infoButtonPressed: (id) sender {
    NSUInteger advIdx = [infoButtons indexOfObject: sender];
    
    if (advIdx == NSNotFound) {
        selectedAdventure = nil;
        return; // do nothing
    }
    else {
        selectedAdventure = [adventures objectAtIndex: advIdx];
        [self performSegueWithIdentifier: @"AdventureDetailView" sender: self];
    }
}


// Segue methods ----------------------------------------------------------------------------------------

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender:(id) sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString: @"StoryView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [StoryViewController class]]) {

            // Retrieve selected row
            NSIndexPath* selPath = [self.tableView indexPathForSelectedRow];
            NSInteger section = [selPath section];
            NSInteger row = [selPath row];
            Adventure* adventure = [adventures objectAtIndex: section];
            Story* story = [adventure.stories objectAtIndex: row];
        
            // Get reference to the destination view controller
            StoryViewController* storyViewController = (StoryViewController*) destController;
        
            // Pass the selected story to destination controller
            storyViewController.adventure = adventure;
            storyViewController.story = story;
        }
    }
    
    else if ([[segue identifier] isEqualToString: @"AdventureDetailView"]) {
        
        UIViewController* destController = [segue destinationViewController];
        if ([destController isKindOfClass: [AdventureDetailViewController class]] &&
             selectedAdventure != nil) {
            
            // Get reference to the destination view controller
            AdventureDetailViewController* advDetailViewController = (AdventureDetailViewController*) destController;
            
            // Pass the selected story to destination controller
            advDetailViewController.adventure = selectedAdventure;
        }
    }
}


// Segue methods (unwind)
- (IBAction) gotoNextStory: (UIStoryboardSegue*) sender {
    
}


@end
