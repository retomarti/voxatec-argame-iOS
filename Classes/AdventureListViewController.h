//
//  AdventureListViewController.h
//  AR-Quest
//
//  Created by Reto Marti on 23/01/16.
//  Copyright © 2016 Voxatec. All rights reserved.
//
//----------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>



@interface AdventureListViewController : UITableViewController <UITableViewDelegate> {
}

// Outlets
@property (strong, nonatomic) IBOutlet UINavigationItem *adventuresTitel;

// Data model
@property (atomic, retain) NSArray* adventures;

@end
